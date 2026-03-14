# Examples

Standalone Ruby scripts demonstrating the SignalWire AI Agents SDK. Each example uses `require 'signalwire_agents'` and can be run directly.

## Agent Examples

| File | Description |
|------|-------------|
| [simple_agent.rb](simple_agent.rb) | Basic agent with tools, hints, and language configuration |
| [simple_dynamic_agent.rb](simple_dynamic_agent.rb) | Per-request dynamic configuration callback for multi-tenant deployments |
| [multi_agent_server.rb](multi_agent_server.rb) | Three agents (sales, support, receptionist) hosted on one AgentServer |
| [contexts_demo.rb](contexts_demo.rb) | Multi-step workflows using the contexts and steps system |
| [datamap_demo.rb](datamap_demo.rb) | Server-side DataMap tools (weather API, calculator, jokes) |
| [skills_demo.rb](skills_demo.rb) | Built-in skills: datetime, math, and joke |
| [session_state.rb](session_state.rb) | Global data, post-prompt analysis, and on_summary callback |
| [call_flow.rb](call_flow.rb) | Verb management (pre-answer, post-answer, post-AI), recording, debug events |

## Client Examples

| File | Description |
|------|-------------|
| [relay_demo.rb](relay_demo.rb) | RELAY WebSocket client: answer calls, play TTS, record, handle messages |
| [rest_demo.rb](rest_demo.rb) | REST HTTP client: manage AI agents, phone numbers, video rooms, queues |

## Prefab Examples

| File | Description |
|------|-------------|
| [prefab_info_gatherer.rb](prefab_info_gatherer.rb) | InfoGatherer prefab: collect structured answers from callers |
| [prefab_survey.rb](prefab_survey.rb) | Survey prefab: conduct automated phone surveys with ratings and open-ended questions |

## Running

```bash
# Install dependencies
cd /path/to/signalwire-agents-ruby
bundle install

# Run any example
ruby examples/simple_agent.rb

# For RELAY/REST examples, set environment variables first:
export SIGNALWIRE_PROJECT_ID=your-project-id
export SIGNALWIRE_API_TOKEN=your-api-token
export SIGNALWIRE_SPACE=your-space.signalwire.com
ruby examples/relay_demo.rb
```

## More Examples

Additional examples for the RELAY and REST clients are in their respective directories:

- [relay/examples/](../relay/examples/) -- RELAY WebSocket examples (answer, dial, IVR)
- [rest/examples/](../rest/examples/) -- REST API examples (all 12 namespaces)
