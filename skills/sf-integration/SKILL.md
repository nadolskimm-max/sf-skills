---
name: sf-integration
description: >
  Builds Salesforce integrations including Named Credentials, External
  Services, REST/SOAP callouts, Platform Events, and Change Data Capture.
  Use when creating callout services, configuring Named Credentials,
  publishing/subscribing to Platform Events, setting up CDC triggers,
  or working with External Services from OpenAPI specs. Do NOT use for
  OAuth/Connected Apps (use sf-connected-apps) or Apex-only logic (use sf-apex).
---

# Salesforce Integration

## Core Responsibilities

1. Create Named Credentials and External Credentials metadata
2. Build REST/SOAP callout services in Apex
3. Configure Platform Events for async messaging
4. Set up Change Data Capture (CDC) triggers
5. Generate External Services from OpenAPI specs

## Named Credentials

### Named Credential (Per-User Auth)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<NamedCredential xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Stripe API</label>
    <developerName>Stripe_API</developerName>
    <endpoint>https://api.stripe.com/v1</endpoint>
    <principalType>NamedUser</principalType>
    <protocol>Password</protocol>
</NamedCredential>
```

### External Credential + Named Credential (Modern Pattern)

```xml
<!-- External Credential -->
<?xml version="1.0" encoding="UTF-8"?>
<ExternalCredential xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Stripe External</label>
    <authenticationProtocol>Custom</authenticationProtocol>
    <externalCredentialParameters>
        <parameterName>ApiKey</parameterName>
        <parameterType>AuthHeader</parameterType>
    </externalCredentialParameters>
</ExternalCredential>
```

## REST Callout Pattern

```apex
public class StripeService {
    private static final String NAMED_CREDENTIAL = 'callout:Stripe_API';

    public static HttpResponse createCharge(Decimal amount, String currency_x) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + '/charges');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String, Object>{
            'amount' => (Integer)(amount * 100),
            'currency' => currency_x
        }));
        req.setTimeout(30000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            throw new CalloutException('Stripe API error: ' + res.getStatusCode()
                + ' ' + res.getBody());
        }
        return res;
    }
}
```

### Retry Pattern

```apex
public class RetryableCallout {
    private static final Integer MAX_RETRIES = 3;
    private static final Integer[] RETRY_DELAYS = new Integer[]{1000, 2000, 4000};

    public static HttpResponse sendWithRetry(HttpRequest req) {
        HttpResponse res;
        for (Integer attempt = 0; attempt < MAX_RETRIES; attempt++) {
            res = new Http().send(req);
            if (res.getStatusCode() < 500) {
                return res;
            }
            // Server error — retry (note: sleep not available in Apex,
            // use Queueable chaining for actual delays)
        }
        throw new CalloutException('Max retries exceeded. Last status: '
            + res.getStatusCode());
    }
}
```

## Platform Events

### Define Platform Event

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Order Event</label>
    <pluralLabel>Order Events</pluralLabel>
    <eventType>HighVolume</eventType>
    <publishBehavior>PublishAfterCommit</publishBehavior>
    <fields>
        <fullName>Order_Id__c</fullName>
        <label>Order Id</label>
        <type>Text</type>
        <length>18</length>
    </fields>
    <fields>
        <fullName>Status__c</fullName>
        <label>Status</label>
        <type>Text</type>
        <length>50</length>
    </fields>
</CustomObject>
```

### Publish Event (Apex)

```apex
Order_Event__e event = new Order_Event__e(
    Order_Id__c = order.Id,
    Status__c = 'Shipped'
);
Database.SaveResult sr = EventBus.publish(event);
if (!sr.isSuccess()) {
    for (Database.Error err : sr.getErrors()) {
        System.debug(LoggingLevel.ERROR, 'Event publish error: ' + err.getMessage());
    }
}
```

### Subscribe (Apex Trigger)

```apex
trigger OrderEventTrigger on Order_Event__e (after insert) {
    List<Task> tasks = new List<Task>();
    for (Order_Event__e event : Trigger.new) {
        if (event.Status__c == 'Shipped') {
            tasks.add(new Task(
                Subject = 'Order shipped: ' + event.Order_Id__c,
                WhatId = event.Order_Id__c
            ));
        }
    }
    if (!tasks.isEmpty()) {
        insert tasks;
    }
}
```

## Change Data Capture (CDC)

### Enable CDC

Configure in Setup > Change Data Capture, or via metadata:

```bash
sf data query --query "SELECT Id, DeveloperName FROM ChangeDataCaptureConfig" --target-org <alias> --use-tooling-api
```

### CDC Trigger

```apex
trigger AccountChangeEventTrigger on AccountChangeEvent (after insert) {
    for (AccountChangeEvent event : Trigger.new) {
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        if (header.getChangeType() == 'UPDATE') {
            List<String> changedFields = header.getChangedFields();
            // Process changes
        }
    }
}
```

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Hardcoded endpoints in Apex | Use Named Credentials |
| No timeout on callouts | Always set `req.setTimeout()` |
| No error handling for callout responses | Check status code, handle errors |
| Synchronous callout from trigger | Use `@future(callout=true)` or Queueable |
| No retry logic for transient failures | Implement retry with backoff |

## Cross-Skill References

- For OAuth/Connected Apps: see **sf-connected-apps**
- For Apex callout code: see **sf-apex**
- For testing callout mocks: see **sf-testing**
- For deploying integrations: see **sf-deploy**
