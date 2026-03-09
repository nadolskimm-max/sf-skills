---
name: sf-duplicate-management
description: >
  Configures Salesforce duplicate detection and management including
  Duplicate Rules, Matching Rules, merge operations, and data quality
  monitoring. Use when setting up duplicate prevention, creating matching
  rules, merging duplicate records, or building data quality dashboards.
  Do NOT use for general data operations (use sf-data) or validation
  rules (use sf-formula).
---

# Duplicate Management

## Core Responsibilities

1. Create Matching Rules for duplicate detection
2. Configure Duplicate Rules for alert/block behavior
3. Merge duplicate records programmatically
4. Build data quality monitoring queries
5. Design deduplication strategies

## Matching Rules

### Standard Matching Rule Fields

| Object | Default Matching Fields |
|---|---|
| Account | Name, BillingCity, BillingStreet, Phone, Website |
| Contact | FirstName, LastName, Email, Phone, MailingAddress |
| Lead | FirstName, LastName, Email, Phone, Company |

### Custom Matching Rule Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<MatchingRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Contact_Email_Match</fullName>
    <label>Contact Email Match</label>
    <matchingRuleItems>
        <blankValueBehavior>NullNotAllowed</blankValueBehavior>
        <fieldName>Email</fieldName>
        <matchingMethod>Exact</matchingMethod>
    </matchingRuleItems>
    <matchingRuleItems>
        <blankValueBehavior>NullNotAllowed</blankValueBehavior>
        <fieldName>LastName</fieldName>
        <matchingMethod>Exact</matchingMethod>
    </matchingRuleItems>
    <ruleStatus>Active</ruleStatus>
</MatchingRule>
```

### Matching Methods

| Method | Description | Use Case |
|---|---|---|
| Exact | Identical match | Email, Phone |
| Fuzzy: First Name | Name variations (Bob/Robert) | First Name |
| Fuzzy: Last Name | Typo tolerance | Last Name |
| Fuzzy: Company Name | Company variations (Inc/LLC) | Company |
| Fuzzy: Phone | Format-agnostic phone match | Phone |
| Fuzzy: City | City name variations | City |
| Fuzzy: Street | Address normalization | Street |
| Fuzzy: Zip | Zip code matching | Postal Code |

## Duplicate Rules

```xml
<?xml version="1.0" encoding="UTF-8"?>
<DuplicateRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Contact_Duplicate_Rule</fullName>
    <actionOnInsert>Allow</actionOnInsert>
    <actionOnUpdate>Allow</actionOnUpdate>
    <alertText>This contact may be a duplicate.</alertText>
    <isActive>true</isActive>
    <operationsOnInsert>Alert</operationsOnInsert>
    <operationsOnUpdate>Alert</operationsOnUpdate>
    <duplicateRuleMatchRules>
        <matchingRule>Contact_Email_Match</matchingRule>
        <objectMapping>Contact</objectMapping>
    </duplicateRuleMatchRules>
</DuplicateRule>
```

### Action Types

| Action | Behavior |
|---|---|
| Allow + Alert | Show warning, user can save anyway |
| Allow + Report | Log to duplicate record set silently |
| Block | Prevent save if duplicates found |

## Apex Duplicate Detection

```apex
public class DuplicateChecker {
    public static List<Datacloud.DuplicateResult> findDuplicates(SObject record) {
        Datacloud.FindDuplicatesResult[] results =
            Datacloud.FindDuplicates.findDuplicates(new List<SObject>{ record });

        List<Datacloud.DuplicateResult> duplicates = new List<Datacloud.DuplicateResult>();
        for (Datacloud.FindDuplicatesResult result : results) {
            duplicates.addAll(result.getDuplicateResults());
        }
        return duplicates;
    }
}
```

## Merge Records (Apex)

```apex
// Merge up to 3 records into master
Account master = [SELECT Id FROM Account WHERE Id = :masterId];
Account duplicate = [SELECT Id FROM Account WHERE Id = :duplicateId];
Database.MergeResult result = Database.merge(master, duplicate);

if (result.isSuccess()) {
    System.debug('Merged. Updated related: ' + result.getUpdatedRelatedIds());
}
```

## Data Quality Queries

```sql
-- Find duplicate Contacts by email
SELECT Email, COUNT(Id) cnt
FROM Contact
WHERE Email != null
GROUP BY Email
HAVING COUNT(Id) > 1
ORDER BY COUNT(Id) DESC

-- Find duplicate Accounts by name
SELECT Name, COUNT(Id) cnt
FROM Account
WHERE Name != null
GROUP BY Name
HAVING COUNT(Id) > 1

-- Contacts without email
SELECT Id, FirstName, LastName, AccountId
FROM Contact
WHERE Email = null

-- Accounts without phone or website
SELECT Id, Name FROM Account
WHERE Phone = null AND Website = null
```

## Deduplication Strategy

```
1. IDENTIFY: Run data quality queries to find duplicates
2. ANALYZE: Review matches, determine master record
3. MERGE: Use Database.merge or manual merge
4. PREVENT: Activate Duplicate Rules + Matching Rules
5. MONITOR: Schedule periodic data quality reports
```

## Cross-Skill References

- For data quality SOQL: see **sf-soql**
- For batch deduplication: see **sf-async-patterns**
- For data import with dedup: see **sf-data**
- For reporting on data quality: see **sf-reporting**
