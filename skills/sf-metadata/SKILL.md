---
name: sf-metadata
description: >
  Generates and manages Salesforce metadata (custom objects, fields,
  validation rules, record types, page layouts). Use when creating
  custom objects/fields, querying org metadata via CLI, generating
  permission sets, or working with metadata XML files. Do NOT use for
  Apex code (use sf-apex), Flows (use sf-flow), or deployment (use sf-deploy).
---

# Salesforce Metadata Management

## Core Responsibilities

1. Generate custom object and field metadata XML
2. Create validation rules, record types, and page layouts
3. Query org metadata via Salesforce CLI
4. Generate permission sets and profiles
5. Ensure metadata follows naming conventions and best practices

## Workflow

### Phase 1 — Discover

Query existing metadata in the org:

```bash
# Describe an object
sf sobject describe --sobject Account --target-org <alias>

# List all custom objects
sf sobject list --sobject-type custom --target-org <alias>

# Retrieve metadata from org
sf project retrieve start --metadata CustomObject:Invoice__c --target-org <alias>
```

### Phase 2 — Generate

Create metadata XML files following Salesforce DX project structure:

```
force-app/main/default/
├── objects/
│   └── Invoice__c/
│       ├── Invoice__c.object-meta.xml
│       ├── fields/
│       │   ├── Amount__c.field-meta.xml
│       │   └── Status__c.field-meta.xml
│       ├── validationRules/
│       │   └── RequireAmountWhenApproved.validationRule-meta.xml
│       └── recordTypes/
│           └── Standard.recordType-meta.xml
├── permissionsets/
│   └── Invoice_Manager.permissionset-meta.xml
└── layouts/
    └── Invoice__c-Invoice Layout.layout-meta.xml
```

### Phase 3 — Deploy

```bash
sf project deploy start --source-dir force-app --target-org <alias>
```

## Metadata Templates

### Custom Object

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Invoice</label>
    <pluralLabel>Invoices</pluralLabel>
    <nameField>
        <label>Invoice Number</label>
        <type>AutoNumber</type>
        <displayFormat>INV-{0000}</displayFormat>
        <startingNumber>1</startingNumber>
    </nameField>
    <deploymentStatus>Deployed</deploymentStatus>
    <sharingModel>ReadWrite</sharingModel>
    <enableActivities>true</enableActivities>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
</CustomObject>
```

### Custom Fields

**Text Field:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Description__c</fullName>
    <label>Description</label>
    <type>TextArea</type>
    <required>false</required>
</CustomField>
```

**Currency Field:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Amount__c</fullName>
    <label>Amount</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>
    <required>true</required>
</CustomField>
```

**Picklist Field:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Status__c</fullName>
    <label>Status</label>
    <type>Picklist</type>
    <required>true</required>
    <valueSet>
        <restricted>true</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value><fullName>Draft</fullName><default>true</default><label>Draft</label></value>
            <value><fullName>Submitted</fullName><default>false</default><label>Submitted</label></value>
            <value><fullName>Approved</fullName><default>false</default><label>Approved</label></value>
            <value><fullName>Paid</fullName><default>false</default><label>Paid</label></value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
```

**Lookup Field:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Account__c</fullName>
    <label>Account</label>
    <type>Lookup</type>
    <referenceTo>Account</referenceTo>
    <relationshipName>Invoices</relationshipName>
    <relationshipLabel>Invoices</relationshipLabel>
    <required>false</required>
    <deleteConstraint>SetNull</deleteConstraint>
</CustomField>
```

### Validation Rule

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>RequireAmountWhenApproved</fullName>
    <active>true</active>
    <errorConditionFormula>AND(
    ISPICKVAL(Status__c, 'Approved'),
    ISBLANK(Amount__c)
)</errorConditionFormula>
    <errorDisplayField>Amount__c</errorDisplayField>
    <errorMessage>Amount is required when Status is Approved.</errorMessage>
</ValidationRule>
```

## Naming Conventions

| Metadata Type | Pattern | Example |
|---|---|---|
| Custom Object | `{Name}__c` (PascalCase) | `Invoice__c` |
| Custom Field | `{Name}__c` (PascalCase) | `Total_Amount__c` |
| Validation Rule | `{PurposeCamelCase}` | `RequireAmountWhenApproved` |
| Record Type | `{Name}` (PascalCase) | `Standard`, `Partner` |
| Permission Set | `{Role}_Permissions` | `Invoice_Manager` |

## Cross-Skill References

- For permission sets: see **sf-permissions**
- For deployment: see **sf-deploy**
- For querying metadata: see **sf-soql** (Tooling API)
