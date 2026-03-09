---
name: sf-formula
description: >
  Creates Salesforce formula fields, validation rules, and formula-based
  automation. Use when writing formula field expressions, building
  validation rules, troubleshooting formula compilation errors, or
  optimizing formula performance (compiled size limits). Do NOT use for
  SOQL queries (use sf-soql) or Flow formulas (use sf-flow).
---

# Salesforce Formulas & Validation Rules

## Core Responsibilities

1. Create formula fields (text, number, checkbox, date)
2. Build validation rules with complex conditions
3. Troubleshoot formula compilation errors and size limits
4. Handle null values and cross-object references
5. Optimize formula performance

## Formula Field Types

| Return Type | Use Case | Example |
|---|---|---|
| Text | Concatenation, formatting | Full Name, formatted address |
| Number | Calculations | Discount amount, days open |
| Currency | Financial calculations | Weighted revenue |
| Percent | Ratios | Win rate, completion % |
| Checkbox | Boolean logic | Is High Value?, Is Overdue? |
| Date | Date calculations | Due Date, Next Review Date |
| DateTime | Timestamp calculations | SLA deadline |

## Common Formula Patterns

### Null-Safe Field Access

```
IF(ISBLANK(Amount), 0, Amount * Discount_Percent__c / 100)
```

### Cross-Object Reference

```
Account.Owner.Manager.Email
```

### Text Concatenation

```
IF(ISBLANK(MailingStreet), '',
    MailingStreet & BR() &
    MailingCity & ', ' & MailingState & ' ' & MailingPostalCode &
    BR() & MailingCountry
)
```

### Date Calculations

```
/* Days until close */
CLOSE_DATE - TODAY()

/* Business days between two dates (approximate) */
(CLOSE_DATE - CreatedDate) - (FLOOR((CLOSE_DATE - CreatedDate) / 7) * 2)

/* Next business day */
CASE(
    MOD(TODAY() - DATE(1900, 1, 7), 7),
    5, TODAY() + 3,
    6, TODAY() + 2,
    TODAY() + 1
)
```

### Conditional Logic

```
CASE(StageName,
    'Prospecting', 10,
    'Qualification', 25,
    'Proposal', 50,
    'Negotiation', 75,
    'Closed Won', 100,
    0
)
```

### Image Formula

```
IMAGE(
    CASE(Priority,
        'High', '/img/samples/flag_red.gif',
        'Medium', '/img/samples/flag_yellow.gif',
        '/img/samples/flag_green.gif'
    ),
    Priority, 16, 16
)
```

## Validation Rules

### Required Field Conditionally

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Require_Close_Date_When_Closed</fullName>
    <active>true</active>
    <errorConditionFormula>AND(
    ISPICKVAL(StageName, 'Closed Won'),
    ISBLANK(CloseDate)
)</errorConditionFormula>
    <errorDisplayField>CloseDate</errorDisplayField>
    <errorMessage>Close Date is required when Stage is Closed Won.</errorMessage>
</ValidationRule>
```

### Prevent Backdating

```
CloseDate < TODAY() && ISCHANGED(CloseDate)
```

### Email Format Validation

```
AND(
    NOT(ISBLANK(Email)),
    NOT(REGEX(Email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'))
)
```

### Cross-Object Validation

```
AND(
    ISPICKVAL(Status__c, 'Active'),
    Account.IsDeleted
)
```

## REGEX Patterns

| Pattern | Matches |
|---|---|
| `^[0-9]{5}(-[0-9]{4})?$` | US ZIP code (12345 or 12345-6789) |
| `^\\+?[1-9]\\d{1,14}$` | E.164 phone number |
| `^[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{7}([A-Z0-9]?){0,16}$` | IBAN |
| `^[0-9]{3}-[0-9]{2}-[0-9]{4}$` | US SSN format |

## Compiled Size Limits

| Limit | Maximum |
|---|---|
| Formula field compiled size | 5,000 characters |
| Validation rule formula size | 5,000 characters |
| Cross-object spans | Max 10 relationships |
| SOQL in formulas | Not allowed |

### Size Reduction Tips

- Replace `IF(condition, true, false)` with just `condition` for checkboxes
- Use `CASE` instead of nested `IF` (smaller compiled size)
- Move complex logic to Apex/Flow if approaching limits
- Avoid deep cross-object references (each span adds ~200 chars)

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| No null handling | Wrap in `IF(ISBLANK(...))` or `BLANKVALUE()` |
| Nested IF > 5 levels | Use `CASE` statement instead |
| Hardcoded picklist values | Use `ISPICKVAL()` for type safety |
| Formula field referencing formula field | Beware of compiled size cascade |
| Validation rule with no error message context | Point to specific field with `errorDisplayField` |

## Cross-Skill References

- For formula fields in metadata: see **sf-metadata**
- For Flow formula resources: see **sf-flow**
- For validation rule deployment: see **sf-deploy**
