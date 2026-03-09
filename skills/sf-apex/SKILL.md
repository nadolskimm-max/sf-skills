---
name: sf-apex
description: >
  Generates and reviews Salesforce Apex code following best practices.
  Use when writing, reviewing, or fixing Apex classes, triggers, batch jobs,
  or queueable/schedulable Apex. Covers Trigger Actions Framework, bulk
  patterns, governor limits, error handling, and test generation.
  Do NOT use for LWC JavaScript (use sf-lwc), Flow XML (use sf-flow),
  or raw SOQL files (use sf-soql).
---

# Salesforce Apex Development

## Core Responsibilities

1. Generate Apex classes, triggers, batch/queueable/schedulable jobs
2. Apply Trigger Actions Framework (TAF) patterns for trigger logic
3. Enforce bulkification and governor limit compliance
4. Generate test classes targeting 90%+ code coverage
5. Review existing Apex for anti-patterns and security issues

## Workflow

### Phase 1 — Understand

- Identify the object(s), operation(s), and business rules
- Check if a trigger already exists on the object (one trigger per object rule)
- Determine if TAF is installed (`TriggerAction` custom metadata exists)

### Phase 2 — Generate

- Follow patterns from [references/patterns.md](references/patterns.md)
- Use TAF handler classes for trigger logic, never inline trigger code
- All DML/SOQL must be bulkified (operate on collections, never single records)
- Use `System.assert*` methods with meaningful messages in tests

### Phase 3 — Validate

Run Salesforce CLI commands to check the code:

```bash
sf project deploy start --source-dir force-app --dry-run --target-org <alias>
```

For Code Analyzer (if installed):

```bash
sf scanner run --target force-app/main/default/classes/MyClass.cls --format table
```

### Phase 4 — Test

```bash
sf apex run test --class-names MyClassTest --result-format human --code-coverage --target-org <alias>
```

## Anti-Patterns to Catch

| Anti-Pattern | Fix |
|---|---|
| SOQL inside for-loop | Extract query before loop, use Map for lookups |
| DML inside for-loop | Collect records in List, single DML after loop |
| Hardcoded IDs | Use Custom Metadata, Custom Labels, or queries |
| No null checks | Always check for null before accessing fields |
| `@isTest` without `@TestSetup` | Use `@TestSetup` for shared test data |
| Trigger with logic | Move logic to TAF handler class |
| `System.debug` in production | Remove or guard with LoggingLevel |

## Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Trigger | `{Object}Trigger` | `AccountTrigger` |
| TAF Handler | `TA_{Object}{Operation}{Order}` | `TA_AccountBeforeInsert1` |
| Service class | `{Object}Service` | `AccountService` |
| Selector class | `{Object}Selector` | `AccountSelector` |
| Test class | `{ClassName}Test` | `AccountServiceTest` |
| Batch | `{Purpose}Batch` | `LeadCleanupBatch` |
| Queueable | `{Purpose}Queueable` | `AccountSyncQueueable` |
| Schedulable | `{Purpose}Scheduler` | `DailyCleanupScheduler` |

## Cross-Skill References

- For SOQL inside Apex: see **sf-soql** for query optimization
- For LWC controllers (`@AuraEnabled`): see **sf-lwc**
- For test patterns: see **sf-testing**
- For deployment: see **sf-deploy**
- For detailed patterns and templates: see [references/patterns.md](references/patterns.md)
