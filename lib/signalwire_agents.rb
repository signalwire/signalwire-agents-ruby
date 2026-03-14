# frozen_string_literal: true

require_relative 'signalwire_agents/version'
require_relative 'signalwire_agents/logging'
require_relative 'signalwire_agents/swml/document'
require_relative 'signalwire_agents/swml/schema'
require_relative 'signalwire_agents/swml/service'
require_relative 'signalwire_agents/swaig/function_result'
require_relative 'signalwire_agents/security/session_manager'
require_relative 'signalwire_agents/contexts/context_builder'
require_relative 'signalwire_agents/datamap/data_map'
require_relative 'signalwire_agents/skills/skill_base'
require_relative 'signalwire_agents/skills/skill_manager'
require_relative 'signalwire_agents/skills/skill_registry'
require_relative 'signalwire_agents/agent/agent_base'

module SignalWireAgents
  # Top-level convenience: re-export VERSION from version.rb
end
