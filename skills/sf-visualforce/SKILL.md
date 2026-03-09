---
name: sf-visualforce
description: >
  Maintains Salesforce Visualforce pages and plans migration to LWC.
  Use when working with existing VF pages, VF controllers, PDF generation
  via VF, or planning VF-to-LWC migration strategy. Do NOT use for new
  UI development (use sf-lwc — Visualforce is legacy). Do NOT use for
  Aura migration (use sf-aura).
---

# Visualforce & Migration

## Core Responsibilities

1. Maintain existing Visualforce pages and controllers
2. Plan VF-to-LWC migration
3. Handle VF-specific use cases (PDF generation, email templates)
4. Fix security issues in VF pages (XSS, CSRF)
5. Embed LWC inside Visualforce pages

## VF Use Cases Still Valid

| Use Case | VF Still Needed? | LWC Alternative |
|---|---|---|
| PDF generation (`renderAs="pdf"`) | Yes — no LWC equivalent | Use VF for PDF, LWC for UI |
| Complex email templates with HTML | Partial — Lightning templates limited | VF email templates for complex HTML |
| Override standard buttons | No — use LWC Quick Actions | Migrate |
| Custom tabs/pages | No — use LWC | Migrate |
| Canvas apps | Yes — Canvas requires VF | Keep VF |
| Flow screens | No — use LWC screen components | Migrate |

## VF Page Structure

```xml
<apex:page controller="InvoiceController" renderAs="pdf" applyBodyTag="false">
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; }
            table { width: 100%; border-collapse: collapse; }
            th, td { border: 1px solid #ddd; padding: 8px; }
        </style>
    </head>
    <body>
        <h1>Invoice: {!invoice.Name}</h1>
        <p>Date: {!TODAY()}</p>
        <table>
            <tr>
                <th>Item</th><th>Qty</th><th>Price</th>
            </tr>
            <apex:repeat value="{!lineItems}" var="item">
                <tr>
                    <td>{!item.Product__r.Name}</td>
                    <td>{!item.Quantity__c}</td>
                    <td>{!item.Total__c}</td>
                </tr>
            </apex:repeat>
        </table>
        <p><strong>Total: {!invoice.Total_Amount__c}</strong></p>
    </body>
    </html>
</apex:page>
```

## VF Controller

```apex
public with sharing class InvoiceController {
    public Invoice__c invoice { get; set; }
    public List<Invoice_Line_Item__c> lineItems { get; set; }

    public InvoiceController() {
        String invoiceId = ApexPages.currentPage().getParameters().get('id');
        invoice = [
            SELECT Id, Name, Total_Amount__c, Account__r.Name
            FROM Invoice__c
            WHERE Id = :invoiceId
            WITH SECURITY_ENFORCED
        ];
        lineItems = [
            SELECT Id, Product__r.Name, Quantity__c, Total__c
            FROM Invoice_Line_Item__c
            WHERE Invoice__c = :invoiceId
            WITH SECURITY_ENFORCED
        ];
    }
}
```

## Security Fixes

### XSS Prevention

```xml
<!-- BAD: unescaped output -->
<apex:outputText value="{!userInput}" escape="false"/>

<!-- GOOD: escaped by default -->
<apex:outputText value="{!userInput}"/>

<!-- GOOD: explicit encoding in formulas -->
{!HTMLENCODE(userInput)}
{!JSENCODE(userInput)}
{!URLENCODE(userInput)}
```

### CSRF Protection

```xml
<!-- VF forms have built-in CSRF tokens -->
<apex:form>
    <apex:commandButton value="Save" action="{!save}"/>
</apex:form>

<!-- Remote actions — use $RemoteAction for CSRF token -->
Visualforce.remoting.Manager.invokeAction(
    '{!$RemoteAction.MyController.doSomething}',
    param1, callback, { escape: true }
);
```

## Embed LWC in Visualforce

```xml
<apex:page>
    <apex:includeLightning/>

    <div id="lwc-container"></div>

    <script>
        $Lightning.use("c:lwcApp", function() {
            $Lightning.createComponent("c:myComponent",
                { recordId: "{!recordId}" },
                "lwc-container"
            );
        });
    </script>
</apex:page>
```

## Migration Workflow

```
1. INVENTORY: List all VF pages, categorize (PDF, UI, email, canvas)
2. IDENTIFY: Mark PDF/canvas pages as "keep VF"
3. MIGRATE: Rewrite UI-only pages as LWC
4. TEST: Verify functionality parity
5. REDIRECT: Update navigation, tabs, overrides to LWC
6. DEPRECATE: Mark old VF pages as inactive
```

## Cross-Skill References

- For LWC development: see **sf-lwc**
- For Apex controllers: see **sf-apex**
- For security review: see **sf-security**
- For deployment: see **sf-deploy**
