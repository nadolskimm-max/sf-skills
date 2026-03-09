---
name: sf-event-monitoring
description: >
  Configures and analyzes Salesforce Event Monitoring including login
  history, EventLogFiles, real-time events, and Shield Event Monitoring.
  Use when investigating security events, analyzing user login patterns,
  monitoring API usage, setting up transaction security policies, or
  building audit compliance reports. Do NOT use for debug logs
  (use sf-debug) or general reporting (use sf-reporting).
---

# Event Monitoring

## Core Responsibilities

1. Query and analyze EventLogFiles (ELF)
2. Monitor login events and session management
3. Configure Transaction Security policies
4. Set up real-time event streaming
5. Build compliance and audit reports

## EventLogFile Types

| Event Type | Description | Use Case |
|---|---|---|
| `Login` | User login attempts | Failed login detection |
| `Logout` | User logouts | Session analysis |
| `API` | API calls | Usage monitoring |
| `ApexExecution` | Apex class execution | Performance analysis |
| `ApexTrigger` | Trigger execution | Trigger performance |
| `Report` | Report execution | Report usage audit |
| `ReportExport` | Report export events | Data exfiltration detection |
| `URI` | Page view events | UI usage patterns |
| `LightningPageView` | Lightning page views | Lightning adoption |
| `ApiTotalUsage` | API limits tracking | Limit management |
| `BulkApi` | Bulk API operations | Data load monitoring |
| `ContentDistribution` | File sharing | Document access audit |

## Querying EventLogFiles

### Basic ELF Query

```sql
SELECT Id, EventType, LogDate, LogFileLength, LogFile
FROM EventLogFile
WHERE EventType = 'Login'
  AND LogDate >= LAST_N_DAYS:7
ORDER BY LogDate DESC
```

### Download Log File

```bash
# List available log files
sf data query --query "SELECT Id, EventType, LogDate FROM EventLogFile WHERE LogDate = TODAY" --target-org <alias>

# Download specific log
sf data get record --sobject EventLogFile --record-id <logId> --target-org <alias>
```

### Analyze Login Events

```sql
-- Failed logins in last 7 days
SELECT Id, EventType, LogDate
FROM EventLogFile
WHERE EventType = 'Login'
  AND LogDate >= LAST_N_DAYS:7

-- After downloading CSV, look for:
-- LOGIN_STATUS != 'LOGIN_NO_ERROR'
-- CLIENT_IP for suspicious locations
-- BROWSER_TYPE for unusual user agents
```

## Real-Time Events (Shield)

### Event Types

| Event | Description |
|---|---|
| `LoginEvent` | Real-time login stream |
| `LogoutEvent` | Real-time logout stream |
| `ApiEvent` | API usage in real-time |
| `ReportEvent` | Report access in real-time |
| `ListViewEvent` | List view access |
| `SessionHijackingEvent` | Potential session hijack |
| `CredentialStuffingEvent` | Brute force login attempts |

### Subscribe via Apex Trigger

```apex
trigger LoginEventTrigger on LoginEvent (after insert) {
    List<Security_Alert__c> alerts = new List<Security_Alert__c>();
    for (LoginEvent event : Trigger.new) {
        if (event.LoginType == 'Remote Access 2.0' &&
            event.Status != 'Success') {
            alerts.add(new Security_Alert__c(
                Event_Type__c = 'Failed API Login',
                User__c = event.UserId,
                IP_Address__c = event.SourceIp,
                Details__c = 'Failed login from ' + event.City + ', ' + event.Country
            ));
        }
    }
    if (!alerts.isEmpty()) {
        insert alerts;
    }
}
```

## Transaction Security Policies

Automated responses to security events:

| Condition | Action |
|---|---|
| Login from blocked country | Block |
| Report export > 10k records | Require MFA |
| API calls > threshold | Notify admin |
| Session from new device | Notify user |
| Bulk data export | Require approval |

### Policy Setup

```bash
# Query existing policies
sf data query --query "SELECT Id, DeveloperName, State, EventType FROM TransactionSecurityPolicy" --target-org <alias> --use-tooling-api
```

## Compliance Audit Queries

```sql
-- Users who exported reports this month
SELECT Id, EventType, LogDate
FROM EventLogFile
WHERE EventType = 'ReportExport'
  AND LogDate = THIS_MONTH

-- API usage by integration user
SELECT Id, EventType, LogDate
FROM EventLogFile
WHERE EventType = 'API'
  AND LogDate >= LAST_N_DAYS:30

-- Login history for specific user
SELECT LoginTime, SourceIp, LoginType, Status, Browser, Platform
FROM LoginHistory
WHERE UserId = :userId
ORDER BY LoginTime DESC
LIMIT 100
```

## Prerequisites

| Feature | Required License |
|---|---|
| EventLogFile (24hr retention) | Included in Enterprise+ |
| EventLogFile (30-day retention) | Shield or Event Monitoring add-on |
| Real-Time Events | Shield Platform |
| Transaction Security | Shield Platform |
| Field Audit Trail | Shield Platform |

## Cross-Skill References

- For debug log analysis: see **sf-debug**
- For security configuration: see **sf-security**
- For compliance reports: see **sf-reporting**
- For Platform Event triggers: see **sf-integration**
