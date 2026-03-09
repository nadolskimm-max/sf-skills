---
name: sf-data
description: >
  Manages Salesforce data operations including SOQL queries, test data
  factories, record import/export, and Bulk API operations. Use when
  querying data, creating test data factories, importing/exporting CSV,
  or performing bulk data operations. Do NOT use for query optimization
  theory (use sf-soql) or Apex DML patterns (use sf-apex).
---

# Salesforce Data Operations

## Core Responsibilities

1. Execute SOQL queries and export results
2. Create Apex test data factory classes
3. Import/export records via CLI (CSV, JSON)
4. Perform bulk data operations (insert, update, upsert, delete)
5. Generate realistic test data hierarchies

## Workflow

### Phase 1 — Query

```bash
# Query records
sf data query --query "SELECT Id, Name FROM Account LIMIT 10" --target-org <alias>

# Query with CSV output
sf data query --query "SELECT Id, Name, Industry FROM Account" --result-format csv --target-org <alias> > accounts.csv

# Query with JSON output
sf data query --query "SELECT Id, Name FROM Account LIMIT 5" --result-format json --target-org <alias>
```

### Phase 2 — Import/Export

```bash
# Import from CSV
sf data import bulk --sobject Account --file accounts.csv --target-org <alias>

# Export to CSV
sf data export bulk --query "SELECT Id, Name FROM Account" --output-file accounts.csv --target-org <alias>

# Insert single record
sf data create record --sobject Account --values "Name='Acme Corp' Industry='Technology'" --target-org <alias>

# Delete record
sf data delete record --sobject Account --record-id 001xx000003ABCDEF --target-org <alias>

# Upsert with external ID
sf data upsert bulk --sobject Account --file accounts.csv --external-id External_Id__c --target-org <alias>
```

## Test Data Factory Pattern

```apex
@IsTest
public class TestDataFactory {
    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Industry = 'Technology',
                BillingCity = 'San Francisco'
            ));
        }
        insert accounts;
        return accounts;
    }

    public static List<Contact> createContacts(List<Account> accounts, Integer perAccount) {
        List<Contact> contacts = new List<Contact>();
        for (Account acc : accounts) {
            for (Integer i = 0; i < perAccount; i++) {
                contacts.add(new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact ' + i,
                    AccountId = acc.Id,
                    Email = 'test' + i + '@' + acc.Name.deleteWhitespace() + '.com'
                ));
            }
        }
        insert contacts;
        return contacts;
    }

    public static List<Opportunity> createOpportunities(List<Account> accounts, Integer perAccount) {
        List<Opportunity> opps = new List<Opportunity>();
        for (Account acc : accounts) {
            for (Integer i = 0; i < perAccount; i++) {
                opps.add(new Opportunity(
                    Name = acc.Name + ' Opp ' + i,
                    AccountId = acc.Id,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    Amount = 10000 + (i * 5000)
                ));
            }
        }
        insert opps;
        return opps;
    }

    public static void createFullHierarchy(Integer accountCount, Integer contactsPer, Integer oppsPer) {
        List<Account> accounts = createAccounts(accountCount);
        createContacts(accounts, contactsPer);
        createOpportunities(accounts, oppsPer);
    }
}
```

## Bulk API Operations

For large datasets (10k+ records), use Bulk API:

```bash
# Bulk insert
sf data import bulk --sobject Account --file large_accounts.csv --target-org <alias>

# Bulk delete
sf data delete bulk --sobject Account --file account_ids.csv --target-org <alias>

# Bulk upsert
sf data upsert bulk --sobject Account --file accounts.csv --external-id External_Id__c --target-org <alias>
```

### CSV Format Requirements

- First row must be field API names
- Use UTF-8 encoding
- Date format: `YYYY-MM-DD`
- DateTime format: `YYYY-MM-DDThh:mm:ss.sssZ`
- Boolean: `true` / `false`
- Null: empty value

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Manual test data in each test method | Use a centralized `TestDataFactory` class |
| Hardcoded record IDs in data scripts | Use queries or External IDs |
| No cleanup after data load | Use scratch orgs or document cleanup steps |
| Loading related records without parent IDs | Load parents first, map IDs, then load children |

## Cross-Skill References

- For SOQL query syntax: see **sf-soql**
- For test class patterns: see **sf-testing**
- For deploying data scripts: see **sf-deploy**
