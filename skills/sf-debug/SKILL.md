---
name: sf-debug
description: >
  Analyzes Salesforce debug logs, diagnoses governor limit violations,
  and identifies performance bottlenecks. Use when investigating errors,
  analyzing debug logs, fixing SOQL-in-loop issues, CPU time violations,
  heap size errors, or mixed DML exceptions. Do NOT use for writing new
  Apex logic (use sf-apex) or running tests (use sf-testing).
---

# Salesforce Debug & Troubleshooting

## Core Responsibilities

1. Analyze debug logs for errors and performance issues
2. Diagnose governor limit violations (SOQL limits, CPU time, heap)
3. Identify and fix common runtime exceptions
4. Set up and manage trace flags
5. Recommend performance optimizations

## Workflow

### Phase 1 — Capture

Set up trace flags and capture logs:

```bash
# Set trace flag for current user (30 min)
sf apex tail log --target-org <alias>

# Get list of recent logs
sf apex list log --target-org <alias>

# Download specific log
sf apex get log --log-id <logId> --target-org <alias>
```

### Phase 2 — Analyze

Look for these patterns in order:
1. **FATAL_ERROR** lines — the root cause
2. **LIMIT_USAGE_FOR_NS** — governor limit consumption
3. **DML_BEGIN/DML_END** inside **LOOP** — DML in loop
4. **SOQL_EXECUTE_BEGIN** count > 100 — too many queries
5. **CUMULATIVE_LIMIT_USAGE** at end — overall consumption

### Phase 3 — Fix

Apply targeted fixes based on the diagnosis:

## Common Exceptions & Fixes

| Exception | Root Cause | Fix |
|---|---|---|
| `System.LimitException: Too many SOQL queries: 101` | SOQL inside for-loop | Move query before loop, use Map for lookups |
| `System.LimitException: Apex CPU time limit exceeded` | Complex logic or large loops | Optimize algorithms, reduce loop iterations, use batch |
| `System.LimitException: Apex heap size too large` | Large data structures in memory | Process in smaller chunks, remove unnecessary variables |
| `System.DmlException: MIXED_DML_OPERATION` | Setup + non-setup DML in same transaction | Use `System.runAs()` or separate into @future |
| `System.NullPointerException` | Accessing field on null reference | Add null checks before accessing fields |
| `System.QueryException: List has no rows` | `.get(0)` or assignment from empty query | Use `List<>` return type, check `isEmpty()` |
| `System.DmlException: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY` | Trigger/flow error on related DML | Check trigger handler and flow entry criteria |
| `System.CalloutException: Callout from triggers not supported` | HTTP callout in trigger context | Use `@future(callout=true)` or Queueable |

## Governor Limit Diagnosis

When analyzing `CUMULATIVE_LIMIT_USAGE`:

```
Number of SOQL queries: 95 out of 100     ← WARNING: near limit
Number of DML statements: 148 out of 150  ← CRITICAL: near limit
Maximum CPU time: 8500 out of 10000       ← WARNING: 85% consumed
Maximum heap size: 4500000 out of 6000000 ← OK: 75%
```

### Priority thresholds:
- **> 90%** of any limit → CRITICAL — will fail at scale
- **> 70%** of any limit → WARNING — refactor recommended
- **< 50%** of all limits → HEALTHY

## Debug Log Levels

| Category | Level for Debugging | Level for Production |
|---|---|---|
| Apex_code | FINEST | ERROR |
| Apex_profiling | FINE | NONE |
| Database | FINE | ERROR |
| System | DEBUG | ERROR |
| Validation | INFO | ERROR |
| Workflow | FINE | ERROR |
| Callout | FINE | ERROR |

## Performance Optimization Checklist

1. **SOQL**: Move queries outside loops, use selective filters, add LIMIT
2. **DML**: Collect records in lists, single DML operation after loop
3. **CPU**: Reduce nested loops, use Maps instead of nested queries
4. **Heap**: Process in batches, null out large variables after use
5. **Callouts**: Use Queueable for chaining, batch for bulk callouts

## Cross-Skill References

- For fixing Apex code issues: see **sf-apex**
- For re-running tests after fixes: see **sf-testing**
- For query optimization: see **sf-soql**
