---
name: sf-slack
description: >
  Integrates Salesforce with Slack including Slack apps, message
  formatting, interactive components, shortcuts, and the Salesforce
  for Slack package. Use when building Slack notifications from
  Salesforce, creating interactive Slack messages, configuring Salesforce
  for Slack, or building custom Slack apps that interact with Salesforce.
  Do NOT use for general integrations (use sf-integration) or email
  notifications (use sf-email).
---

# Slack Integration

## Core Responsibilities

1. Configure Salesforce for Slack package
2. Build custom Slack notifications from Salesforce
3. Create interactive Slack messages with Block Kit
4. Implement Slack shortcuts and actions for Salesforce data
5. Design Slack-first workflows with Salesforce backend

## Salesforce for Slack (Official Package)

### Features

| Feature | Description |
|---|---|
| Record Alerts | Push Salesforce record updates to Slack channels |
| Account/Opportunity Channels | Auto-create channels for records |
| Search in Slack | Search Salesforce from Slack |
| Flows in Slack | Run Salesforce Flows from Slack messages |
| Approval Requests | Approve/reject in Slack |

### Setup

```
1. Install Salesforce for Slack package (AppExchange)
2. Connect Slack workspace (Setup → Slack)
3. Configure alert rules (per object/field)
4. Map Salesforce users to Slack users
5. Set up channel naming conventions
```

## Custom Slack Notifications (Apex)

### Send Message via Slack API

```apex
public class SlackNotifier {
    private static final String SLACK_WEBHOOK = 'callout:Slack_Webhook';

    @InvocableMethod(label='Send Slack Message' description='Posts a message to Slack')
    public static void sendMessage(List<SlackRequest> requests) {
        for (SlackRequest req : requests) {
            postToSlack(req.channel, req.message, req.blocks);
        }
    }

    @future(callout=true)
    private static void postToSlack(String channel, String text, String blocksJson) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SLACK_WEBHOOK);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>{
            'channel' => channel,
            'text' => text
        };
        if (String.isNotBlank(blocksJson)) {
            payload.put('blocks', JSON.deserializeUntyped(blocksJson));
        }
        req.setBody(JSON.serialize(payload));
        new Http().send(req);
    }

    public class SlackRequest {
        @InvocableVariable(required=true) public String channel;
        @InvocableVariable(required=true) public String message;
        @InvocableVariable public String blocks;
    }
}
```

## Block Kit Message Formatting

### Rich Notification

```json
{
    "blocks": [
        {
            "type": "header",
            "text": { "type": "plain_text", "text": "New Opportunity Won!" }
        },
        {
            "type": "section",
            "fields": [
                { "type": "mrkdwn", "text": "*Account:*\nAcme Corp" },
                { "type": "mrkdwn", "text": "*Amount:*\n$150,000" },
                { "type": "mrkdwn", "text": "*Owner:*\nJohn Smith" },
                { "type": "mrkdwn", "text": "*Close Date:*\nMarch 9, 2026" }
            ]
        },
        {
            "type": "actions",
            "elements": [
                {
                    "type": "button",
                    "text": { "type": "plain_text", "text": "View in Salesforce" },
                    "url": "https://myorg.lightning.force.com/lightning/r/Opportunity/006.../view",
                    "style": "primary"
                },
                {
                    "type": "button",
                    "text": { "type": "plain_text", "text": "Approve" },
                    "action_id": "approve_deal",
                    "style": "primary"
                }
            ]
        }
    ]
}
```

### Status Update

```json
{
    "blocks": [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":rotating_light: *Case Escalated*\n*Case #* 00001234\n*Subject:* System outage affecting 50+ users\n*Priority:* Critical"
            }
        },
        {
            "type": "context",
            "elements": [
                { "type": "mrkdwn", "text": "Assigned to <@U123456> | SLA: 1 hour" }
            ]
        }
    ]
}
```

## Flow-Based Slack Integration

```
Record-Triggered Flow (After Save)
├── Entry: Opportunity.StageName changed to 'Closed Won'
├── Get Records: Account details
├── Action: SlackNotifier.sendMessage
│   ├── channel: #sales-wins
│   └── message: "{!Account.Name} deal closed for {!$Record.Amount}"
└── Update Record: Slack_Notified__c = true
```

## Common Patterns

| Pattern | Implementation |
|---|---|
| Deal alerts | Flow → Slack webhook on Opp stage change |
| Case escalation | Flow → Slack when Case priority = Critical |
| Approval in Slack | Salesforce for Slack package + approval process |
| Daily digest | Scheduled Flow → aggregate → Slack webhook |
| Interactive actions | Slack app → Salesforce REST API |

## Cross-Skill References

- For Salesforce callout patterns: see **sf-integration**
- For Named Credentials (Slack API auth): see **sf-integration**
- For Flow automation: see **sf-flow**
- For Apex webhook code: see **sf-apex**
