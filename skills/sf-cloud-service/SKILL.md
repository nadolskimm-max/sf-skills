---
name: sf-cloud-service
description: >
  Builds Service Cloud features including Cases, Omni-Channel routing,
  Knowledge articles, Entitlements, Milestones, and Messaging. Use when
  configuring case management, setting up Omni-Channel, creating Knowledge
  articles, or building service console components. Do NOT use for
  general Apex (use sf-apex) or Experience Cloud portals (use sf-experience-cloud).
---

# Service Cloud

## Core Responsibilities

1. Configure Case management (assignment rules, escalation rules, queues)
2. Set up Omni-Channel routing and agent capacity
3. Create Knowledge article metadata and templates
4. Configure Entitlements and Milestones for SLA tracking
5. Build service console LWC components

## Case Management

### Case Assignment Rule

```xml
<?xml version="1.0" encoding="UTF-8"?>
<AssignmentRules xmlns="http://soap.sforce.com/2006/04/metadata">
    <assignmentRule>
        <fullName>Standard_Case_Assignment</fullName>
        <active>true</active>
        <ruleEntry>
            <assignedTo>Tier1_Support</assignedTo>
            <assignedToType>Queue</assignedToType>
            <criteriaItems>
                <field>Case.Priority</field>
                <operation>equals</operation>
                <value>Low,Medium</value>
            </criteriaItems>
        </ruleEntry>
        <ruleEntry>
            <assignedTo>Tier2_Support</assignedTo>
            <assignedToType>Queue</assignedToType>
            <criteriaItems>
                <field>Case.Priority</field>
                <operation>equals</operation>
                <value>High,Critical</value>
            </criteriaItems>
        </ruleEntry>
    </assignmentRule>
</AssignmentRules>
```

### Case Escalation Rule

```xml
<?xml version="1.0" encoding="UTF-8"?>
<EscalationRules xmlns="http://soap.sforce.com/2006/04/metadata">
    <escalationRule>
        <fullName>Escalate_Critical_Cases</fullName>
        <active>true</active>
        <ruleEntry>
            <criteriaItems>
                <field>Case.Priority</field>
                <operation>equals</operation>
                <value>Critical</value>
            </criteriaItems>
            <escalationAction>
                <assignedTo>support-manager@example.com</assignedTo>
                <minutesToEscalation>60</minutesToEscalation>
                <notifyTo>support-manager@example.com</notifyTo>
            </escalationAction>
        </ruleEntry>
    </escalationRule>
</EscalationRules>
```

## Omni-Channel

### Key Concepts

| Concept | Description |
|---|---|
| Service Channel | Defines which object types route through Omni-Channel |
| Routing Configuration | Rules for how work is assigned (Queue vs Skill) |
| Presence Configuration | Controls agent capacity and statuses |
| Agent Work | A unit of work assigned to an agent |

### Routing Strategies

| Strategy | Description |
|---|---|
| Queue-Based | Routes to agents who are members of the queue |
| Skill-Based | Matches agent skills to work item requirements |
| External Routing | Custom routing via API (Einstein, custom logic) |

## Knowledge

### Article Type

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>FAQ</label>
    <pluralLabel>FAQs</pluralLabel>
    <deploymentStatus>Deployed</deploymentStatus>
    <fields>
        <fullName>Question__c</fullName>
        <label>Question</label>
        <type>TextArea</type>
        <required>true</required>
    </fields>
    <fields>
        <fullName>Answer__c</fullName>
        <label>Answer</label>
        <type>Html</type>
    </fields>
</CustomObject>
```

### Query Knowledge Articles

```sql
SELECT Id, Title, Summary, ArticleNumber,
       KnowledgeArticleId, PublishStatus, VersionNumber
FROM Knowledge__kav
WHERE PublishStatus = 'Online'
  AND Language = 'en_US'
ORDER BY LastModifiedDate DESC
```

## Entitlements & Milestones

| Component | Purpose |
|---|---|
| Entitlement Process | SLA template (defines milestones) |
| Milestone | Individual SLA target (First Response, Resolution) |
| Entitlement | Assigns a process to an Account/Contact/Asset |

### Common Milestones

| Milestone | Typical SLA |
|---|---|
| First Response | 1 hour (Critical), 4 hours (High), 8 hours (Medium) |
| Resolution | 4 hours (Critical), 24 hours (High), 72 hours (Medium) |
| Customer Update | Every 2 hours (Critical), daily (High) |

## Cross-Skill References

- For case automation flows: see **sf-flow**
- For service console LWC: see **sf-lwc**
- For email-to-case: see **sf-email**
- For agent bots: see **sf-ai-agentforce**
