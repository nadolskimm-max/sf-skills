---
name: sf-mulesoft
description: >
  Integrates Salesforce with MuleSoft Anypoint Platform including API-led
  connectivity, Salesforce Connector, DataWeave transformations, and
  integration patterns. Use when building MuleSoft flows for Salesforce,
  configuring Salesforce Connector, writing DataWeave, or designing
  API-led integration architecture. Do NOT use for native Salesforce
  callouts (use sf-integration) or Named Credentials (use sf-integration).
---

# MuleSoft Integration

## Core Responsibilities

1. Design API-led connectivity architecture for Salesforce
2. Configure MuleSoft Salesforce Connector
3. Write DataWeave transformations for data mapping
4. Build integration patterns (sync, async, event-driven)
5. Deploy and monitor MuleSoft APIs in Anypoint

## API-Led Connectivity

```
Experience APIs (mobile, web, partner)
    │
System APIs ← Process APIs → System APIs
(Salesforce)   (orchestration)   (ERP, DB)
```

| Layer | Purpose | Example |
|---|---|---|
| Experience API | Channel-specific | Mobile app API, Partner API |
| Process API | Business logic orchestration | Order processing, lead routing |
| System API | Direct system access | Salesforce CRUD, ERP queries |

## Salesforce Connector Operations

| Operation | Description |
|---|---|
| Create | Insert records |
| Update | Update by ID |
| Upsert | Insert or update by External ID |
| Query | SOQL query |
| Query Single | Single record by ID |
| Delete | Delete by ID |
| Bulk Create/Update/Upsert | Bulk API operations |
| Subscribe Topic | CometD streaming subscription |
| Subscribe Channel | Platform Event subscription |
| Replay Topic/Channel | Replay from position |

### Connector Configuration (XML)

```xml
<salesforce:config name="Salesforce_Config">
    <salesforce:oauth-jwt-connection
        consumerKey="${sf.consumerKey}"
        keyStorePath="${sf.keystorePath}"
        storePassword="${sf.storePassword}"
        principal="${sf.username}"
        audienceUrl="https://login.salesforce.com"
        tokenUrl="https://login.salesforce.com/services/oauth2/token"/>
</salesforce:config>
```

## DataWeave Transformations

### Salesforce Record to JSON

```dataweave
%dw 2.0
output application/json
---
{
    id: payload.Id,
    name: payload.Name,
    industry: payload.Industry default "Unknown",
    contacts: payload.Contacts map ((contact) -> {
        firstName: contact.FirstName,
        lastName: contact.LastName,
        email: contact.Email
    })
}
```

### JSON to Salesforce Record

```dataweave
%dw 2.0
output application/java
---
{
    Name: payload.companyName,
    Industry: payload.industry,
    BillingCity: payload.address.city,
    BillingCountry: payload.address.country,
    External_Id__c: payload.externalId
}
```

### Batch Transformation

```dataweave
%dw 2.0
output application/json
---
payload map ((item) -> {
    Name: item.name,
    Amount__c: item.amount as Number,
    Status__c: if (item.status == "active") "Active" else "Inactive",
    External_Id__c: item.id
})
```

## Integration Patterns

### Real-Time Sync (Salesforce → External)

```
Salesforce Platform Event
  → MuleSoft subscribes via Connector
  → DataWeave transformation
  → POST to external system
  → Error handling + dead letter queue
```

### Batch Sync (External → Salesforce)

```
Scheduler (daily/hourly)
  → Query external database
  → DataWeave transformation
  → Salesforce Bulk Upsert (External ID)
  → Log results + error report
```

### Event-Driven (bidirectional)

```
Salesforce CDC → MuleSoft → External System
External Webhook → MuleSoft → Salesforce upsert
```

## Error Handling

```xml
<error-handler>
    <on-error-propagate type="SALESFORCE:INVALID_INPUT">
        <logger message="Invalid Salesforce input: #[error.description]"/>
        <set-variable variableName="httpStatus" value="400"/>
    </on-error-propagate>
    <on-error-propagate type="SALESFORCE:CONNECTIVITY">
        <logger message="Salesforce connection error: #[error.description]"/>
        <set-variable variableName="httpStatus" value="503"/>
    </on-error-propagate>
    <on-error-continue type="ANY">
        <logger message="Unexpected error: #[error.description]" level="ERROR"/>
    </on-error-continue>
</error-handler>
```

## Anypoint CLI

```bash
# Deploy to CloudHub
anypoint-cli runtime-mgr cloudhub-application deploy <app-name> <artifact.jar>

# List deployments
anypoint-cli runtime-mgr cloudhub-application list

# Check application status
anypoint-cli runtime-mgr cloudhub-application describe <app-name>
```

## Cross-Skill References

- For Salesforce-native callouts: see **sf-integration**
- For Connected Apps (JWT auth): see **sf-connected-apps**
- For Platform Events: see **sf-integration**
- For data mapping requirements: see **sf-data**
