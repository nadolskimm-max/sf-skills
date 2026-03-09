---
name: sf-industry-finserv
description: >
  Builds Financial Services Cloud features including KYC, AML, wealth
  management, financial accounts, and compliance automation. Use when
  working with Financial Services Cloud objects, implementing KYC/AML
  workflows, building financial account hierarchies, or ensuring
  financial compliance patterns. Do NOT use for general Apex (use sf-apex)
  or standard integrations (use sf-integration).
---

# Financial Services Cloud

## Core Responsibilities

1. Configure Financial Services Cloud data model
2. Build KYC (Know Your Customer) workflows
3. Implement AML (Anti-Money Laundering) monitoring
4. Create financial account hierarchies
5. Ensure regulatory compliance patterns

## Financial Services Cloud Data Model

### Core Objects

| Object | Description |
|---|---|
| FinancialAccount | Bank accounts, investments, loans |
| FinancialAccountRole | Account ownership relationships |
| FinancialGoal | Client financial goals |
| WealthAppConfig | Wealth management configuration |
| InvestmentAccount | Investment-specific details |
| InsurancePolicy | Insurance policy records |
| Claim | Insurance claims |
| Card | Credit/debit card records |
| ChargeGroup | Fee/charge groupings |

### Account-Contact Relationship

```sql
-- Financial accounts for a client
SELECT Id, Name, FinancialAccountType__c, Balance__c,
       FinancialAccountNumber__c, Status__c
FROM FinancialAccount__c
WHERE PrimaryOwner__c = :clientId
ORDER BY FinancialAccountType__c

-- Client household with related financial accounts
SELECT Id, Name,
    (SELECT Id, Name, Balance__c FROM FinancialAccounts__r)
FROM Account
WHERE RecordType.DeveloperName = 'IndustriesHousehold'
```

## KYC Workflow

### KYC Process Steps

```
1. Customer Identification → Collect ID documents
2. Verification → Validate against external databases
3. Risk Assessment → Score based on risk indicators
4. Enhanced Due Diligence → Additional checks for high-risk
5. Approval → Compliance officer sign-off
6. Ongoing Monitoring → Periodic review
```

### KYC Automation (Flow)

```
Record-Triggered Flow: KYC Review
├── Entry: Account created with RecordType = 'Client'
├── Create KYC_Review__c record (Status = 'Pending')
├── Decision: Is high-risk country?
│   ├── Yes → Set Risk_Level__c = 'High', route to Compliance Queue
│   └── No → Set Risk_Level__c = 'Standard'
└── Email Alert: Notify assigned reviewer
```

## AML Monitoring

### Suspicious Activity Indicators

| Indicator | Detection Method |
|---|---|
| Unusual transaction volume | Apex Batch: compare vs 90-day average |
| Structuring (smurfing) | Multiple deposits just below reporting threshold |
| Rapid movement of funds | Money in/out within 24 hours |
| High-risk geography | Country list match via Custom Metadata |
| Politically Exposed Person | External API check during onboarding |

### AML Alert Apex

```apex
public class AMLMonitoringBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, PrimaryOwner__c, Balance__c,
                   (SELECT Id, Amount__c, TransactionDate__c
                    FROM Transactions__r
                    WHERE TransactionDate__c = LAST_N_DAYS:1)
            FROM FinancialAccount__c
            WHERE Status__c = 'Active'
        ]);
    }

    public void execute(Database.BatchableContext bc, List<FinancialAccount__c> scope) {
        List<AML_Alert__c> alerts = new List<AML_Alert__c>();
        for (FinancialAccount__c fa : scope) {
            Decimal dailyTotal = 0;
            for (Transaction__c tx : fa.Transactions__r) {
                dailyTotal += tx.Amount__c;
            }
            if (dailyTotal > 10000) {
                alerts.add(new AML_Alert__c(
                    Financial_Account__c = fa.Id,
                    Alert_Type__c = 'Large Transaction',
                    Amount__c = dailyTotal,
                    Status__c = 'New'
                ));
            }
        }
        if (!alerts.isEmpty()) {
            insert alerts;
        }
    }

    public void finish(Database.BatchableContext bc) {}
}
```

## Compliance Patterns

- [ ] All financial data classes use `with sharing`
- [ ] Shield Encryption on account numbers, SSN, financial balances
- [ ] Field Audit Trail on sensitive financial fields
- [ ] Role hierarchy restricts advisor-client relationships
- [ ] Apex-managed sharing for complex access rules
- [ ] All API integrations use Named Credentials
- [ ] Audit logging on all financial transactions

## Cross-Skill References

- For KYC/AML automation: see **sf-flow**
- For external verification APIs: see **sf-integration**
- For financial data security: see **sf-security**
- For regulatory reports: see **sf-reporting**
- For client portal: see **sf-experience-cloud**
