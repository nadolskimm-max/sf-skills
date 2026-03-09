---
name: sf-custom-metadata
description: >
  Creates and manages Custom Metadata Types, Custom Settings, and Custom
  Labels for Salesforce configuration. Use when building configurable
  applications, implementing feature flags, choosing between CMT vs
  Custom Settings vs Custom Labels, or creating metadata-driven logic.
  Do NOT use for custom objects (use sf-metadata) or permission
  configuration (use sf-permissions).
---

# Custom Metadata, Settings & Labels

## Core Responsibilities

1. Create Custom Metadata Types (CMT) for deployable configuration
2. Build Custom Settings (hierarchy and list) for org/user config
3. Manage Custom Labels for translatable text
4. Implement feature flags and configuration patterns
5. Guide correct choice between CMT, Settings, and Labels

## When to Use What

| Feature | Custom Metadata Type | Custom Setting (Hierarchy) | Custom Setting (List) | Custom Label |
|---|---|---|---|---|
| Deployable | Yes | No (data) | No (data) | Yes |
| Packageable | Yes | No | No | Yes |
| Per-user config | No | Yes | No | No |
| SOQL-free access | Yes (`getAll()`) | Yes (`getInstance()`) | Yes (`getAll()`) | Yes (`Label.*`) |
| Triggers | No | No | No | No |
| Test visible | Yes | Needs `SeeAllData` or setup | Needs `SeeAllData` or setup | Yes |
| Use case | App config, mapping tables | Feature flags per user/profile | Lookup tables (not deployable) | UI text, error messages |

**Rule of thumb**: Use CMT for anything that should travel with your deployment. Use Custom Settings for runtime toggles. Use Custom Labels for user-facing text.

## Custom Metadata Type

### Metadata Definition

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>API Endpoint Config</label>
    <pluralLabel>API Endpoint Configs</pluralLabel>
    <visibility>Public</visibility>
    <fields>
        <fullName>Endpoint_URL__c</fullName>
        <label>Endpoint URL</label>
        <type>Url</type>
        <required>true</required>
    </fields>
    <fields>
        <fullName>Timeout_Ms__c</fullName>
        <label>Timeout (ms)</label>
        <type>Number</type>
        <precision>5</precision>
        <scale>0</scale>
        <defaultValue>30000</defaultValue>
    </fields>
    <fields>
        <fullName>Is_Active__c</fullName>
        <label>Active</label>
        <type>Checkbox</type>
        <defaultValue>true</defaultValue>
    </fields>
</CustomObject>
```

### CMT Record

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Stripe</label>
    <protected>false</protected>
    <values>
        <field>Endpoint_URL__c</field>
        <value>https://api.stripe.com/v1</value>
    </values>
    <values>
        <field>Timeout_Ms__c</field>
        <value>15000</value>
    </values>
    <values>
        <field>Is_Active__c</field>
        <value>true</value>
    </values>
</CustomMetadata>
```

### Access in Apex (no SOQL)

```apex
// Get all records (cached, no SOQL)
Map<String, API_Endpoint_Config__mdt> configs =
    API_Endpoint_Config__mdt.getAll();

// Get specific record by DeveloperName
API_Endpoint_Config__mdt stripe =
    API_Endpoint_Config__mdt.getInstance('Stripe');

String endpoint = stripe.Endpoint_URL__c;
Integer timeout = (Integer) stripe.Timeout_Ms__c;
```

## Custom Settings

### Hierarchy Custom Setting (per-user/profile)

```apex
// Define: Feature_Flags__c with Checkbox fields

// Access (checks User → Profile → Org default)
Feature_Flags__c flags = Feature_Flags__c.getInstance();
if (flags.Enable_New_UI__c) {
    // new feature logic
}

// Access for specific user
Feature_Flags__c userFlags = Feature_Flags__c.getInstance(userId);
```

### List Custom Setting

```apex
// Access all records
Map<String, Country_Config__c> countries = Country_Config__c.getAll();
Country_Config__c us = Country_Config__c.getInstance('US');
```

## Custom Labels

### Define in Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomLabels xmlns="http://soap.sforce.com/2006/04/metadata">
    <labels>
        <fullName>Error_Record_Not_Found</fullName>
        <language>en_US</language>
        <protected>false</protected>
        <shortDescription>Record not found error</shortDescription>
        <value>The requested record could not be found.</value>
    </labels>
</CustomLabels>
```

### Access

```apex
// Apex
String msg = Label.Error_Record_Not_Found;

// LWC
import ERROR_MSG from '@salesforce/label/c.Error_Record_Not_Found';

// Formula
$Label.c.Error_Record_Not_Found
```

## Feature Flag Pattern

```apex
public class FeatureFlags {
    public static Boolean isEnabled(String featureName) {
        Feature_Flag__mdt flag = Feature_Flag__mdt.getInstance(featureName);
        return flag != null && flag.Is_Enabled__c;
    }
}

// Usage:
if (FeatureFlags.isEnabled('New_Pricing_Engine')) {
    // new logic
} else {
    // legacy logic
}
```

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Hardcoded values in Apex | Use CMT or Custom Labels |
| Custom Setting for deployable config | Use CMT instead (deployable) |
| SOQL query for CMT records | Use `getAll()` / `getInstance()` (free) |
| Custom Label for non-user text | Use CMT for internal config |
| CMT for per-user settings | Use Hierarchy Custom Setting |

## Cross-Skill References

- For custom objects: see **sf-metadata**
- For Apex usage patterns: see **sf-apex**
- For deployment: see **sf-deploy**
