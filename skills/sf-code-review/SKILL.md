---
name: sf-code-review
description: >
  Reviews Salesforce code (Apex, LWC, Flows) against best practices
  with a structured scoring rubric. Use when performing code reviews,
  generating review checklists, scoring code quality, or creating PR
  templates for Salesforce projects. Do NOT use for writing new code
  (use sf-apex, sf-lwc, sf-flow) or debugging (use sf-debug).
---

# Salesforce Code Review

## Core Responsibilities

1. Review Apex classes and triggers against quality rubric
2. Review LWC components for patterns and accessibility
3. Review Flows for bulk safety and error handling
4. Generate structured review feedback with severity levels
5. Provide actionable fix suggestions

## Review Process

### Phase 1 — Security

| Check | Severity | Details |
|---|---|---|
| `with sharing` enforced | Critical | All classes accessing data must use `with sharing` |
| FLS/CRUD checks | Critical | `stripInaccessible` or `WITH SECURITY_ENFORCED` |
| No hardcoded credentials | Critical | Check for API keys, passwords, tokens |
| No SOQL injection | Critical | Bind variables or `escapeSingleQuotes` |
| No sensitive data in logs | High | No PII/PHI in `System.debug` |

### Phase 2 — Bulkification

| Check | Severity | Details |
|---|---|---|
| No SOQL in loops | Critical | Query before loop, use Map lookups |
| No DML in loops | Critical | Collect in List, single DML after loop |
| No callouts in loops | Critical | Use Queueable chaining |
| Collection-based processing | High | All trigger logic handles 200+ records |
| Governor limit awareness | High | Check `Limits` class usage |

### Phase 3 — Architecture

| Check | Severity | Details |
|---|---|---|
| One trigger per object | High | Delegate to handler classes |
| Separation of concerns | Medium | Service, Selector, Domain layers |
| No business logic in triggers | High | Use TAF handlers or service classes |
| Reusable methods | Medium | No duplicated logic across classes |
| Appropriate async pattern | Medium | Batch for large data, Queueable for chaining |

### Phase 4 — Testing

| Check | Severity | Details |
|---|---|---|
| Test coverage >= 90% | High | Per class, not just overall |
| Bulk test (200+ records) | High | For all trigger-related tests |
| Positive + negative cases | Medium | Test both success and failure paths |
| Meaningful assertions | Medium | Not just `System.assert(true)` |
| No `SeeAllData=true` | High | Create test data in `@TestSetup` |
| Mock callouts | Medium | Use `HttpCalloutMock` interface |

### Phase 5 — Clean Code

| Check | Severity | Details |
|---|---|---|
| Consistent naming | Low | PascalCase classes, camelCase methods |
| No magic numbers | Low | Use constants or Custom Labels |
| Method length < 50 lines | Low | Extract sub-methods for clarity |
| No commented-out code | Low | Delete unused code, use version control |
| Appropriate access modifiers | Low | `private` by default, `public` only when needed |

## Feedback Format

```markdown
## Code Review: AccountService.cls

### Critical
- **L42**: SOQL inside for-loop. Move query to line 38, use Map<Id, Account> for lookups.
- **L67**: Missing FLS check before DML. Add `Security.stripInaccessible(AccessType.CREATABLE, records)`.

### High
- **L15**: Class uses `without sharing`. Document business justification or change to `with sharing`.

### Suggestions
- **L30**: Consider extracting account validation to separate `AccountValidator` class.
- **L55**: This method is 80 lines. Break into smaller methods for readability.

### Positives
- Good use of `@TestSetup` for shared test data.
- Proper bulk handling in trigger handler.
```

## LWC Review Checklist

- [ ] Uses `lwc:if` (not deprecated `if:true`)
- [ ] `key` attribute on all `for:each` loops
- [ ] Error handling for all wire/imperative calls
- [ ] No direct DOM manipulation
- [ ] SLDS classes for styling
- [ ] `aria-label` on interactive elements
- [ ] No `@track` on primitives

## Flow Review Checklist

- [ ] No DML/SOQL inside loop elements
- [ ] Fault connectors on all DML/query elements
- [ ] Entry criteria prevent unnecessary executions
- [ ] Before-save used for same-record field updates
- [ ] All elements have descriptions
- [ ] Variables follow naming conventions

## Cross-Skill References

- For Apex patterns: see **sf-apex**
- For LWC patterns: see **sf-lwc**
- For Flow patterns: see **sf-flow**
- For security review: see **sf-security**
