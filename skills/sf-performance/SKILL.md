---
name: sf-performance
description: >
  Optimizes Salesforce platform performance across Apex, SOQL, LWC,
  Flows, and UI. Use when diagnosing slow pages, optimizing Apex
  execution, reducing SOQL query time, improving LWC rendering, or
  tuning Flow performance. Do NOT use for debugging specific errors
  (use sf-debug) or writing new code (use respective skills).
---

# Salesforce Performance Optimization

## Core Responsibilities

1. Diagnose and fix Apex performance bottlenecks
2. Optimize SOQL query selectivity and execution time
3. Improve LWC rendering and data loading performance
4. Tune Flow execution for bulk operations
5. Optimize page load times and Lightning Experience UI

## Performance Diagnosis

### Step 1 — Identify the Bottleneck

| Symptom | Likely Area | Tool |
|---|---|---|
| Page loads slowly | LWC / Apex / SOQL | Chrome DevTools, Debug Log |
| "CPU time limit" error | Apex | Debug Log (CUMULATIVE_LIMIT_USAGE) |
| "Too many SOQL queries" | Apex / Flow | Debug Log (SOQL_EXECUTE_BEGIN count) |
| Slow report loading | SOQL / Indexing | Report performance settings |
| Batch job timeout | Apex Batch | Reduce scope size, optimize query |
| Flow interview timeout | Flow | Check for loops with DML |

### Step 2 — Measure

```bash
# Capture debug log
sf apex tail log --target-org <alias> --debug-level FINEST

# Run specific test with timing
sf apex run test --class-names MyServiceTest --result-format human --target-org <alias>
```

## Apex Optimization

### CPU Time Reduction

| Technique | Savings |
|---|---|
| Replace nested loops with Map lookups | 10-100x |
| Use `Set.contains()` instead of list iteration | 10-50x |
| Move calculations outside loops | 2-10x |
| Use `Database.query` with bind vars (not dynamic concat) | 2-5x |
| Cache repeated method calls in local variable | 2-5x |

### Example: Map Lookup vs Nested Loop

```apex
// SLOW: O(n*m) — nested loop
for (Contact c : contacts) {
    for (Account a : accounts) {
        if (c.AccountId == a.Id) {
            c.Description = a.Name;
        }
    }
}

// FAST: O(n+m) — Map lookup
Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
for (Contact c : contacts) {
    Account a = accountMap.get(c.AccountId);
    if (a != null) {
        c.Description = a.Name;
    }
}
```

### Heap Size Reduction

- Process large collections in chunks
- Set large variables to `null` after use
- Use `Database.QueryLocator` instead of `List<SObject>` in batch
- Avoid storing entire query results when only IDs are needed

## SOQL Optimization

### Selectivity Checklist

1. Use indexed fields in WHERE clause (Id, Name, lookups, custom indexes)
2. Avoid leading wildcards (`LIKE '%value'`)
3. Avoid negation operators on large tables
4. Add LIMIT for exploratory queries
5. Use `FOR UPDATE` only when necessary

### Query Plan Analysis

```bash
sf data query --query "EXPLAIN SELECT Id FROM Account WHERE Industry = 'Technology'" --target-org <alias> --use-tooling-api
```

Key metrics:
- **relativeCost < 1.0** = selective (good)
- **leadingOperationType = Index** = using index (good)
- **leadingOperationType = TableScan** = full scan (bad)

## LWC Performance

| Technique | Impact |
|---|---|
| Use `@wire` with `cacheable=true` | Eliminates redundant server calls |
| Implement pagination (not load-all) | Reduces initial payload |
| Use `lightning-datatable` for large lists | Built-in virtualization |
| Lazy-load child components | Faster initial render |
| Debounce search inputs | Fewer server round-trips |
| Avoid reactive loops (tracked prop → handler → tracked prop) | Prevents infinite re-renders |

### Debounce Pattern

```javascript
handleSearch(event) {
    window.clearTimeout(this._searchTimeout);
    this._searchTimeout = setTimeout(() => {
        this.searchTerm = event.target.value;
    }, 300);
}
```

## Flow Performance

| Technique | Impact |
|---|---|
| Use before-save for same-record updates | No DML count |
| Bulkify: move Get/DML outside loops | 10-100x fewer operations |
| Add entry criteria to skip unnecessary runs | Avoids wasted processing |
| Use Fast Field Updates (before-save) | Faster than after-save |
| Minimize formula calculations in flows | Reduce CPU time |

## Lightning Page Optimization

| Technique | Impact |
|---|---|
| Reduce components per page | Fewer parallel data loads |
| Use conditional visibility | Load components only when needed |
| Minimize custom Apex in components | Fewer server round-trips |
| Cache static data in LWC | Avoid repeated queries |

## Cross-Skill References

- For Apex optimization details: see **sf-apex**
- For SOQL query tuning: see **sf-soql**
- For LWC patterns: see **sf-lwc**
- For debug log analysis: see **sf-debug**
- For Flow optimization: see **sf-flow**
