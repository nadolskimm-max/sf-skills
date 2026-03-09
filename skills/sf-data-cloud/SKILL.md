---
name: sf-data-cloud
description: >
  Builds Salesforce Data Cloud (CDP) features including data model objects,
  segments, calculated insights, identity resolution, and data streams.
  Use when configuring Data Cloud data models, creating segments, setting
  up data streams, or querying Data Cloud objects. Do NOT use for standard
  SOQL (use sf-soql) or regular data operations (use sf-data).
---

# Data Cloud

## Core Responsibilities

1. Configure Data Model Objects (DMOs) and relationships
2. Create and manage Segments for audience targeting
3. Set up Data Streams for ingestion
4. Configure Identity Resolution rulesets
5. Build Calculated Insights for derived metrics

## Key Concepts

| Concept | Description |
|---|---|
| Data Model Object (DMO) | Schema definition for data in Data Cloud |
| Data Stream | Ingestion pipeline from a source to a DMO |
| Identity Resolution | Rules for matching/merging individual profiles |
| Unified Profile | Merged view of an individual across sources |
| Segment | Audience definition based on criteria |
| Calculated Insight | Computed metric stored on profiles |
| Activation | Publishing segments to marketing channels |

## Data Model Objects

### Standard DMOs

| DMO | Description |
|---|---|
| Individual | Person/contact records |
| Account | Organization records |
| Sales Order | Transaction records |
| Engagement | Interaction records (email, web, etc.) |
| Product | Product catalog |
| Loyalty Program | Loyalty memberships and transactions |

### Querying DMOs

Data Cloud uses SQL-like syntax:

```sql
SELECT
    ssot__FirstName__c,
    ssot__LastName__c,
    ssot__Email__c,
    ssot__AccountId__c
FROM ssot__Individual__dlm
WHERE ssot__Email__c IS NOT NULL
LIMIT 100
```

## Data Streams

### Stream Types

| Type | Source | Use Case |
|---|---|---|
| CRM Connector | Salesforce org | Sync CRM data |
| Ingestion API | External systems | Real-time events |
| Amazon S3 | S3 buckets | Batch data import |
| Google Cloud Storage | GCS buckets | Batch data import |
| Marketing Cloud | SFMC | Email engagement data |

### Setup via CLI

```bash
# Query existing data streams
sf data query --query "SELECT Id, DeveloperName, Status FROM DataStream" --target-org <alias> --use-tooling-api
```

## Identity Resolution

### Resolution Ruleset

| Rule Type | Description | Example |
|---|---|---|
| Exact Match | Exact field match | Email = Email |
| Normalized Match | Match after normalization | Phone (strip formatting) |
| Fuzzy Match | Approximate match | Name (Levenshtein distance) |

### Priority Order
1. Exact email match
2. Exact phone + last name match
3. Fuzzy first name + last name + postal code

## Segments

### Segment Types

| Type | Description |
|---|---|
| Batch | Refreshed on schedule (hourly, daily) |
| Streaming | Real-time updates as data changes |

### Segment Query Example

```sql
-- High-value customers who engaged recently
SELECT ssot__Individual__dlm.ssot__Id__c
FROM ssot__Individual__dlm
JOIN ssot__SalesOrder__dlm
  ON ssot__Individual__dlm.ssot__Id__c = ssot__SalesOrder__dlm.ssot__IndividualId__c
WHERE ssot__SalesOrder__dlm.ssot__TotalAmount__c > 1000
  AND ssot__SalesOrder__dlm.ssot__OrderDate__c >= DATEADD(month, -3, CURRENT_DATE)
```

## Calculated Insights

```sql
-- Lifetime Value calculation
CREATE CALCULATED INSIGHT Customer_LTV AS
SELECT
    ssot__IndividualId__c,
    SUM(ssot__TotalAmount__c) AS Lifetime_Value,
    COUNT(*) AS Total_Orders,
    MAX(ssot__OrderDate__c) AS Last_Order_Date
FROM ssot__SalesOrder__dlm
GROUP BY ssot__IndividualId__c
```

## Activations

| Target | Description |
|---|---|
| Marketing Cloud | Email campaigns |
| Google Ads | Custom audiences |
| Meta Ads | Lookalike audiences |
| Amazon Ads | Display targeting |
| Salesforce CRM | Update records |

## Cross-Skill References

- For CRM data feeding Data Cloud: see **sf-data**
- For SOQL on CRM objects: see **sf-soql**
- For agent observability via Data Cloud: see **sf-ai-agentforce-observability**
- For deployment: see **sf-deploy**
