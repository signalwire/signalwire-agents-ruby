# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/signalwire_agents/swaig/function_result'
require_relative '../../lib/signalwire_agents/skills/skill_base'
require_relative '../../lib/signalwire_agents/skills/skill_registry'
require_relative '../../lib/signalwire_agents/skills/builtin/custom_skills'

class CustomSkillsDetailedTest < Minitest::Test
  def test_setup_and_register
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('custom_skills')
    skill = factory.call({
      'tools' => [
        { 'name' => 'my_tool', 'description' => 'Does something', 'response' => 'Done!' }
      ]
    })
    assert skill.setup
    tools = skill.register_tools
    assert_equal 1, tools.size
    assert_equal 'my_tool', tools[0][:name]

    result = tools[0][:handler].call({}, {})
    assert_equal 'Done!', result.response
  end

  def test_setup_fails_without_tools
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('custom_skills')
    skill = factory.call({})
    refute skill.setup
  end

  def test_multiple_tools
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('custom_skills')
    skill = factory.call({
      'tools' => [
        { 'name' => 'tool_a', 'description' => 'A' },
        { 'name' => 'tool_b', 'description' => 'B' }
      ]
    })
    skill.setup
    tools = skill.register_tools
    assert_equal 2, tools.size
  end

  def test_supports_multiple_instances
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('custom_skills')
    skill = factory.call({})
    assert skill.supports_multiple_instances?
  end

  def test_default_response
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('custom_skills')
    skill = factory.call({
      'tools' => [{ 'name' => 'no_response_tool', 'description' => 'Test' }]
    })
    skill.setup
    tools = skill.register_tools
    result = tools[0][:handler].call({}, {})
    assert_includes result.response, 'no_response_tool'
  end
end
