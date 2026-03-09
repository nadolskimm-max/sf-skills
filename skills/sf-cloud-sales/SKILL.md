---
name: sf-cloud-sales
description: >
  Builds Sales Cloud features including Opportunity products, Quotes,
  Forecasting, Territory Management, and sales processes. Use when
  configuring sales paths, setting up opportunity products/price books,
  creating quote templates, or building sales-specific automation.
  Do NOT use for general Apex (use sf-apex) or reports (use sf-reporting).
---

# Sales Cloud

## Core Responsibilities

1. Configure Opportunity products, Price Books, and pricing
2. Set up Quotes and Quote templates
3. Configure Sales Forecasting
4. Build sales processes and path guidance
5. Set up Territory Management

## Opportunity Products & Price Books

### Standard Price Book Entry

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Product2 xmlns="http://soap.sforce.com/2006/04/metadata">
    <Name>Enterprise License</Name>
    <ProductCode>ENT-001</ProductCode>
    <IsActive>true</IsActive>
    <Description>Annual enterprise license</Description>
    <Family>Licenses</Family>
</Product2>
```

### Apex: Add Products to Opportunity

```apex
PricebookEntry pbe = [
    SELECT Id, UnitPrice FROM PricebookEntry
    WHERE Product2.ProductCode = 'ENT-001'
      AND Pricebook2.IsStandard = true
    LIMIT 1
];

OpportunityLineItem oli = new OpportunityLineItem(
    OpportunityId = opp.Id,
    PricebookEntryId = pbe.Id,
    Quantity = 10,
    UnitPrice = pbe.UnitPrice
);
insert oli;
```

## Sales Process

### Sales Path Stages

| Stage | Probability | Guidance |
|---|---|---|
| Prospecting | 10% | Qualify the lead, identify decision maker |
| Qualification | 25% | Confirm budget, authority, need, timeline |
| Proposal | 50% | Send proposal, demo product |
| Negotiation | 75% | Negotiate terms, handle objections |
| Closed Won | 100% | Signed contract, handoff to CS |
| Closed Lost | 0% | Document loss reason, schedule follow-up |

### Sales Process Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<BusinessProcess xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Enterprise_Sales_Process</fullName>
    <isActive>true</isActive>
    <values>
        <fullName>Prospecting</fullName>
        <default>true</default>
    </values>
    <values><fullName>Qualification</fullName></values>
    <values><fullName>Proposal</fullName></values>
    <values><fullName>Negotiation</fullName></values>
    <values><fullName>Closed Won</fullName></values>
    <values><fullName>Closed Lost</fullName></values>
</BusinessProcess>
```

## Forecasting

### Forecast Types

| Type | Description |
|---|---|
| Opportunity Amount | Based on Amount field |
| Opportunity Quantity | Based on Quantity field |
| Custom Measure | Formula-based forecast field |
| Overlay Split | Team-based split forecasting |

### Forecast Categories

| Category | Stage Mapping |
|---|---|
| Pipeline | Prospecting, Qualification |
| Best Case | Proposal, Negotiation |
| Commit | Verbal Commit |
| Closed | Closed Won |
| Omitted | Closed Lost |

## Territory Management

### Territory Model

```
Global Territory
├── North America
│   ├── US West
│   │   ├── California
│   │   └── Washington
│   └── US East
│       ├── New York
│       └── Florida
└── EMEA
    ├── UK
    └── Germany
```

### Assignment Rules

```sql
-- Accounts assigned to territories
SELECT Id, Name, Territory2Id, Territory2.Name
FROM Account
WHERE Territory2Id != null

-- User-territory assignments
SELECT Id, Territory2Id, UserId, User.Name
FROM UserTerritory2Association
```

## Key SOQL Queries

```sql
-- Pipeline report
SELECT StageName, COUNT(Id) cnt, SUM(Amount) total
FROM Opportunity
WHERE IsClosed = false AND CloseDate = THIS_FISCAL_QUARTER
GROUP BY StageName

-- Win rate
SELECT StageName, COUNT(Id) cnt
FROM Opportunity
WHERE CloseDate = THIS_FISCAL_YEAR AND IsClosed = true
GROUP BY StageName
```

## Cross-Skill References

- For opportunity automation: see **sf-flow**
- For sales reports: see **sf-reporting**
- For quote generation in Apex: see **sf-apex**
- For sales team permissions: see **sf-permissions**
