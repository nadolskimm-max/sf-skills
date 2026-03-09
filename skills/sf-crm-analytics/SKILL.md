---
name: sf-crm-analytics
description: >
  Builds CRM Analytics (formerly Tableau CRM / Einstein Analytics)
  dashboards, datasets, lenses, and SAQL/SOQL queries. Use when creating
  analytics dashboards, writing SAQL queries, configuring dataflows and
  recipes, or embedding analytics in Lightning pages. Do NOT use for
  standard reports (use sf-reporting) or Data Cloud (use sf-data-cloud).
---

# CRM Analytics

## Core Responsibilities

1. Create dashboards and lenses with SAQL
2. Configure dataflows and recipes for data preparation
3. Write SAQL queries for custom analytics
4. Embed analytics in Lightning pages and LWC
5. Manage datasets, security predicates, and sharing

## Key Concepts

| Concept | Description |
|---|---|
| Dataset | Pre-computed data store optimized for analytics |
| Lens | Single query/visualization on a dataset |
| Dashboard | Collection of widgets (charts, tables, filters) |
| Dataflow | ETL process that builds datasets from Salesforce objects |
| Recipe | Visual point-and-click data preparation tool |
| SAQL | Salesforce Analytics Query Language |
| Security Predicate | Row-level security filter on datasets |

## SAQL Query Examples

### Basic Query

```saql
q = load "Opportunities";
q = filter q by 'StageName' in ["Closed Won", "Negotiation"];
q = group q by 'StageName';
q = foreach q generate 'StageName', sum('Amount') as 'TotalAmount', count() as 'Count';
q = order q by 'TotalAmount' desc;
q = limit q 10;
```

### Date Filtering

```saql
q = load "Opportunities";
q = filter q by date('CloseDate_Year', 'CloseDate_Month', 'CloseDate_Day')
    in ["current year"];
q = group q by ('CloseDate_Year', 'CloseDate_Month');
q = foreach q generate 'CloseDate_Year' + "-" + 'CloseDate_Month' as 'Month',
    sum('Amount') as 'Revenue';
q = order q by 'Month' asc;
```

### Join Datasets

```saql
accounts = load "Accounts";
opps = load "Opportunities";
joined = cogroup accounts by 'Id', opps by 'AccountId';
joined = foreach joined generate
    accounts.'Name' as 'AccountName',
    sum(opps.'Amount') as 'TotalPipeline',
    count(opps) as 'OppCount';
joined = order joined by 'TotalPipeline' desc;
```

### Windowing Functions

```saql
q = load "Opportunities";
q = group q by ('OwnerId', 'Owner.Name');
q = foreach q generate
    'Owner.Name' as 'Rep',
    sum('Amount') as 'Total',
    sum(sum('Amount')) over ([..0] partition by all order by sum('Amount') desc) as 'RunningTotal';
```

## Dataflow Definition

```json
{
    "Extract_Opportunities": {
        "action": "sfdcDigest",
        "parameters": {
            "object": "Opportunity",
            "fields": [
                { "name": "Id" },
                { "name": "Name" },
                { "name": "Amount" },
                { "name": "StageName" },
                { "name": "CloseDate" },
                { "name": "AccountId" },
                { "name": "OwnerId" }
            ]
        }
    },
    "Register_Dataset": {
        "action": "sfdcRegister",
        "parameters": {
            "name": "Opportunities",
            "alias": "Opportunities",
            "source": "Extract_Opportunities"
        }
    }
}
```

## Security Predicates

Row-level security on datasets:

```json
// Only see own records
"'OwnerId' == \"$User.Id\""

// See records in own role hierarchy
"'OwnerId' == \"$User.Id\" || 'Owner.RoleId' in \"$User.UserRoleId\""

// See all if admin
"\"$User.Profile.Name\" == \"System Administrator\" || 'OwnerId' == \"$User.Id\""
```

## Embed in Lightning

### LWC Embed

```html
<template>
    <lightning-card title="Sales Dashboard">
        <wave-dashboard
            dashboard-id={dashboardId}
            height="600px"
            open-in-new-window>
        </wave-dashboard>
    </lightning-card>
</template>
```

## CLI Commands

```bash
# List analytics apps
sf data query --query "SELECT Id, DeveloperName, Label FROM Folder WHERE Type = 'Insights'" --target-org <alias>

# Retrieve analytics assets
sf project retrieve start --metadata WaveApplication,WaveDashboard,WaveDataflow --target-org <alias>
```

## Cross-Skill References

- For standard reports: see **sf-reporting**
- For SOQL queries: see **sf-soql**
- For embedding in LWC: see **sf-lwc**
- For Data Cloud analytics: see **sf-data-cloud**
