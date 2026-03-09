---
name: sf-security
description: >
  Manages Salesforce security model including sharing rules, org-wide
  defaults, field-level security, encryption, and security review
  preparation. Use when configuring record access, troubleshooting
  sharing issues, setting up Shield Platform Encryption, or preparing
  for Salesforce Security Review. Do NOT use for Permission Sets only
  (use sf-permissions) or OAuth apps (use sf-connected-apps).
---

# Salesforce Security

## Core Responsibilities

1. Configure Organization-Wide Defaults (OWD) and sharing model
2. Create sharing rules (criteria-based and owner-based)
3. Set up Shield Platform Encryption
4. Enforce field-level security and CRUD checks in Apex
5. Prepare for Salesforce Security Review (AppExchange)

## Sharing Model Architecture

```
Organization-Wide Defaults (most restrictive baseline)
  └── Role Hierarchy (opens access up the hierarchy)
      └── Sharing Rules (opens access to groups/roles)
          └── Manual Sharing (individual record grants)
              └── Apex Managed Sharing (programmatic)
```

## Organization-Wide Defaults

| Setting | Record Access |
|---|---|
| Private | Only owner + users above in role hierarchy |
| Read Only | Everyone reads; only owner edits |
| Read/Write | Everyone reads and edits |
| Controlled by Parent | Inherits from master-detail parent |
| Full Access | (internal use only for certain objects) |

### Configure via Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<SharingRules xmlns="http://soap.sforce.com/2006/04/metadata">
    <sharingCriteriaRules>
        <fullName>Share_High_Value_Accounts</fullName>
        <accessLevel>Read</accessLevel>
        <label>Share High Value Accounts</label>
        <sharedTo>
            <group>Sales_Managers</group>
        </sharedTo>
        <criteriaItems>
            <field>AnnualRevenue</field>
            <operation>greaterOrEqual</operation>
            <value>1000000</value>
        </criteriaItems>
    </sharingCriteriaRules>
</SharingRules>
```

## CRUD/FLS Enforcement in Apex

### WITH SECURITY_ENFORCED (simplest)

```apex
List<Account> accounts = [
    SELECT Id, Name, Phone
    FROM Account
    WITH SECURITY_ENFORCED
];
```

### Security.stripInaccessible (granular)

```apex
List<Account> accounts = [SELECT Id, Name, Phone, Secret__c FROM Account];
SObjectAccessDecision decision = Security.stripInaccessible(
    AccessType.READABLE, accounts
);
List<Account> sanitized = decision.getRecords();
// Secret__c stripped if user lacks FLS read access
```

### Schema Checks (manual)

```apex
if (!Schema.sObjectType.Account.isAccessible()) {
    throw new SecurityException('No access to Account');
}
if (!Schema.sObjectType.Account.fields.Phone.isUpdateable()) {
    throw new SecurityException('Cannot update Phone field');
}
```

## Shield Platform Encryption

### Key Concepts

| Feature | Description |
|---|---|
| Deterministic Encryption | Allows filtering on encrypted fields |
| Probabilistic Encryption | Stronger security, no filtering |
| Tenant Secret | Customer-controlled key component |
| Key Derivation Function | Combines tenant secret + Salesforce master secret |

### Encrypted Field Types

Text, Text Area, Phone, Email, URL, Date, DateTime, and custom fields can be encrypted. Standard fields on standard objects have limited support.

### Enable via CLI

```bash
sf data query --query "SELECT Id, DeveloperName FROM TenantSecret" --target-org <alias> --use-tooling-api
```

## Security Review Checklist

For AppExchange submissions:

- [ ] All SOQL uses `WITH SECURITY_ENFORCED` or `stripInaccessible`
- [ ] No hardcoded credentials, IDs, or endpoints
- [ ] All DML checks `isCreateable()` / `isUpdateable()` / `isDeletable()`
- [ ] No `without sharing` classes unless documented and justified
- [ ] SOSL/SOQL injection prevention (`String.escapeSingleQuotes`)
- [ ] No `@RemoteAction` without CSRF protection
- [ ] Visualforce pages use `{!HTMLENCODE()}` for output
- [ ] LWC components sanitize user input
- [ ] Connected Apps use minimum required scopes
- [ ] No sensitive data in debug logs or client-side code

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| `without sharing` by default | Use `with sharing`, document exceptions |
| No FLS checks before DML | Use `stripInaccessible` or Schema checks |
| Dynamic SOQL with string concat | Use bind variables or `escapeSingleQuotes` |
| Hardcoded admin profile checks | Use Permission Sets and Custom Permissions |
| Sharing rules for row-level logic | Use Apex Managed Sharing for complex rules |

## Cross-Skill References

- For Permission Sets: see **sf-permissions**
- For OAuth security: see **sf-connected-apps**
- For Apex security patterns: see **sf-apex**
- For deployment: see **sf-deploy**
