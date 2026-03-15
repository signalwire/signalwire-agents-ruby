# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/signalwire_agents/rest/signalwire_client'

class RestCallingDetailedTest < Minitest::Test
  def setup
    @http = SignalWireAgents::REST::HttpClient.new('proj', 'tok', 'test.signalwire.com')
  end

  def test_calling_path
    resource = SignalWireAgents::REST::Namespaces::CallingNamespace.new(@http)
    assert_equal '/api/calling/calls', resource.instance_variable_get(:@base_path)
  end

  def test_calling_namespace_exists
    client = SignalWireAgents::REST::SignalWireClient.new(
      project: 'proj', token: 'tok', host: 'test.signalwire.com'
    )
    refute_nil client.calling
  end
end
