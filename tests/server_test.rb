# frozen_string_literal: true

require 'minitest/autorun'
require 'json'

require_relative '../lib/signalwire_agents/server/agent_server'

# Simple mock agent for testing
class MockAgent
  attr_reader :name, :route

  def initialize(name:, route:)
    @name  = name
    @route = route
  end
end

class AgentServerTest < Minitest::Test
  def setup
    @server = SignalWireAgents::AgentServer.new(host: '127.0.0.1', port: 4567)
  end

  def test_creation
    assert_equal '127.0.0.1', @server.host
    assert_equal 4567, @server.port
  end

  def test_default_creation
    server = SignalWireAgents::AgentServer.new
    assert_equal '0.0.0.0', server.host
    assert_equal 3000, server.port
  end

  def test_register_agent
    agent = MockAgent.new(name: 'test', route: '/test')
    @server.register(agent)

    assert_equal agent, @server.get_agent('/test')
  end

  def test_register_with_explicit_route
    agent = MockAgent.new(name: 'test', route: '/original')
    @server.register(agent, route: '/custom')

    assert_equal agent, @server.get_agent('/custom')
    assert_nil @server.get_agent('/original')
  end

  def test_register_auto_prefixes_slash
    agent = MockAgent.new(name: 'test', route: '/test')
    @server.register(agent, route: 'no_slash')

    assert_equal agent, @server.get_agent('/no_slash')
  end

  def test_register_duplicate_raises
    agent1 = MockAgent.new(name: 'a', route: '/route')
    agent2 = MockAgent.new(name: 'b', route: '/route')
    @server.register(agent1)

    assert_raises(ArgumentError) { @server.register(agent2) }
  end

  def test_unregister
    agent = MockAgent.new(name: 'test', route: '/test')
    @server.register(agent)
    assert_equal agent, @server.get_agent('/test')

    removed = @server.unregister('/test')
    assert_equal agent, removed
    assert_nil @server.get_agent('/test')
  end

  def test_unregister_nonexistent
    assert_nil @server.unregister('/nonexistent')
  end

  def test_get_agents
    a1 = MockAgent.new(name: 'a', route: '/a')
    a2 = MockAgent.new(name: 'b', route: '/b')
    @server.register(a1)
    @server.register(a2)

    agents = @server.get_agents
    assert_equal 2, agents.size
    assert_equal a1, agents['/a']
    assert_equal a2, agents['/b']
  end

  def test_get_agent_not_found
    assert_nil @server.get_agent('/nonexistent')
  end

  def test_rack_app_health_endpoint
    agent = MockAgent.new(name: 'test', route: '/test')
    @server.register(agent)

    app = @server.rack_app
    env = { 'PATH_INFO' => '/health' }
    status, headers, body = app.call(env)

    assert_equal '200', status
    assert_equal 'application/json', headers['Content-Type']
    data = JSON.parse(body.first)
    assert_equal 'ok', data['status']
    assert_includes data['agents'], '/test'
  end

  def test_rack_app_healthz_endpoint
    app = @server.rack_app
    status, _, _ = app.call({ 'PATH_INFO' => '/healthz' })
    assert_equal '200', status
  end

  def test_rack_app_root_endpoint
    agent = MockAgent.new(name: 'test', route: '/test')
    @server.register(agent)

    app = @server.rack_app
    status, _, body = app.call({ 'PATH_INFO' => '/' })

    assert_equal '200', status
    data = JSON.parse(body.first)
    assert_equal 'SignalWire Agent Server', data['service']
    assert_includes data['agents'], '/test'
  end

  def test_rack_app_agent_route
    agent = MockAgent.new(name: 'test', route: '/test')
    @server.register(agent)

    app = @server.rack_app
    status, _, body = app.call({ 'PATH_INFO' => '/test' })

    assert_equal '200', status
    data = JSON.parse(body.first)
    assert_equal '/test', data['agent']
    assert_equal 'registered', data['status']
  end

  def test_rack_app_404
    app = @server.rack_app
    status, _, body = app.call({ 'PATH_INFO' => '/nonexistent' })

    assert_equal '404', status
    data = JSON.parse(body.first)
    assert_equal 'Not found', data['error']
  end

  def test_rack_app_callable_agent
    # Agent that responds to call
    callable_agent = Proc.new { |_env| ['200', { 'Content-Type' => 'text/plain' }, ['hello']] }
    @server.register(callable_agent, route: '/callable')

    app = @server.rack_app
    status, _, body = app.call({ 'PATH_INFO' => '/callable' })

    assert_equal '200', status
    assert_equal 'hello', body.first
  end

  def test_setup_sip_routing
    agent = MockAgent.new(name: 'test', route: '/test')
    @server.register(agent)
    @server.setup_sip_routing(route: '/sip', auto_map: true)

    # No crash is good enough for now; SIP routing is configuration-level
    assert true
  end

  def test_register_sip_username
    @server.register_sip_username('alice', '/agent1')
    assert true  # No crash
  end

  def test_fluent_register
    agent = MockAgent.new(name: 'test', route: '/test')
    result = @server.register(agent)
    assert_same @server, result
  end
end
