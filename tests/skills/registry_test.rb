# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/signalwire_agents/swaig/function_result'
require_relative '../../lib/signalwire_agents/datamap/data_map'
require_relative '../../lib/signalwire_agents/skills/skill_base'
require_relative '../../lib/signalwire_agents/skills/skill_manager'
require_relative '../../lib/signalwire_agents/skills/skill_registry'

SignalWireAgents::Skills::SkillRegistry.register_builtins!

class RegistryDetailedTest < Minitest::Test
  EXPECTED_SKILLS = %w[
    api_ninjas_trivia claude_skills custom_skills datasphere datasphere_serverless
    datetime google_maps info_gatherer joke math mcp_gateway native_vector_search
    play_background_file spider swml_transfer weather_api web_search wikipedia_search
  ].freeze

  def test_has_all_18_skills
    registered = SignalWireAgents::Skills::SkillRegistry.list_skills.sort
    EXPECTED_SKILLS.each do |skill_name|
      assert_includes registered, skill_name, "Missing skill: #{skill_name}"
    end
    assert registered.size >= 18
  end

  def test_each_skill_can_be_instantiated
    EXPECTED_SKILLS.each do |skill_name|
      factory = SignalWireAgents::Skills::SkillRegistry.get_factory(skill_name)
      refute_nil factory, "No factory for: #{skill_name}"
      skill = factory.call({})
      assert_kind_of SignalWireAgents::Skills::SkillBase, skill
      assert_equal skill_name, skill.name
    end
  end

  def test_registered_check
    assert SignalWireAgents::Skills::SkillRegistry.registered?('datetime')
    refute SignalWireAgents::Skills::SkillRegistry.registered?('nonexistent_skill_xyz')
  end

  def test_get_factory_returns_nil_for_unknown
    assert_nil SignalWireAgents::Skills::SkillRegistry.get_factory('nonexistent_skill_xyz')
  end
end

class ManagerDetailedTest < Minitest::Test
  def setup
    @manager = SignalWireAgents::Skills::SkillManager.new
  end

  def test_load_and_get
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('datetime')
    skill = factory.call({})
    @manager.load('datetime', skill)
    assert @manager.loaded?('datetime')
    assert_equal skill, @manager.get('datetime')
    assert_equal 1, @manager.size
  end

  def test_unload
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('math')
    skill = factory.call({})
    @manager.load('math', skill)
    removed = @manager.unload('math')
    assert_equal skill, removed
    refute @manager.loaded?('math')
  end

  def test_load_duplicate_raises
    factory = SignalWireAgents::Skills::SkillRegistry.get_factory('datetime')
    skill = factory.call({})
    @manager.load('datetime', skill)
    assert_raises(ArgumentError) { @manager.load('datetime', skill) }
  end

  def test_loaded_keys
    %w[datetime math].each do |name|
      factory = SignalWireAgents::Skills::SkillRegistry.get_factory(name)
      @manager.load(name, factory.call({}))
    end
    keys = @manager.loaded_keys.sort
    assert_equal %w[datetime math], keys
  end

  def test_clear
    %w[datetime math].each do |name|
      factory = SignalWireAgents::Skills::SkillRegistry.get_factory(name)
      @manager.load(name, factory.call({}))
    end
    @manager.clear
    assert_equal 0, @manager.size
  end
end
