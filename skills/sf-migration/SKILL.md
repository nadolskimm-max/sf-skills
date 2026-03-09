---
name: sf-migration
description: >
  Plans and executes Salesforce org migrations including metadata
  comparison, data migration strategies, and org-to-org transfers.
  Use when migrating between orgs, comparing metadata between environments,
  planning data migration, or converting from classic to Lightning.
  Do NOT use for regular deployment (use sf-deploy) or data import/export
  only (use sf-data).
---

# Salesforce Migration

## Core Responsibilities

1. Compare metadata between source and target orgs
2. Plan data migration strategies (order, dependencies, volumes)
3. Generate migration runbooks and checklists
4. Handle org-to-org metadata transfer
5. Validate post-migration integrity

## Migration Workflow

### Phase 1 — Discovery

```bash
# List all metadata types in org
sf org list metadata-types --target-org source-org

# Retrieve full metadata inventory
sf project retrieve start --target-org source-org

# Compare metadata between orgs
sf project retrieve start --target-org source-org --output-dir source-metadata
sf project retrieve start --target-org target-org --output-dir target-metadata
```

### Phase 2 — Plan

Build a migration plan covering:

**Metadata migration order:**
1. Custom Objects, Fields, Record Types
2. Profiles, Permission Sets, Roles
3. Validation Rules, Workflows, Flows
4. Apex Classes, Triggers
5. Lightning Components (LWC, Aura)
6. Reports, Dashboards
7. Connected Apps, Named Credentials

**Data migration order (respect dependencies):**
1. Reference/lookup target objects first (e.g., Account before Contact)
2. Junction objects last
3. Large-volume objects via Bulk API
4. Preserve record ownership if needed

### Phase 3 — Execute

```bash
# Deploy metadata to target
sf project deploy start --source-dir force-app --target-org target-org --test-level RunLocalTests

# Migrate data using Bulk API
sf data import bulk --sobject Account --file accounts.csv --target-org target-org
sf data import bulk --sobject Contact --file contacts.csv --target-org target-org

# Upsert with External ID for relationship mapping
sf data upsert bulk --sobject Contact --file contacts.csv --external-id Legacy_Id__c --target-org target-org
```

### Phase 4 — Validate

```bash
# Run all tests in target
sf apex run test --test-level RunLocalTests --result-format human --code-coverage --target-org target-org

# Compare record counts
sf data query --query "SELECT COUNT() FROM Account" --target-org source-org
sf data query --query "SELECT COUNT() FROM Account" --target-org target-org
```

## Data Migration Strategies

| Strategy | When to Use | Tool |
|---|---|---|
| Full Extract + Load | Small orgs (< 100k records) | CLI Bulk API |
| Incremental Sync | Ongoing sync between orgs | Change Data Capture |
| External ID Mapping | Preserving relationships | Upsert with External ID |
| ETL Tool | Complex transformations | MuleSoft, Informatica |
| Data Loader | Large volumes, scheduled | Salesforce Data Loader |

## Relationship Mapping

When migrating related records, IDs change between orgs. Use External IDs:

```apex
// Add External ID field to source objects before migration
// Source org: Account.Legacy_Id__c = Account.Id (18-char)
// Target org: Upsert using Legacy_Id__c to match

// For lookups in CSV:
// Contact.csv should reference Account.Legacy_Id__c, not Account.Id
```

### CSV with External ID References

```csv
FirstName,LastName,Email,Account.Legacy_Id__c
John,Doe,john@example.com,001xx000003ABCDE
Jane,Smith,jane@example.com,001xx000003ABCDF
```

## Migration Checklist

### Pre-Migration
- [ ] Full metadata inventory of source org
- [ ] Identify customizations vs standard config
- [ ] Map data dependencies (parent-child relationships)
- [ ] Add External ID fields on all migrated objects
- [ ] Estimate data volumes and plan batching
- [ ] Disable triggers/flows in target during load
- [ ] Backup target org metadata

### Post-Migration
- [ ] Run all Apex tests in target org
- [ ] Verify record counts match source
- [ ] Validate lookup relationships are intact
- [ ] Test critical business processes end-to-end
- [ ] Re-enable triggers/flows
- [ ] Verify reports and dashboards render correctly
- [ ] Check permission sets and user access

## Common Issues

| Issue | Fix |
|---|---|
| ID mismatch between orgs | Use External IDs for all references |
| Circular dependencies | Migrate in phases, nullable lookups first |
| Data volume timeout | Use Bulk API with smaller batch sizes |
| Trigger errors during load | Disable triggers, load data, re-enable |
| Missing metadata dependencies | Deploy dependencies first |

## Cross-Skill References

- For deployment mechanics: see **sf-deploy**
- For data operations: see **sf-data**
- For metadata generation: see **sf-metadata**
- For test validation: see **sf-testing**
