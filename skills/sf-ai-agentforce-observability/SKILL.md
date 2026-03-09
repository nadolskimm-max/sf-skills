---
name: sf-ai-agentforce-observability
description: >
  Traces and analyzes Agentforce agent sessions using Data Cloud and
  platform logs. Use when investigating agent behavior in production,
  extracting session transcripts, analyzing topic routing accuracy,
  or monitoring agent performance metrics. Do NOT use for agent
  configuration (use sf-ai-agentforce) or pre-deployment testing
  (use sf-ai-agentforce-testing).
---

# Agentforce Observability

## Core Responsibilities

1. Extract agent session data from Data Cloud
2. Analyze conversation transcripts for quality
3. Monitor topic routing accuracy
4. Track action success/failure rates
5. Identify patterns in escalations and failures

## Session Data Sources

| Source | Data Available | Access Method |
|---|---|---|
| Data Cloud | Full session transcripts, action logs | SOQL on Data Cloud objects |
| Event Logs | Agent API calls, latency | EventLogFile queries |
| Debug Logs | Apex action execution details | `sf apex tail log` |
| Setup Audit Trail | Configuration changes | Setup UI or API |

## Extracting Session Data

### Query Agent Sessions (Data Cloud)

```sql
SELECT
    SessionId,
    StartTime,
    EndTime,
    AgentName,
    TopicName,
    UserMessage,
    AgentResponse,
    ActionInvoked,
    ActionStatus
FROM AgentSession__dll
WHERE StartTime >= LAST_N_DAYS:7
ORDER BY StartTime DESC
LIMIT 100
```

### Query Action Performance

```sql
SELECT
    ActionName,
    COUNT(Id) AS InvocationCount,
    AVG(DurationMs) AS AvgDuration,
    SUM(CASE WHEN Status = 'Error' THEN 1 ELSE 0 END) AS ErrorCount
FROM AgentActionLog__dll
WHERE CreatedDate >= LAST_N_DAYS:30
GROUP BY ActionName
ORDER BY InvocationCount DESC
```

### Query Escalation Patterns

```sql
SELECT
    EscalationReason,
    TopicName,
    COUNT(Id) AS EscalationCount
FROM AgentEscalation__dll
WHERE CreatedDate >= LAST_N_DAYS:30
GROUP BY EscalationReason, TopicName
ORDER BY EscalationCount DESC
```

## Analysis Workflow

### Phase 1 — Collect

Gather session data for the analysis period:

```bash
# Export recent sessions
sf data query --query "SELECT SessionId, AgentResponse, ActionInvoked FROM AgentSession__dll WHERE StartTime >= LAST_N_DAYS:7" --result-format csv --target-org <alias> > sessions.csv
```

### Phase 2 — Analyze

Key metrics to evaluate:

| Metric | Target | Formula |
|---|---|---|
| Resolution Rate | > 80% | Sessions resolved / Total sessions |
| Escalation Rate | < 20% | Escalated sessions / Total sessions |
| Avg Actions per Session | 2-5 | Total actions / Total sessions |
| Topic Routing Accuracy | > 90% | Correctly routed / Total routed |
| Action Error Rate | < 5% | Failed actions / Total actions |
| Avg Response Time | < 3s | Total response time / Total responses |

### Phase 3 — Diagnose

Common issues and indicators:

| Symptom | Likely Cause | Investigation |
|---|---|---|
| High escalation rate | Missing topic or action | Check unresolved query patterns |
| Frequent action errors | Apex/Flow bugs | Review debug logs for action failures |
| Wrong topic routing | Overlapping topic descriptions | Compare topic keywords for overlap |
| Slow responses | Heavy Apex operations | Check CPU time in debug logs |
| Repeated questions | Agent not understanding context | Review session transcripts |

### Phase 4 — Recommend

Generate improvement recommendations:
- Add missing actions for common unresolved queries
- Refine topic descriptions to reduce misrouting
- Optimize slow Apex actions
- Update persona for tone issues

## Alerting Thresholds

| Metric | Warning | Critical |
|---|---|---|
| Error Rate | > 5% | > 15% |
| Escalation Rate | > 25% | > 40% |
| Avg Response Time | > 5s | > 10s |
| Unresolved Sessions | > 20% | > 35% |

## Cross-Skill References

- For fixing agent configuration: see **sf-ai-agentforce**
- For updating persona after analysis: see **sf-ai-agentforce-persona**
- For creating regression tests: see **sf-ai-agentforce-testing**
- For debugging Apex actions: see **sf-debug**
