---
name: sf-cpq
description: >
  Configures Salesforce CPQ (Configure, Price, Quote) including product
  bundles, price rules, discount schedules, quote templates, and
  advanced approvals. Use when setting up CPQ products, building pricing
  logic, creating quote templates, or troubleshooting CPQ calculations.
  Do NOT use for standard Opportunity products (use sf-cloud-sales) or
  general Apex (use sf-apex).
---

# Salesforce CPQ

## Core Responsibilities

1. Configure product bundles and options
2. Build price rules and discount schedules
3. Create quote templates and document generation
4. Set up advanced approvals for quotes
5. Troubleshoot CPQ calculation and performance

## CPQ Data Model

```
Quote (SBQQ__Quote__c)
├── Quote Line (SBQQ__QuoteLine__c)
│   ├── Product (Product2)
│   │   ├── Product Option (SBQQ__ProductOption__c)
│   │   └── Product Feature (SBQQ__ProductFeature__c)
│   ├── Price Rule (SBQQ__PriceRule__c)
│   └── Discount Schedule (SBQQ__DiscountSchedule__c)
├── Quote Template (SBQQ__QuoteTemplate__c)
└── Subscription (SBQQ__Subscription__c)
```

## Product Configuration

### Bundle Structure

| Component | Description |
|---|---|
| Bundle Product | Parent product containing options |
| Product Feature | Grouping of options (e.g., "Add-Ons") |
| Product Option | Individual items within a feature |
| Option Constraint | Rules for required/excluded combinations |

### Option Types

| Type | Behavior |
|---|---|
| Component | Always included in bundle |
| Accessory | Optional, can be added/removed |
| Related Product | Suggested, independent pricing |

## Price Rules

### Price Rule Structure

```
Price Rule (SBQQ__PriceRule__c)
├── Conditions (SBQQ__PriceCondition__c)
│   ├── Object: Quote Line
│   ├── Field: SBQQ__Product__r.Family
│   ├── Operator: equals
│   └── Value: "Enterprise"
└── Actions (SBQQ__PriceAction__c)
    ├── Target Object: Quote Line
    ├── Target Field: SBQQ__Discount__c
    └── Value: 10
```

### Price Rule Types

| Type | Evaluation | Use Case |
|---|---|---|
| Calculator | During price calculation | Automatic discounts, surcharges |
| Configurator | During product configuration | Bundle option pricing |

## Discount Schedules

| Schedule Type | Description |
|---|---|
| Range | Discount by quantity range (1-10: 5%, 11-50: 10%) |
| Slab | Different discount per tier (first 10 at 5%, next 40 at 10%) |
| Term | Discount by subscription term (1yr: 0%, 2yr: 10%, 3yr: 15%) |

## Quote Templates

Quote templates generate PDF documents:

| Section | Content |
|---|---|
| Header | Company logo, quote number, date |
| Customer Info | Account name, contact, address |
| Line Items | Products, quantities, prices |
| Totals | Subtotal, discount, tax, total |
| Terms | Payment terms, validity period |
| Signature | Electronic signature block |

## CPQ Apex Hooks

```apex
// Quote Calculator Plugin
global class MyCalculatorPlugin implements SBQQ.QuoteCalculatorPlugin2 {
    global void onInit(SBQQ.QuoteCalculatorPlugin2.QuoteLineCalculatorPluginContext context) {}
    global void onBeforeCalculate(SBQQ.QuoteCalculatorPlugin2.QuoteCalculatorPluginContext context) {}
    global void onAfterCalculate(SBQQ.QuoteCalculatorPlugin2.QuoteCalculatorPluginContext context) {
        // Custom post-calculation logic
    }
}
```

## Common CPQ Queries

```sql
-- Quotes with line items
SELECT Id, Name, SBQQ__Status__c, SBQQ__NetAmount__c,
    (SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c, SBQQ__NetTotal__c
     FROM SBQQ__LineItems__r)
FROM SBQQ__Quote__c
WHERE SBQQ__Opportunity2__c = :oppId

-- Active price rules
SELECT Id, Name, SBQQ__Active__c, SBQQ__EvaluationEvent__c
FROM SBQQ__PriceRule__c
WHERE SBQQ__Active__c = true
```

## Performance Tips

- Limit product options per bundle to < 200
- Use Price Rule conditions to scope rules narrowly
- Minimize Calculator Plugin complexity
- Cache frequently used configuration data
- Use Quote Line Groups for large quotes (> 100 lines)

## Cross-Skill References

- For standard products: see **sf-cloud-sales**
- For approval processes: see **sf-approval**
- For CPQ Apex plugins: see **sf-apex**
- For deployment: see **sf-deploy**
