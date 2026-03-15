# frozen_string_literal: true

require 'minitest/autorun'

ENV['SIGNALWIRE_LOG_MODE'] = 'off'

require_relative '../lib/signalwire_agents'

class TypeInferenceTest < Minitest::Test
  def test_port_from_integer
    agent = SignalWireAgents::AgentBase.new(port: 8080)
    assert_equal 8080, agent.port
  end

  def test_port_from_env_string
    ENV['PORT'] = '9999'
    agent = SignalWireAgents::AgentBase.new
    assert_equal 9999, agent.port
  ensure
    ENV.delete('PORT')
  end

  def test_route_normalisation_trailing_slash
    agent = SignalWireAgents::AgentBase.new(route: '/foo/')
    assert_equal '/foo', agent.route
  end

  def test_empty_route_becomes_root
    agent = SignalWireAgents::AgentBase.new(route: '')
    assert_equal '/', agent.route
  end

  def test_basic_auth_array
    agent = SignalWireAgents::AgentBase.new(basic_auth: ['u', 'p'])
    creds = agent.get_basic_auth_credentials
    assert_instance_of Array, creds
    assert_equal 2, creds.length
  end

  def test_swml_version_string
    agent = SignalWireAgents::AgentBase.new
    swml = agent.render_swml
    assert_instance_of String, swml['version']
    assert_equal '1.0.0', swml['version']
  end

  def test_sections_is_hash
    agent = SignalWireAgents::AgentBase.new
    swml = agent.render_swml
    assert_instance_of Hash, swml['sections']
  end

  def test_main_section_is_array
    agent = SignalWireAgents::AgentBase.new
    swml = agent.render_swml
    assert_instance_of Array, swml['sections']['main']
  end

  def test_define_tools_returns_array
    agent = SignalWireAgents::AgentBase.new
    tools = agent.define_tools
    assert_instance_of Array, tools
  end

  def test_function_result_response_is_string
    fr = SignalWireAgents::Swaig::FunctionResult.new('Hello')
    assert_instance_of String, fr.response
  end

  def test_function_result_action_is_array
    fr = SignalWireAgents::Swaig::FunctionResult.new
    assert_instance_of Array, fr.action
  end

  def test_document_to_h_returns_hash
    doc = SignalWireAgents::SWML::Document.new
    assert_instance_of Hash, doc.to_h
  end

  def test_document_render_returns_string
    doc = SignalWireAgents::SWML::Document.new
    assert_instance_of String, doc.render
  end

  def test_skill_params_string_keys
    skill = SignalWireAgents::Skills::SkillBase.new({ foo: 'bar', 'baz' => 'qux' })
    assert_equal 'bar', skill.get_param('foo')
    assert_equal 'qux', skill.get_param('baz')
  end

  def test_context_builder_to_h_returns_hash
    builder = SignalWireAgents::Contexts::ContextBuilder.new
    ctx = builder.add_context('default')
    ctx.add_step('s1').set_text('Hello')
    h = builder.to_h
    assert_instance_of Hash, h
  end
end
