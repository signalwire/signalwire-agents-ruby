# frozen_string_literal: true

# Copyright (c) 2025 SignalWire
#
# Licensed under the MIT License.
# See LICENSE file in the project root for full license information.

require 'json'
require 'thread'

module SignalWireAgents
  # Multi-agent hosting on a single Rack application.
  #
  #   server = AgentServer.new(host: '0.0.0.0', port: 3000)
  #   server.register(my_agent, route: '/agent1')
  #   server.register(my_agent2, route: '/agent2')
  #   server.run
  #
  class AgentServer
    attr_reader :host, :port

    def initialize(host: '0.0.0.0', port: 3000)
      @host   = host
      @port   = port
      @agents = {}   # route => agent object
      @sip_routes = {}  # username => route
      @mutex  = Mutex.new
    end

    # Register an agent at a given route.
    # @param agent [Object] an agent object (e.g. AgentBase or prefab)
    # @param route [String, nil] HTTP route; defaults to agent.route if available
    def register(agent, route: nil)
      route ||= agent.respond_to?(:route) ? agent.route : "/#{agent.object_id}"
      route = "/#{route}" unless route.start_with?('/')

      @mutex.synchronize do
        raise ArgumentError, "Route already registered: #{route}" if @agents.key?(route)
        @agents[route] = agent
      end
      self
    end

    # Unregister an agent by route.
    # @param route [String]
    # @return [Object, nil] the removed agent
    def unregister(route)
      route = "/#{route}" unless route.start_with?('/')
      @mutex.synchronize { @agents.delete(route) }
    end

    # Get all registered agents.
    # @return [Hash] route => agent
    def get_agents
      @mutex.synchronize { @agents.dup }
    end

    # Get a specific agent by route.
    # @param route [String]
    # @return [Object, nil]
    def get_agent(route)
      route = "/#{route}" unless route.start_with?('/')
      @mutex.synchronize { @agents[route] }
    end

    # Set up SIP-based routing.
    # @param route [String] the route to handle SIP requests
    # @param auto_map [Boolean] automatically map agent names as SIP usernames
    def setup_sip_routing(route: '/sip', auto_map: true)
      @sip_route = route
      if auto_map
        @mutex.synchronize do
          @agents.each do |r, agent|
            username = r.sub(%r{^/}, '').tr('/', '_')
            @sip_routes[username] = r
          end
        end
      end
      self
    end

    # Register a SIP username mapping to a route.
    def register_sip_username(username, route)
      route = "/#{route}" unless route.start_with?('/')
      @mutex.synchronize { @sip_routes[username] = route }
      self
    end

    # Run the server using WEBrick (stdlib).
    def run
      app = rack_app
      require 'webrick'
      server = WEBrick::HTTPServer.new(
        Host: @host,
        Port: @port,
        Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN),
        AccessLog: []
      )
      server.mount('/', Rack::Handler::WEBrick, app) if defined?(Rack::Handler::WEBrick)
      trap('INT') { server.shutdown }
      trap('TERM') { server.shutdown }
      server.start
    end

    # Build a Rack application that routes requests to the appropriate agent.
    # @return [Proc] a Rack-compatible app
    def rack_app
      agents     = @agents
      sip_routes = @sip_routes
      server     = self

      Proc.new do |env|
        path = env['PATH_INFO'] || '/'

        case path
        when '/health', '/healthz'
          body = { status: 'ok', agents: agents.keys }.to_json
          ['200', { 'Content-Type' => 'application/json' }, [body]]

        when '/'
          body = {
            service: 'SignalWire Agent Server',
            agents: agents.keys,
            version: defined?(SignalWireAgents::VERSION) ? SignalWireAgents::VERSION : '1.0.0'
          }.to_json
          ['200', { 'Content-Type' => 'application/json' }, [body]]

        else
          # Find the matching agent by longest prefix match
          agent = nil
          matched_route = nil

          agents.each do |route, a|
            if path == route || path.start_with?("#{route}/")
              if matched_route.nil? || route.length > matched_route.length
                matched_route = route
                agent = a
              end
            end
          end

          if agent
            if agent.respond_to?(:call)
              agent.call(env)
            elsif agent.respond_to?(:rack_app)
              agent.rack_app.call(env)
            else
              body = { agent: matched_route, status: 'registered' }.to_json
              ['200', { 'Content-Type' => 'application/json' }, [body]]
            end
          else
            body = { error: 'Not found', path: path }.to_json
            ['404', { 'Content-Type' => 'application/json' }, [body]]
          end
        end
      end
    end
  end
end
