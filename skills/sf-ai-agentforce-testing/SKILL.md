---
name: sf-ai-agentforce-testing
description: >
  Creates test specifications and validation strategies for Agentforce
  agents. Use when writing agent test scenarios, building conversation
  test scripts, validating agent behavior against persona rules, or
  running agentic fix loops. Do NOT use for Apex unit tests (use sf-testing)
  or agent configuration (use sf-ai-agentforce).
---

# Agentforce Testing

## Core Responsibilities

1. Create agent test specifications (scenario-based)
2. Build conversation test scripts with expected outcomes
3. Validate topic routing accuracy
4. Test guardrail enforcement
5. Run agentic fix loops (test → diagnose → fix → retest)

## Test Specification Format

```yaml
test_suite: Customer Support Agent
agent: Customer_Support_Agent
version: "1.0"

test_cases:
  - id: TC-001
    name: Order Lookup - Happy Path
    description: Agent correctly retrieves order by number
    setup:
      - Create Order__c with Name='ORD-1001', Status__c='Shipped'
    conversation:
      - user: "Where is my order ORD-1001?"
      - expected_action: OrderLookupAction
      - expected_topic: Order Management
      - assert_response_contains:
          - "ORD-1001"
          - "Shipped"
    teardown:
      - Delete test Order__c

  - id: TC-002
    name: Order Lookup - Not Found
    description: Agent handles missing order gracefully
    conversation:
      - user: "Check order ORD-9999"
      - expected_topic: Order Management
      - assert_response_contains:
          - "couldn't find"
          - "verify the order number"
      - assert_response_not_contains:
          - "error"
          - "exception"
          - "null"

  - id: TC-003
    name: Guardrail - Refund Limit
    description: Agent escalates for refunds above $500
    conversation:
      - user: "I want a refund of $750 for order ORD-1001"
      - assert_escalation: true
      - assert_response_contains:
          - "connect you"
          - "team lead"

  - id: TC-004
    name: Topic Routing
    description: Agent routes to correct topic
    conversation:
      - user: "I need to return a product"
      - expected_topic: Returns & Refunds
      - user: "Actually, where is my order?"
      - expected_topic: Order Management
```

## Test Categories

| Category | What to Test | Example |
|---|---|---|
| **Happy Path** | Core functionality works | Order lookup returns correct data |
| **Error Handling** | Graceful failure | Missing record, invalid input |
| **Guardrails** | Boundaries enforced | PII protection, refund limits |
| **Topic Routing** | Correct topic selected | Switching between order/return topics |
| **Escalation** | Handoff triggers correctly | Customer requests human agent |
| **Persona** | Tone and style matches | Empathetic response to complaint |
| **Edge Cases** | Unusual inputs handled | Empty input, very long message, special chars |

## Agentic Fix Loop

When a test fails, follow this iterative process:

```
1. RUN test suite
2. IDENTIFY failures
3. DIAGNOSE root cause:
   - Action returned wrong data? → Fix Apex/Flow
   - Wrong topic selected? → Adjust topic description/keywords
   - Guardrail not enforced? → Update system instructions
   - Tone mismatch? → Refine persona instructions
4. APPLY fix
5. RETEST (go to step 1)
6. REPEAT until all tests pass (max 3 iterations)
```

## Validation Checklist

### Action Validation
- [ ] Each action returns expected data format
- [ ] Error responses are user-friendly (no technical jargon)
- [ ] Actions handle null/empty inputs gracefully

### Topic Validation
- [ ] Each topic triggers on correct keywords
- [ ] No topic overlap (ambiguous routing)
- [ ] Fallback topic handles unrecognized queries

### Persona Validation
- [ ] Agent uses correct name and greeting
- [ ] Tone matches persona specification
- [ ] Escalation messages include context summary
- [ ] Guardrails prevent prohibited behaviors

### Performance Validation
- [ ] Agent responds within acceptable latency
- [ ] Actions complete without governor limit errors
- [ ] Concurrent sessions don't interfere

## Cross-Skill References

- For agent configuration: see **sf-ai-agentforce**
- For persona rules to validate: see **sf-ai-agentforce-persona**
- For session tracing in production: see **sf-ai-agentforce-observability**
- For Apex test patterns: see **sf-testing**
