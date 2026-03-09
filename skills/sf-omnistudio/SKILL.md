---
name: sf-omnistudio
description: >
  Builds Salesforce OmniStudio components including OmniScripts, FlexCards,
  DataRaptors, and Integration Procedures. Use when creating guided
  processes, building dynamic cards, configuring data transformations,
  or setting up integration procedures. Do NOT use for standard LWC
  (use sf-lwc) or standard Flows (use sf-flow).
---

# OmniStudio

## Core Responsibilities

1. Create OmniScripts for guided processes
2. Build FlexCards for dynamic data display
3. Configure DataRaptors for data transformation
4. Set up Integration Procedures for server-side orchestration
5. Deploy OmniStudio metadata

## Key Components

| Component | Description | Use Case |
|---|---|---|
| **OmniScript** | Multi-step guided process | Forms, wizards, onboarding |
| **FlexCard** | Dynamic data card | Record detail, dashlets |
| **DataRaptor** | Data transformation (ETL) | Extract, Transform, Load |
| **Integration Procedure** | Server-side orchestration | Callouts, multi-step logic |

## OmniScript Structure

```
OmniScript: Customer Onboarding
├── Step 1: Personal Info
│   ├── Text Block (Welcome)
│   ├── Text Input (First Name)
│   ├── Text Input (Last Name)
│   └── Email Input (Email)
├── Step 2: Address
│   ├── Address Input
│   └── Disclosure (Terms)
├── Step 3: Review
│   ├── FlexCard (Summary)
│   └── Checkbox (Confirm)
└── Step 4: Confirmation
    └── Text Block (Success message)
    └── DataRaptor Post Action (Save)
```

## DataRaptor Types

| Type | Direction | Description |
|---|---|---|
| Extract | Read | Queries Salesforce records into JSON |
| Transform | Map | Maps/transforms JSON data |
| Load | Write | Creates/updates Salesforce records |
| Turbo Extract | Read | High-performance extraction |

### DataRaptor Extract Example

```json
{
    "type": "Extract",
    "interfaceObject": "Account",
    "fields": [
        {"fieldName": "Id", "outputPath": "AccountId"},
        {"fieldName": "Name", "outputPath": "AccountName"},
        {"fieldName": "Industry", "outputPath": "Industry"},
        {"fieldName": "Contacts", "outputPath": "Contacts",
         "childFields": [
             {"fieldName": "FirstName", "outputPath": "FirstName"},
             {"fieldName": "LastName", "outputPath": "LastName"}
         ]}
    ],
    "filter": "Id = ':AccountId'"
}
```

## Integration Procedures

Server-side orchestration with multiple elements:

```
Integration Procedure: ProcessClaim
├── DataRaptor Extract: Get Claim Details
├── HTTP Action: Call External Validation API
├── Conditional Block: Is Valid?
│   ├── True: DataRaptor Load: Update Claim Status
│   └── False: Response Action: Return Error
└── DataRaptor Load: Create Activity Record
```

### Element Types

| Element | Description |
|---|---|
| DataRaptor Action | Read/write data |
| HTTP Action | External API callout |
| Conditional Block | If/else branching |
| Loop Block | Iterate over collections |
| Set Values | Assign/transform variables |
| Response Action | Return result to caller |
| Matrix Action | Decision table lookup |

## Deployment

```bash
# Retrieve OmniStudio metadata
sf project retrieve start --metadata OmniScript,OmniDataTransform,OmniIntegrationProcedure --target-org <alias>

# Deploy
sf project deploy start --metadata OmniScript,OmniDataTransform,OmniIntegrationProcedure --target-org <alias>
```

## Best Practices

- Keep OmniScripts under 10 steps for usability
- Use DataRaptor Turbo Extract for read-heavy operations
- Cache Integration Procedure results where appropriate
- Test with different user profiles for FLS compliance
- Use versioning: create new versions, don't modify active ones

## Cross-Skill References

- For standard LWC components: see **sf-lwc**
- For standard Flow automation: see **sf-flow**
- For API callouts in IPs: see **sf-integration**
- For deployment: see **sf-deploy**
