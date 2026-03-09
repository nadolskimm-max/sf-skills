---
name: sf-api-design
description: >
  Designs and implements custom REST and SOAP APIs exposed from Salesforce
  using @RestResource, @HttpGet, @WebService, and Composite API patterns.
  Use when building custom endpoints, designing API contracts, versioning
  APIs, or creating Composite/Batch request handlers. Do NOT use for
  outbound callouts (use sf-integration) or Connected App OAuth
  (use sf-connected-apps).
---

# Custom API Design

## Core Responsibilities

1. Create custom REST endpoints with `@RestResource`
2. Build SOAP web services with `@WebService`
3. Design request/response contracts with proper error handling
4. Implement API versioning strategies
5. Use standard REST/Composite/Batch APIs effectively

## Custom REST API

### Basic Endpoint

```apex
@RestResource(urlMapping='/api/invoices/*')
global with sharing class InvoiceApi {

    @HttpGet
    global static void getInvoice() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String invoiceId = req.requestURI.substringAfterLast('/');

        try {
            Invoice__c inv = [
                SELECT Id, Name, Amount__c, Status__c, Account__r.Name
                FROM Invoice__c
                WHERE Id = :invoiceId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(new ApiResponse(true, inv)));
        } catch (QueryException e) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ApiResponse(false, 'Invoice not found')
            ));
        }
    }

    @HttpPost
    global static void createInvoice() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            Map<String, Object> body = (Map<String, Object>)
                JSON.deserializeUntyped(req.requestBody.toString());

            Invoice__c inv = new Invoice__c(
                Amount__c = (Decimal) body.get('amount'),
                Status__c = 'Draft',
                Account__c = (String) body.get('accountId')
            );
            insert inv;

            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ApiResponse(true, inv)
            ));
        } catch (Exception e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ApiResponse(false, e.getMessage())
            ));
        }
    }

    @HttpPatch
    global static void updateInvoice() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String invoiceId = req.requestURI.substringAfterLast('/');

        try {
            Map<String, Object> body = (Map<String, Object>)
                JSON.deserializeUntyped(req.requestBody.toString());

            Invoice__c inv = new Invoice__c(Id = invoiceId);
            if (body.containsKey('amount')) {
                inv.Amount__c = (Decimal) body.get('amount');
            }
            if (body.containsKey('status')) {
                inv.Status__c = (String) body.get('status');
            }
            update inv;

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ApiResponse(true, inv)
            ));
        } catch (Exception e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ApiResponse(false, e.getMessage())
            ));
        }
    }

    @HttpDelete
    global static void deleteInvoice() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String invoiceId = req.requestURI.substringAfterLast('/');

        try {
            delete new Invoice__c(Id = invoiceId);
            res.statusCode = 204;
        } catch (Exception e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new ApiResponse(false, e.getMessage())
            ));
        }
    }

    global class ApiResponse {
        public Boolean success;
        public Object data;
        public String error;

        public ApiResponse(Boolean success, Object data) {
            this.success = success;
            if (success) { this.data = data; }
            else { this.error = String.valueOf(data); }
        }
    }
}
```

### Endpoint URL

```
POST https://<instance>.salesforce.com/services/apexrest/api/invoices
GET  https://<instance>.salesforce.com/services/apexrest/api/invoices/<id>
```

## Standard REST API Patterns

### Composite API (up to 25 subrequests)

```json
POST /services/data/v62.0/composite
{
    "compositeRequest": [
        {
            "method": "POST",
            "url": "/services/data/v62.0/sobjects/Account",
            "referenceId": "newAccount",
            "body": { "Name": "Acme Corp" }
        },
        {
            "method": "POST",
            "url": "/services/data/v62.0/sobjects/Contact",
            "referenceId": "newContact",
            "body": {
                "FirstName": "John",
                "LastName": "Doe",
                "AccountId": "@{newAccount.id}"
            }
        }
    ]
}
```

### Batch API (up to 25 independent requests)

```json
POST /services/data/v62.0/composite/batch
{
    "batchRequests": [
        { "method": "GET", "url": "v62.0/sobjects/Account/001xx000003ABC" },
        { "method": "GET", "url": "v62.0/sobjects/Contact/003xx000004DEF" }
    ]
}
```

## API Design Best Practices

| Practice | Detail |
|---|---|
| Always return JSON with consistent structure | `{ success, data, error }` |
| Use proper HTTP status codes | 200, 201, 204, 400, 401, 404, 500 |
| Enforce `WITH SECURITY_ENFORCED` | Every query in API endpoints |
| Validate input before DML | Check required fields, types |
| Use `global` access modifier | Required for `@RestResource` |
| Set `Content-Type` header | `application/json` |
| Version your URL | `/api/v1/invoices` vs `/api/v2/invoices` |

## Cross-Skill References

- For outbound callouts: see **sf-integration**
- For OAuth authentication: see **sf-connected-apps**
- For Apex patterns: see **sf-apex**
- For testing REST endpoints: see **sf-testing**
