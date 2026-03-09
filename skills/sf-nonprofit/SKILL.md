---
name: sf-nonprofit
description: >
  Builds Salesforce Nonprofit Cloud (NPSP) features including donations,
  recurring giving, program management, household accounts, and
  fundraising. Use when configuring NPSP, managing donation records,
  building program tracking, or creating nonprofit-specific reports.
  Do NOT use for standard Account/Contact (use sf-metadata) or general
  Sales Cloud (use sf-cloud-sales).
---

# Nonprofit Cloud

## Core Responsibilities

1. Configure NPSP (Nonprofit Success Pack) objects and settings
2. Manage donations, recurring giving, and gift entry
3. Build program management and engagement tracking
4. Create fundraising reports and dashboards
5. Configure household account model

## NPSP Data Model

```
Household Account
├── Contact (household member)
│   ├── Opportunity (donation)
│   │   ├── Allocation (fund designation)
│   │   └── Partial Soft Credit
│   ├── Recurring Donation
│   │   └── Installment Opportunities (auto-created)
│   └── Engagement Plan
│       └── Engagement Plan Task
├── Affiliation (organization relationship)
└── Address (household address)

General Accounting Unit (fund)
└── Allocation (links donation to fund)

Program
├── Program Cohort
└── Program Enrollment
    └── Service Delivery
```

## Key Objects

| Object | Description |
|---|---|
| `Account` (Household) | Household grouping of contacts |
| `Contact` | Individual donor/constituent |
| `Opportunity` | Donation record |
| `npe03__Recurring_Donation__c` | Recurring giving schedule |
| `npsp__Allocation__c` | Fund designation for donation |
| `npsp__General_Accounting_Unit__c` | Fund/campaign account |
| `Program__c` | Program tracking |
| `ServiceDelivery__c` | Service provided to beneficiary |

## Donation Management

### Create Donation

```apex
Opportunity donation = new Opportunity(
    Name = contact.LastName + ' Donation ' + Date.today().format(),
    AccountId = contact.AccountId,
    ContactId = contact.Id,
    Amount = 500,
    CloseDate = Date.today(),
    StageName = 'Closed Won',
    npsp__Primary_Contact__c = contact.Id,
    Type = 'Donation'
);
insert donation;

// Allocate to fund
npsp__Allocation__c allocation = new npsp__Allocation__c(
    npsp__Opportunity__c = donation.Id,
    npsp__General_Accounting_Unit__c = generalFundId,
    npsp__Amount__c = 500
);
insert allocation;
```

### Recurring Donation

```apex
npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(
    npe03__Contact__c = contactId,
    npe03__Amount__c = 50,
    npe03__Installment_Period__c = 'Monthly',
    npe03__Date_Established__c = Date.today(),
    npsp__RecurringType__c = 'Open',
    npsp__Day_of_Month__c = '15',
    npsp__Status__c = 'Active'
);
insert rd;
// NPSP automatically creates installment Opportunities
```

## Common Queries

```sql
-- Total donations by fiscal year
SELECT FISCAL_YEAR(CloseDate) yr, SUM(Amount) total, COUNT(Id) cnt
FROM Opportunity
WHERE StageName = 'Closed Won' AND Type = 'Donation'
GROUP BY FISCAL_YEAR(CloseDate)
ORDER BY FISCAL_YEAR(CloseDate) DESC

-- Top donors
SELECT npsp__Primary_Contact__r.Name, SUM(Amount) total
FROM Opportunity
WHERE StageName = 'Closed Won' AND CloseDate = THIS_FISCAL_YEAR
GROUP BY npsp__Primary_Contact__r.Name
ORDER BY SUM(Amount) DESC
LIMIT 20

-- Recurring donations summary
SELECT npe03__Contact__r.Name, npe03__Amount__c, npe03__Installment_Period__c,
       npsp__Status__c
FROM npe03__Recurring_Donation__c
WHERE npsp__Status__c = 'Active'

-- LYBUNT (Last Year But Unfortunately Not This)
SELECT npsp__Primary_Contact__r.Name, MAX(CloseDate) lastGift
FROM Opportunity
WHERE StageName = 'Closed Won' AND Type = 'Donation'
GROUP BY npsp__Primary_Contact__r.Name
HAVING MAX(CloseDate) < THIS_FISCAL_YEAR
  AND MAX(CloseDate) >= LAST_FISCAL_YEAR
```

## Household Account Model

```
Household Account: "Smith Household"
├── Contact: John Smith (Primary)
├── Contact: Jane Smith
├── Address: 123 Main St, San Francisco CA
└── Donations roll up to Household level
```

NPSP auto-manages:
- Household naming (configurable)
- Primary contact designation
- Address management
- Donation rollups to Account and Contact

## Program Management

```sql
-- Program enrollments
SELECT Id, Program__r.Name, Contact__r.Name, Status__c, EnrollmentDate__c
FROM ProgramEngagement__c
WHERE Program__r.Status__c = 'Active'

-- Service delivery tracking
SELECT Id, ProgramEngagement__r.Contact__r.Name,
       DeliveryDate__c, Quantity__c, UnitOfMeasure__c
FROM ServiceDelivery__c
WHERE DeliveryDate__c = THIS_MONTH
```

## Cross-Skill References

- For donation automation: see **sf-flow**
- For fundraising reports: see **sf-reporting**
- For donor communications: see **sf-email**
- For donor portal: see **sf-experience-cloud**
