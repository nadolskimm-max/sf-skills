---
name: sf-permissions
description: >
  Analyzes and manages Salesforce permissions including Permission Sets,
  Permission Set Groups, Profiles, and sharing rules. Use when answering
  "who has access to X?", creating permission sets, comparing profiles,
  auditing field-level security, or troubleshooting access issues.
  Do NOT use for metadata XML generation (use sf-metadata) or deployment
  (use sf-deploy).
---

# Salesforce Permissions Management

## Core Responsibilities

1. Create Permission Set metadata XML
2. Analyze existing permissions ("Who has access to X?")
3. Compare profiles and permission sets
4. Audit field-level security (FLS)
5. Troubleshoot access and visibility issues

## Workflow

### Phase 1 — Discover

```bash
# List permission sets
sf data query --query "SELECT Id, Name, Label FROM PermissionSet WHERE IsCustom = true" --target-org <alias>

# List permission set assignments for a user
sf data query --query "SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = '<userId>'" --target-org <alias>

# Check object permissions in a permission set
sf data query --query "SELECT SobjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete FROM ObjectPermissions WHERE ParentId = '<permSetId>'" --target-org <alias>

# Check field permissions
sf data query --query "SELECT Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE ParentId = '<permSetId>' AND SobjectType = 'Account'" --target-org <alias>
```

### Phase 2 — Generate

Create Permission Set XML:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Invoice Manager</label>
    <description>Full CRUD access to Invoice object and related fields</description>
    <hasActivationRequired>false</hasActivationRequired>

    <objectPermissions>
        <object>Invoice__c</object>
        <allowCreate>true</allowCreate>
        <allowRead>true</allowRead>
        <allowEdit>true</allowEdit>
        <allowDelete>true</allowDelete>
        <viewAllRecords>false</viewAllRecords>
        <modifyAllRecords>false</modifyAllRecords>
    </objectPermissions>

    <fieldPermissions>
        <field>Invoice__c.Amount__c</field>
        <readable>true</readable>
        <editable>true</editable>
    </fieldPermissions>
    <fieldPermissions>
        <field>Invoice__c.Status__c</field>
        <readable>true</readable>
        <editable>true</editable>
    </fieldPermissions>

    <tabSettings>
        <tab>Invoice__c</tab>
        <visibility>Visible</visibility>
    </tabSettings>
</PermissionSet>
```

### Phase 3 — Assign

```bash
# Assign permission set to user
sf org assign permset --name Invoice_Manager --target-org <alias>

# Assign to specific user
sf org assign permset --name Invoice_Manager --on-behalf-of user@example.com --target-org <alias>
```

## "Who Has Access?" Analysis

To determine who can access a specific object or field:

```sql
-- Users with object access via Permission Sets
SELECT Assignee.Name, PermissionSet.Label
FROM PermissionSetAssignment
WHERE PermissionSet.Id IN (
    SELECT ParentId FROM ObjectPermissions
    WHERE SobjectType = 'Invoice__c' AND PermissionsRead = true
)

-- Users with field edit access
SELECT Assignee.Name, PermissionSet.Label
FROM PermissionSetAssignment
WHERE PermissionSet.Id IN (
    SELECT ParentId FROM FieldPermissions
    WHERE Field = 'Invoice__c.Amount__c' AND PermissionsEdit = true
)
```

## Permission Set Group Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSetGroup xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Sales Team</label>
    <description>Combined permissions for sales team members</description>
    <permissionSets>
        <permissionSet>Invoice_Manager</permissionSet>
        <permissionSet>Account_Editor</permissionSet>
        <permissionSet>Report_Viewer</permissionSet>
    </permissionSets>
</PermissionSetGroup>
```

## Sharing Model Reference

| OWD Setting | Meaning |
|---|---|
| Private | Only owner and above in hierarchy |
| Read Only | Everyone can read, only owner can edit |
| Read/Write | Everyone can read and edit |
| Controlled by Parent | Inherits from master-detail parent |

## Best Practices

- Prefer Permission Sets over Profile edits
- Group related permissions into Permission Set Groups
- Use "Minimum Access" profile + Permission Sets
- Document the purpose of each Permission Set in the description
- Always include FLS alongside object-level CRUD

## Cross-Skill References

- For permission set XML: see **sf-metadata**
- For deploying permissions: see **sf-deploy**
- For querying assignments: see **sf-soql**
