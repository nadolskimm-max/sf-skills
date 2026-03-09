---
name: sf-automation-strategy
description: >
  Guides architectural decisions on which Salesforce automation tool to
  use: Flow vs Apex vs Scheduled vs Platform Events. Use when deciding
  between automation approaches, migrating from Process Builder/Workflow
  Rules, planning automation architecture, or resolving order-of-execution
  conflicts. Do NOT use for building specific automations (use sf-flow,
  sf-apex, sf-async-patterns).
---

# Automation Strategy

## Core Responsibilities

1. Choose the right automation tool for each use case
2. Migrate from deprecated tools (Process Builder, Workflow Rules)
3. Design automation architecture to avoid conflicts
4. Manage order of execution across automations
5. Prevent recursion and infinite loops

## Automation Tool Selection

| Criteria | Flow (Before-Save) | Flow (After-Save) | Apex Trigger | Scheduled Flow | Queueable/Batch |
|---|---|---|---|---|---|
| Update same record | Best | Possible | Yes | N/A | N/A |
| Create related records | No | Yes | Yes | Yes | Yes |
| Complex logic | Limited | Moderate | Full | Moderate | Full |
| Callouts | No | No | No (use async) | No | Yes |
| Bulk safe | Auto | Need care | Manual | Auto | Auto |
| Admin maintainable | Yes | Yes | No (developer) | Yes | No |
| Test coverage needed | No | No | Yes (75%+) | No | Yes |
| Transaction control | Same txn | Same txn | Same txn | Own txn | Own txn |

## Decision Flowchart

```
Is it a simple field update on the triggering record?
├── YES → Before-Save Flow (fastest, no DML cost)
└── NO
    Does it need to create/update related records?
    ├── YES → After-Save Flow (declarative) or Apex Trigger (complex)
    └── NO
        Does it need callouts?
        ├── YES → Queueable Apex or Platform Event → subscriber
        └── NO
            Does it need to run on a schedule?
            ├── YES → Scheduled Flow or Schedulable Apex
            └── NO
                Is the logic very complex (50+ decision paths)?
                ├── YES → Apex Trigger + Service class
                └── NO → After-Save Flow
```

## Deprecated Tools — Migration Guide

| Deprecated Tool | Migrate To | Notes |
|---|---|---|
| **Workflow Rules** | Record-Triggered Flow | 1:1 replacement, use before-save for field updates |
| **Process Builder** | Record-Triggered Flow | Flows are more performant, better error handling |
| **@future methods** | Queueable Apex | Queueable supports chaining, complex types |

### Process Builder → Flow Migration

```
For each Process Builder:
1. Document all criteria nodes and actions
2. Create Record-Triggered Flow on same object
3. Replicate entry criteria → Flow entry conditions
4. Replicate Immediate Actions:
   - Field Update → Assignment element (before-save) or Update Records (after-save)
   - Email Alert → Send Email action
   - Create Record → Create Records element
   - Apex → Action element (Invocable Apex)
5. Replicate Scheduled Actions → Scheduled Path in Flow
6. Test with bulk records (200+)
7. Deactivate Process Builder, activate Flow
```

## Order of Execution

```
1. System validation rules (required fields, field types)
2. Before-save Flows
3. Before triggers (Apex)
4. Custom validation rules
5. After triggers (Apex)
6. Assignment rules
7. Auto-response rules
8. After-save Flows
9. Entitlement rules
10. Roll-up summary calculations
11. Cross-object workflow/process
12. Post-commit logic (email, async)
```

## Recursion Prevention

### In Apex

```apex
public class RecursionGuard {
    private static Set<Id> processedIds = new Set<Id>();

    public static Boolean isFirstRun(Id recordId) {
        if (processedIds.contains(recordId)) {
            return false;
        }
        processedIds.add(recordId);
        return true;
    }

    public static void reset() {
        processedIds.clear();
    }
}
```

### In Flow

- Set entry conditions to prevent re-entry (e.g., only when specific field changes)
- Use a checkbox field as "processing flag"
- Enable "Only when a record is updated to meet the condition requirements"

## One Automation Per Object Rule

Recommended pattern:
- **One trigger** per object → delegates to handler classes (TAF)
- **One record-triggered flow** per object per timing (before-save, after-save)
- Avoid mixing Flow + Apex trigger on same object/timing when possible

## Cross-Skill References

- For Flow development: see **sf-flow**
- For Apex triggers: see **sf-apex**
- For async patterns: see **sf-async-patterns**
- For Process Builder migration: see **sf-flow**
