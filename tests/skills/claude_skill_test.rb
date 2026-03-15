# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../../lib/signalwire_agents/swaig/function_result'
require_relative '../../lib/signalwire_agents/skills/skill_base'
require_relative '../../lib/signalwire_agents/skills/skill_registry'
require_relative '../../lib/signalwire_agents/skills/builtin/claude_skills'

class ClaudeSkillDetailedTest < Minitest::Test
  def setup
    @tmpdir = File.join(Dir.tmpdir, "claude_skill_test_#{$$}")
    FileUtils.mkdir_p(@tmpdir)
    File.write(File.join(@tmpdir, 'greeting.md'), '# Greeting\nSay hello to the user.')
    File.write(File.join(@tmpdir, 'farewell.md'), '# Farewell\nSay goodbye to the user.')
  end

  def teardown
    FileUtils.rm_rf(@tmpdir) if @tmpdir && File.directory?(@tmpdir)
  end

  def test_setup_requires_skills_path
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('claude_skills')
    skill = factory.call({})
    refute skill.setup
  end

  def test_setup_with_valid_path
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('claude_skills')
    skill = factory.call({ 'skills_path' => @tmpdir })
    assert skill.setup
  end

  def test_register_tools_discovers_md_files
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('claude_skills')
    skill = factory.call({ 'skills_path' => @tmpdir })
    skill.setup
    tools = skill.register_tools
    assert_equal 2, tools.size
    names = tools.map { |t| t[:name] }
    assert names.any? { |n| n.include?('greeting') }
    assert names.any? { |n| n.include?('farewell') }
  end

  def test_custom_tool_prefix
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('claude_skills')
    skill = factory.call({ 'skills_path' => @tmpdir, 'tool_prefix' => 'sk_' })
    skill.setup
    tools = skill.register_tools
    assert tools.all? { |t| t[:name].start_with?('sk_') }
  end

  def test_supports_multiple_instances
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('claude_skills')
    skill = factory.call({})
    assert skill.supports_multiple_instances?
  end
end
