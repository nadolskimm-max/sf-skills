---
name: sf-ai-agentforce
description: >
  Builds Salesforce Agentforce agents using Agent Builder, PromptTemplates,
  Models API, and GenAi metadata. Use when creating agents, topics, actions,
  GenAiFunction/GenAiPlanner metadata, or working with Einstein Models API.
  Do NOT use for persona design (use sf-ai-agentforce-persona), testing
  (use sf-ai-agentforce-testing), or observability (use sf-ai-agentforce-observability).
---

# Agentforce Development

## Core Responsibilities

1. Create Agentforce agents with topics and actions
2. Generate GenAi metadata (GenAiFunction, GenAiPlanner, GenAiPlannerBundle)
3. Build PromptTemplates for agent instructions
4. Configure agent actions (Apex, Flow, API-based)
5. Deploy agent configurations to orgs

## Key Concepts

| Concept | Description |
|---|---|
| **Agent** | An AI-powered assistant configured in Agent Builder |
| **Topic** | A scope of expertise the agent handles (e.g., "Order Management") |
| **Action** | A capability bound to a topic (Apex, Flow, or API call) |
| **GenAiFunction** | Metadata describing an invocable action for the agent |
| **GenAiPlanner** | The agent's orchestration configuration |
| **PromptTemplate** | Reusable prompt with merge fields for dynamic context |

## Workflow

### Phase 1 — Design

- Define the agent's purpose and target audience
- Map out topics (areas of expertise)
- Identify actions per topic (what the agent can do)
- Plan escalation paths and guardrails

### Phase 2 — Build Actions

Actions connect to existing Apex or Flow logic:

**Apex Invocable Action:**
```apex
public class OrderLookupAction {
    @InvocableMethod(label='Look Up Order'
                     description='Retrieves order details by order number')
    public static List<OrderResult> lookupOrder(List<OrderRequest> requests) {
        List<OrderResult> results = new List<OrderResult>();
        for (OrderRequest req : requests) {
            Order__c order = [
                SELECT Id, Name, Status__c, Total__c
                FROM Order__c
                WHERE Name = :req.orderNumber
                LIMIT 1
            ];
            OrderResult res = new OrderResult();
            res.orderId = order.Id;
            res.status = order.Status__c;
            res.total = order.Total__c;
            results.add(res);
        }
        return results;
    }

    public class OrderRequest {
        @InvocableVariable(required=true description='The order number to look up')
        public String orderNumber;
    }

    public class OrderResult {
        @InvocableVariable(description='The Salesforce record ID')
        public String orderId;
        @InvocableVariable(description='Current order status')
        public String status;
        @InvocableVariable(description='Order total amount')
        public Decimal total;
    }
}
```

### Phase 3 — GenAi Metadata

**GenAiFunction** (wraps the invocable action):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<GenAiFunction xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>Look Up Order</masterLabel>
    <description>Retrieves order details by order number</description>
    <capabilityType>InvocableAction</capabilityType>
    <invocableActionName>OrderLookupAction</invocableActionName>
    <invocableActionType>apex</invocableActionType>
</GenAiFunction>
```

**GenAiPlanner:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<GenAiPlanner xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>Customer Support Agent</masterLabel>
    <description>Handles customer inquiries about orders and returns</description>
    <plannerType>Agent</plannerType>
</GenAiPlanner>
```

### Phase 4 — PromptTemplate

```xml
<?xml version="1.0" encoding="UTF-8"?>
<GenAiPromptTemplate xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>Case Summary</masterLabel>
    <description>Summarizes a support case for agent context</description>
    <templateVersions>
        <content>Summarize this support case:
Subject: {!$Input:CaseSubject}
Description: {!$Input:CaseDescription}
Priority: {!$Input:CasePriority}

Provide a concise 2-3 sentence summary focusing on the customer's issue and urgency.</content>
        <templateVersion>1</templateVersion>
    </templateVersions>
</GenAiPromptTemplate>
```

### Phase 5 — Deploy

```bash
# Deploy agent metadata
sf project deploy start --source-dir force-app/main/default/genAiFunctions --target-org <alias>
sf project deploy start --source-dir force-app/main/default/genAiPlanners --target-org <alias>

# Requires API v66.0+ for full GenAiPlannerBundle support
```

## Agent Architecture Pattern

```
Agent (GenAiPlanner)
├── Topic: Order Management
│   ├── Action: Look Up Order (GenAiFunction → Apex)
│   ├── Action: Cancel Order (GenAiFunction → Flow)
│   └── Action: Track Shipment (GenAiFunction → API)
├── Topic: Returns & Refunds
│   ├── Action: Initiate Return (GenAiFunction → Flow)
│   └── Action: Check Refund Status (GenAiFunction → Apex)
└── Guardrails
    ├── Max actions per turn: 5
    ├── Escalation: Transfer to human after 3 failed attempts
    └── PII handling: Mask credit card numbers
```

## API Version Requirements

| Feature | Minimum API Version |
|---|---|
| GenAiFunction | 62.0 (Winter '25) |
| GenAiPlanner | 62.0 |
| GenAiPlannerBundle | 66.0 (Spring '26) |
| PromptTemplate | 62.0 |
| Models API | 62.0 |

## Cross-Skill References

- For persona design: see **sf-ai-agentforce-persona**
- For agent testing: see **sf-ai-agentforce-testing**
- For session tracing: see **sf-ai-agentforce-observability**
- For Apex invocable actions: see **sf-apex**
- For Flow-based actions: see **sf-flow**
