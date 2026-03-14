# frozen_string_literal: true

# Copyright (c) 2025 SignalWire
#
# Licensed under the MIT License.
# See LICENSE file in the project root for full license information.

module SignalWireAgents
  module Swaig
    # Wrapper around SWAIG function responses that handles proper formatting
    # of response text and actions.
    #
    # The result object has three main components:
    #   1. response  - Text the AI should say back to the user
    #   2. action    - List of structured actions to execute
    #   3. post_process - Whether to let AI take another turn before executing actions
    #
    # All mutator methods return +self+ for fluent chaining.
    #
    #   result = SwaigFunctionResult.new("Found your order")
    #
    #   result = SwaigFunctionResult.new("Transferring you")
    #            .add_action("transfer", { "dest" => "support" })
    #
    class FunctionResult
      attr_accessor :response, :action, :post_process

      def initialize(response = nil, post_process: false)
        @response = response || ""
        @action = []
        @post_process = post_process
      end

      # Set the natural-language response text.
      def set_response(text)
        @response = text
        self
      end

      # Set whether to enable post-processing.
      def set_post_process(val)
        @post_process = val
        self
      end

      # Add a single structured action.
      def add_action(name, data)
        @action << { name => data }
        self
      end

      # Add multiple structured actions.
      def add_actions(actions)
        @action.concat(actions)
        self
      end

      # Serialize to the Hash expected by SWAIG / SWML.
      def to_h
        result = {}
        result["response"] = @response if @response && !@response.empty?
        result["action"]   = @action   if @action && !@action.empty?
        result["post_process"] = true   if @post_process && !@action.empty?
        result
      end
    end
  end
end
