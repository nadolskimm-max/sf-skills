---
name: sf-commerce
description: >
  Builds Salesforce B2B and B2C Commerce storefronts including product
  catalogs, carts, checkout flows, pricing, and order management. Use
  when configuring Commerce Cloud storefronts, building custom commerce
  components, managing product catalogs, or integrating payment gateways.
  Do NOT use for standard Salesforce UI (use sf-lwc) or CPQ pricing
  (use sf-cpq).
---

# Salesforce Commerce Cloud

## Core Responsibilities

1. Configure B2B/B2C Commerce storefronts
2. Manage product catalogs, categories, and entitlements
3. Build custom checkout flows and cart components
4. Integrate payment gateways and tax engines
5. Configure order management and fulfillment

## Commerce Editions

| Edition | Target | Key Features |
|---|---|---|
| B2B Commerce | Business buyers | Account-based pricing, reorder, bulk |
| B2C Commerce (LWR) | Consumers | Self-service, guest checkout |
| D2C Commerce | Direct to consumer | Quick setup, templates |

## Commerce Data Model

```
Store (WebStore)
├── Product Catalog
│   ├── Product Category
│   │   └── Product Category Product
│   └── Product2
│       ├── Product Media
│       └── Product Attribute
├── Buyer Group
│   └── Buyer Account
├── Entitlement Policy
├── Price Book (Pricebook2)
│   └── Price Book Entry
├── Cart (WebCart)
│   └── Cart Item (CartItem)
├── Checkout Session
└── Order / Order Summary
    └── Order Item / Order Item Summary
```

## Key Objects

| Object | Description |
|---|---|
| WebStore | The storefront configuration |
| ProductCatalog | Container for product categories |
| ProductCategory | Hierarchical product grouping |
| WebCart | Shopping cart |
| CartItem | Individual item in cart |
| OrderSummary | Post-checkout order record |
| FulfillmentOrder | Fulfillment tracking |

## Product Catalog Queries

```sql
-- Products in a category
SELECT Id, Product2.Name, Product2.Description,
       ProductCategory.Name
FROM ProductCategoryProduct
WHERE ProductCategory.Name = 'Electronics'

-- Cart items for a buyer
SELECT Id, Product2.Name, Quantity, TotalPrice
FROM CartItem
WHERE WebCart.AccountId = :accountId
  AND WebCart.Status = 'Active'

-- Order history
SELECT Id, OrderNumber, Status, TotalAmount,
    (SELECT Id, Product2.Name, Quantity, TotalPrice
     FROM OrderItemSummaries)
FROM OrderSummary
WHERE AccountId = :accountId
ORDER BY CreatedDate DESC
```

## Custom Commerce LWC

Commerce components use special targets:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__CommerceWebStore</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__CommerceWebStore">
            <property name="heading" type="String" label="Heading"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

## Checkout Flow Customization

```
Cart Review
├── Validate inventory availability
├── Apply promotions / coupons
├── Calculate shipping
├── Calculate tax (external tax engine)
├── Payment capture (payment gateway)
└── Place Order → Create OrderSummary
```

## Payment Gateway Integration

```apex
// Custom payment gateway adapter
global class MyPaymentGatewayAdapter implements commercepayments.PaymentGatewayAdapter {
    global commercepayments.GatewayResponse processRequest(
        commercepayments.paymentGatewayContext gatewayContext
    ) {
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();

        if (requestType == commercepayments.RequestType.Authorize) {
            return processAuthorization(gatewayContext);
        } else if (requestType == commercepayments.RequestType.Capture) {
            return processCapture(gatewayContext);
        }
        return new commercepayments.GatewayErrorResponse('400', 'Unsupported request');
    }
}
```

## CLI Commands

```bash
# Retrieve store metadata
sf project retrieve start --metadata ExperienceBundle --target-org <alias>

# Index products for search
sf commerce store index --store-name "My Store" --target-org <alias>
```

## Cross-Skill References

- For storefront LWC: see **sf-lwc**
- For product data: see **sf-data**
- For payment integration: see **sf-integration**
- For Experience Cloud sites: see **sf-experience-cloud**
