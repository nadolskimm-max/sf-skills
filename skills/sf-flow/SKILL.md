---
name: sf-flow
description: >
  Creates and reviews Salesforce Flows (Record-Triggered, Screen, Scheduled,
  Autolaunched, Platform Event-Triggered). Use when building or reviewing
  Flow XML, designing flow logic, handling bulk operations in flows, or
  troubleshooting flow errors. Do NOT use for Apex triggers (use sf-apex)
  or Process Builder (deprecated — migrate to Flow).
---

# Salesforce Flow Development

## Core Responsibilities

1. Generate Flow XML metadata for all flow types
2. Design screen flows with proper validation and navigation
3. Ensure bulk-safe patterns in record-triggered flows
4. Implement fault paths and error handling
5. Apply naming conventions and documentation standards

## Flow Types

| Type | Use Case | Entry Condition |
|---|---|---|
| Record-Triggered | Automate on record changes | Before/After Save, After Delete |
| Screen | User-facing forms and wizards | User clicks button/action |
| Scheduled | Time-based batch processing | Schedule or record-based time |
| Autolaunched | Backend automation (no UI) | Called from Apex, other flows |
| Platform Event-Triggered | Event-driven processing | Platform Event published |

## Workflow

### Phase 1 — Design

- Identify trigger conditions (object, when to run, entry criteria)
- Plan decision logic and data operations
- Determine if before-save (no DML needed) or after-save (related records)
- Identify fault handling requirements

### Phase 2 — Generate

Follow these rules:

**Before-Save Flows (preferred for field updates on the same record):**
- Runs before commit — no DML count
- Faster than after-save
- Cannot create/update related records
- Use `$Record` to modify the triggering record directly

**After-Save Flows:**
- Use for creating/updating related records
- Runs after DML commit
- Can trigger other automations (beware recursion)

### Phase 3 — Validate

```bash
sf project deploy start --source-dir force-app/main/default/flows --dry-run --target-org <alias>
```

## Naming Conventions

| Element | Pattern | Example |
|---|---|---|
| Flow API Name | `{Object}_{Trigger}_{Purpose}` | `Account_AfterSave_CreateTask` |
| Screen Flow | `Screen_{Purpose}` | `Screen_NewCustomerOnboarding` |
| Scheduled Flow | `Scheduled_{Purpose}` | `Scheduled_LeadCleanup` |
| Variables | `var{PurposePascalCase}` | `varAccountName` |
| Collections | `col{ObjectPlural}` | `colContacts` |
| Record variables | `rec{Object}` | `recAccount` |
| Constants | `con{Purpose}` | `conDefaultStatus` |
| Formulas | `fx{Purpose}` | `fxIsHighValue` |
| Decision | `dec{Question}` | `decIsNewCustomer` |
| Loop | `loop{Collection}` | `loopContacts` |
| Assignment | `assign{Purpose}` | `assignDefaultValues` |

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| DML inside a loop element | Collect in collection variable, single DML after loop |
| SOQL inside a loop element | Query before loop, use collection variable |
| No fault connector | Add fault path to every DML/query element |
| Hardcoded IDs in criteria | Use Custom Metadata or Custom Labels |
| After-save for same-record update | Use before-save flow instead |
| No entry criteria | Always add conditions to prevent unnecessary runs |
| Missing descriptions | Add description to every flow and element |

## Bulk-Safe Flow Pattern

```
[Entry Criteria] → [Get Records (before loop)] → [Loop]
    → [Assignment (add to collection)] → [End Loop]
    → [Update Records (collection)] → [Fault Path]
```

Key: All Get/Create/Update/Delete elements must be **outside** loops.

## Cross-Skill References

- For Apex invocable actions: see **sf-apex** (`@InvocableMethod`)
- For metadata deployment: see **sf-deploy**
- For testing flows: see **sf-testing**
