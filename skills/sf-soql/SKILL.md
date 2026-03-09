---
name: sf-soql
description: >
  Generates and optimizes SOQL queries for Salesforce. Use when writing
  SOQL queries, converting natural language to SOQL, optimizing query
  performance, debugging selective/non-selective queries, or working with
  relationship queries. Do NOT use for DML operations (use sf-data) or
  Apex logic beyond queries (use sf-apex).
---

# SOQL Query Development

## Core Responsibilities

1. Convert natural language requirements to SOQL
2. Optimize queries for selectivity and performance
3. Build relationship queries (parent-to-child, child-to-parent)
4. Analyze query plans and suggest index improvements
5. Ensure governor limit compliance (50k row limit, 100 queries)

## Workflow

### Phase 1 — Translate

Convert the request to SOQL:
- Identify the primary object and fields needed
- Determine filter criteria (WHERE clause)
- Add relationship traversals if needed
- Apply ORDER BY and LIMIT

### Phase 2 — Optimize

Check for selectivity:
- Indexed fields in WHERE clause (Id, Name, RecordTypeId, foreign keys, custom indexes)
- Avoid leading wildcards (`LIKE '%value'`) — non-selective
- Avoid negation operators (`!=`, `NOT IN`) on large datasets
- Use LIMIT to constrain result sets

### Phase 3 — Validate

```bash
# Execute query against org
sf data query --query "SELECT Id, Name FROM Account LIMIT 10" --target-org <alias>

# Check query plan (REST API)
sf data query --query "SELECT Id FROM Account WHERE Name = 'Acme'" --target-org <alias> --use-tooling-api
```

## Query Patterns

### Basic Query

```sql
SELECT Id, Name, Industry, Phone
FROM Account
WHERE Industry = 'Technology'
ORDER BY Name ASC
LIMIT 100
```

### Parent-to-Child (subquery)

```sql
SELECT Id, Name,
    (SELECT Id, FirstName, LastName, Email
     FROM Contacts
     WHERE Email != null
     ORDER BY LastName)
FROM Account
WHERE Industry = 'Technology'
```

### Child-to-Parent (dot notation)

```sql
SELECT Id, FirstName, LastName,
       Account.Name, Account.Industry
FROM Contact
WHERE Account.Industry = 'Technology'
```

### Aggregate Query

```sql
SELECT StageName, COUNT(Id) cnt, SUM(Amount) total
FROM Opportunity
WHERE CloseDate = THIS_FISCAL_YEAR
GROUP BY StageName
HAVING SUM(Amount) > 100000
ORDER BY SUM(Amount) DESC
```

### Semi-Join (records WITH related)

```sql
SELECT Id, Name FROM Account
WHERE Id IN (SELECT AccountId FROM Opportunity WHERE StageName = 'Closed Won')
```

### Anti-Join (records WITHOUT related)

```sql
SELECT Id, Name FROM Account
WHERE Id NOT IN (SELECT AccountId FROM Contact)
```

### Date Literals

| Literal | Meaning |
|---|---|
| `TODAY` | Current day |
| `YESTERDAY` | Previous day |
| `THIS_WEEK` | Current week |
| `LAST_N_DAYS:30` | Past 30 days |
| `THIS_FISCAL_YEAR` | Current fiscal year |
| `NEXT_N_MONTHS:3` | Next 3 months |

## Selectivity Rules

A query is selective when it returns less than:
- **10%** of total records for the first filter, OR
- **5%** of total records for subsequent filters (AND)

| Field Type | Indexed by Default |
|---|---|
| Id | Yes |
| Name | Yes |
| OwnerId | Yes |
| RecordTypeId | Yes |
| CreatedDate | Yes |
| SystemModstamp | Yes |
| Lookup/Master-Detail | Yes |
| External ID fields | Yes |
| Custom fields | No (request custom index) |

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| `SELECT *` equivalent (all fields) | Select only needed fields |
| `LIKE '%value%'` (leading wildcard) | Use `LIKE 'value%'` or SOSL |
| No LIMIT on exploratory queries | Always add LIMIT during development |
| No WHERE clause on large objects | Add selective filter criteria |
| `!=` on non-indexed field | Restructure as positive match |
| Query in Apex for-loop | Move query before loop, use Map |
| ORDER BY non-indexed field on large set | Add custom index or restructure |

## Cross-Skill References

- For SOQL inside Apex: see **sf-apex** for bulkification patterns
- For test data queries: see **sf-data**
- For query plan analysis via CLI: see **sf-deploy**
