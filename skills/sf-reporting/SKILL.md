---
name: sf-reporting
description: >
  Creates and manages Salesforce reports, dashboards, custom report types,
  and analytic snapshots. Use when building report metadata XML, creating
  dashboard components, designing custom report types, or troubleshooting
  report performance. Do NOT use for SOQL queries (use sf-soql) or
  data exports (use sf-data).
---

# Salesforce Reports & Dashboards

## Core Responsibilities

1. Generate report metadata XML (tabular, summary, matrix)
2. Create dashboard metadata with chart components
3. Build custom report types for complex relationships
4. Optimize report performance for large datasets
5. Configure report folders and sharing

## Report Types

| Format | Use Case | Features |
|---|---|---|
| Tabular | Simple record lists | Fastest, no grouping |
| Summary | Grouped with subtotals | Row groupings, formulas |
| Matrix | Cross-tabulated data | Row + column groupings |
| Joined | Multiple report blocks | Combine different objects |

## Report Metadata XML

### Summary Report

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="http://soap.sforce.com/2006/04/metadata">
    <name>Opportunities by Stage</name>
    <reportType>Opportunity</reportType>
    <format>Summary</format>
    <groupingsDown>
        <dateGranularity>None</dateGranularity>
        <field>STAGE_NAME</field>
        <sortOrder>Asc</sortOrder>
    </groupingsDown>
    <columns>
        <field>OPPORTUNITY_NAME</field>
    </columns>
    <columns>
        <field>ACCOUNT_NAME</field>
    </columns>
    <columns>
        <field>AMOUNT</field>
    </columns>
    <columns>
        <field>CLOSE_DATE</field>
    </columns>
    <aggregates>
        <calculatedFormula>AMOUNT:SUM</calculatedFormula>
        <datatype>currency</datatype>
        <description>Total Amount</description>
        <developerName>FORMULA1</developerName>
        <isActive>true</isActive>
        <masterLabel>Total Amount</masterLabel>
        <scale>2</scale>
    </aggregates>
    <filter>
        <criteriaItems>
            <column>CLOSE_DATE</column>
            <columnToColumn>false</columnToColumn>
            <isUnlocked>false</isUnlocked>
            <operator>equals</operator>
            <value>THIS_FISCAL_YEAR</value>
        </criteriaItems>
    </filter>
    <showDetails>true</showDetails>
    <sortColumn>AMOUNT</sortColumn>
    <sortOrder>Desc</sortOrder>
</Report>
```

## Dashboard Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Dashboard xmlns="http://soap.sforce.com/2006/04/metadata">
    <backgroundEndColor>#FFFFFF</backgroundEndColor>
    <backgroundStartColor>#FFFFFF</backgroundStartColor>
    <dashboardType>SpecifiedUser</dashboardType>
    <runningUser>admin@example.com</runningUser>
    <title>Sales Executive Dashboard</title>
    <leftSection>
        <columnSize>Medium</columnSize>
        <components>
            <componentType>Chart</componentType>
            <report>Opportunities_by_Stage</report>
            <chartSummary>
                <aggregate>Sum</aggregate>
                <column>AMOUNT</column>
            </chartSummary>
            <displayUnits>Auto</displayUnits>
            <header>Pipeline by Stage</header>
        </components>
    </leftSection>
</Dashboard>
```

## Custom Report Type

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ReportType xmlns="http://soap.sforce.com/2006/04/metadata">
    <baseObject>Account</baseObject>
    <label>Accounts with Contacts and Opportunities</label>
    <category>accounts</category>
    <deployed>true</deployed>
    <description>Accounts with related Contacts and Opportunities</description>
    <join>
        <outerJoin>false</outerJoin>
        <relationship>Contacts</relationship>
        <join>
            <outerJoin>true</outerJoin>
            <relationship>Opportunities</relationship>
        </join>
    </join>
</ReportType>
```

## CLI Commands

```bash
# Deploy reports
sf project deploy start --metadata Report --target-org <alias>

# Deploy dashboards
sf project deploy start --metadata Dashboard --target-org <alias>

# Retrieve reports from org
sf project retrieve start --metadata Report:My_Report --target-org <alias>
```

## Performance Optimization

| Issue | Solution |
|---|---|
| Report timeout on large datasets | Add date range filter, reduce columns |
| Slow cross-object reports | Use custom report types with inner joins |
| Dashboard load time | Limit to 20 components, use filters |
| Formula columns slow | Pre-compute in Apex/Flow, store in field |
| Too many groupings | Reduce to max 3 groupings |

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Running as admin (sees all data) | Use "Run as specified user" or "Run as logged-in user" |
| No date filter on transaction objects | Always filter by date range |
| Joined reports for simple cases | Use summary/matrix instead (faster) |
| Dashboard without refresh schedule | Set auto-refresh for key dashboards |

## Cross-Skill References

- For SOQL-based data analysis: see **sf-soql**
- For custom objects in reports: see **sf-metadata**
- For deployment: see **sf-deploy**
