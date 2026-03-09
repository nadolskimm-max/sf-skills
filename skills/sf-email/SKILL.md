---
name: sf-email
description: >
  Creates and manages Salesforce email functionality including Lightning
  email templates, email alerts, email services, and org-wide email
  addresses. Use when building email templates, configuring email alerts
  for workflows/approvals, setting up inbound email services, or
  troubleshooting email deliverability. Do NOT use for Messaging/Chat
  (use sf-cloud-service) or Platform Events (use sf-integration).
---

# Salesforce Email

## Core Responsibilities

1. Create Lightning email templates with merge fields
2. Configure email alerts for automation
3. Set up inbound email services (Email-to-Case, custom handlers)
4. Manage org-wide email addresses
5. Send emails programmatically from Apex

## Lightning Email Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<EmailTemplate xmlns="http://soap.sforce.com/2006/04/metadata">
    <name>Invoice_Approved</name>
    <available>true</available>
    <description>Notification when invoice is approved</description>
    <encodingKey>UTF-8</encodingKey>
    <subject>Invoice {!Invoice__c.Name} Approved</subject>
    <type>custom</type>
    <uiType>SFX</uiType>
    <textOnly>Your invoice {!Invoice__c.Name} for {!Invoice__c.Amount__c} has been approved.</textOnly>
</EmailTemplate>
```

## Email Alert Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<WorkflowAlert xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Email_Invoice_Approved</fullName>
    <description>Send approval notification</description>
    <protected>false</protected>
    <recipients>
        <type>owner</type>
    </recipients>
    <recipients>
        <field>Contact__c</field>
        <type>contactLookup</type>
    </recipients>
    <senderAddress>invoices@example.com</senderAddress>
    <senderType>OrgWideEmailAddress</senderType>
    <template>Invoice_Approved</template>
</WorkflowAlert>
```

## Apex Email

### Single Email

```apex
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(new List<String>{'user@example.com'});
mail.setSubject('Invoice ' + invoice.Name + ' Approved');
mail.setPlainTextBody('Your invoice has been approved.');
mail.setOrgWideEmailAddressId(orgWideId);
mail.setSaveAsActivity(true);

Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
for (Messaging.SendEmailResult result : results) {
    if (!result.isSuccess()) {
        for (Messaging.SendEmailError err : result.getErrors()) {
            System.debug(LoggingLevel.ERROR, 'Email error: ' + err.getMessage());
        }
    }
}
```

### Template-Based Email

```apex
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setTemplateId(templateId);
mail.setTargetObjectId(contactId); // Who variable resolves to
mail.setWhatId(invoiceId);         // Related record for merge fields
mail.setOrgWideEmailAddressId(orgWideId);
Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
```

### Mass Email

```apex
Messaging.MassEmailMessage massEmail = new Messaging.MassEmailMessage();
massEmail.setTargetObjectIds(contactIds); // up to 5,000
massEmail.setTemplateId(templateId);
Messaging.sendEmail(new List<Messaging.MassEmailMessage>{massEmail});
```

## Inbound Email Service

```apex
global class InvoiceEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope
    ) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try {
            Invoice__c inv = new Invoice__c(
                Name = email.subject,
                Description__c = email.plainTextBody,
                Source__c = 'Email'
            );
            insert inv;

            if (email.binaryAttachments != null) {
                List<ContentVersion> files = new List<ContentVersion>();
                for (Messaging.InboundEmail.BinaryAttachment att : email.binaryAttachments) {
                    files.add(new ContentVersion(
                        Title = att.fileName,
                        PathOnClient = att.fileName,
                        VersionData = att.body,
                        FirstPublishLocationId = inv.Id
                    ));
                }
                insert files;
            }
            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.message = e.getMessage();
        }
        return result;
    }
}
```

## Email Limits

| Limit | Value |
|---|---|
| Single emails per day (Apex) | 5,000 |
| Mass emails per day | Varies by org edition |
| Email attachments total size | 25 MB per email |
| Email template merge fields | Up to 3 levels of cross-object |
| Org-wide email addresses | 25 per org |

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Sending email in a loop | Collect messages in list, single `sendEmail` call |
| No org-wide address | Configure org-wide to control sender identity |
| Hardcoded email addresses | Use Custom Metadata or Custom Labels |
| No `setSaveAsActivity(true)` | Always save as activity for audit trail |
| Email in trigger without null check | Check if recipients exist before sending |

## Cross-Skill References

- For email alerts in approvals: see **sf-approval**
- For email alerts in flows: see **sf-flow**
- For Apex email code: see **sf-apex**
- For email template deployment: see **sf-deploy**
