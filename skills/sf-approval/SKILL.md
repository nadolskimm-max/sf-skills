---
name: sf-approval
description: >
  Creates and manages Salesforce approval processes including multi-step
  approvals, email alerts, field updates, and outbound messages. Use when
  building approval workflows, configuring approval steps and actions,
  or troubleshooting approval routing. Do NOT use for Flow-based approvals
  (use sf-flow) or Apex-only automation (use sf-apex).
---

# Salesforce Approval Processes

## Core Responsibilities

1. Design multi-step approval processes
2. Configure approval actions (email alerts, field updates, outbound messages)
3. Set up approval routing (hierarchical, queue-based, manual)
4. Build approval-related Apex (submit, approve, reject programmatically)
5. Troubleshoot approval routing issues

## Approval Process Architecture

```
Record Submitted
  → Entry Criteria (filter)
  → Step 1: Approval (approver assignment)
    → Approved → Step 2 (optional)
    → Rejected → Rejection Actions
  → Final Approval Actions
    → Field Update (Status = 'Approved')
    → Email Alert to submitter
  → Final Rejection Actions
    → Field Update (Status = 'Rejected')
    → Email Alert to submitter
```

## Approval Process Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApprovalProcess xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Invoice_Approval</fullName>
    <active>true</active>
    <label>Invoice Approval</label>
    <description>Multi-step approval for invoices over $1000</description>
    <recordEditability>AdminOrCurrentApprover</recordEditability>
    <showApprovalHistory>true</showApprovalHistory>

    <entryCriteria>
        <criteriaItems>
            <field>Invoice__c.Amount__c</field>
            <operation>greaterOrEqual</operation>
            <value>1000</value>
        </criteriaItems>
    </entryCriteria>

    <approvalStep>
        <name>Manager_Approval</name>
        <label>Manager Approval</label>
        <assignedApprover>
            <approver>
                <type>userHierarchyField</type>
                <name>Manager</name>
            </approver>
        </assignedApprover>
        <approvalActions>
            <action>
                <name>Update_Status_Pending_Finance</name>
                <type>FieldUpdate</type>
            </action>
        </approvalActions>
        <rejectionActions>
            <action>
                <name>Update_Status_Rejected</name>
                <type>FieldUpdate</type>
            </action>
            <action>
                <name>Email_Rejection_Notice</name>
                <type>Alert</type>
            </action>
        </rejectionActions>
    </approvalStep>

    <finalApprovalActions>
        <action>
            <name>Update_Status_Approved</name>
            <type>FieldUpdate</type>
        </action>
        <action>
            <name>Email_Approval_Confirmation</name>
            <type>Alert</type>
        </action>
    </finalApprovalActions>

    <finalRejectionActions>
        <action>
            <name>Update_Status_Rejected</name>
            <type>FieldUpdate</type>
        </action>
    </finalRejectionActions>
</ApprovalProcess>
```

## Apex Programmatic Approval

### Submit for Approval

```apex
Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
req.setObjectId(invoice.Id);
req.setSubmitterId(UserInfo.getUserId());
req.setComments('Submitting invoice for approval');
req.setProcessDefinitionNameOrId('Invoice_Approval');
Approval.ProcessResult result = Approval.process(req);
System.assert(result.isSuccess(), 'Approval submission failed');
```

### Approve/Reject

```apex
List<ProcessInstanceWorkitem> workItems = [
    SELECT Id FROM ProcessInstanceWorkitem
    WHERE ProcessInstance.TargetObjectId = :invoice.Id
];

Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
req.setWorkitemId(workItems[0].Id);
req.setAction('Approve'); // or 'Reject'
req.setComments('Approved by automation');
Approval.ProcessResult result = Approval.process(req);
```

### Check Approval Status

```apex
List<ProcessInstance> approvals = [
    SELECT Id, Status, CompletedDate,
        (SELECT Id, StepStatus, ActorId, Comments FROM StepsAndWorkitems)
    FROM ProcessInstance
    WHERE TargetObjectId = :recordId
    ORDER BY CreatedDate DESC
    LIMIT 1
];
```

## Approver Assignment Types

| Type | Description |
|---|---|
| User Hierarchy Field | Manager of submitter (e.g., `Manager`) |
| Queue | Assigned to a queue for any member to approve |
| Related User | Field on the record (e.g., `OwnerId`) |
| Specific User | Hardcoded user (avoid in production) |
| Post to Chatter Group | Notification only, manual action |

## Best Practices

- Use field update to lock record during approval (`recordEditability`)
- Always include email alerts for submitter on approval/rejection
- Use `Recall` actions to allow submitters to withdraw
- Test with different user roles to verify routing
- Add approval history related list to page layouts

## Cross-Skill References

- For email templates in alerts: see **sf-email**
- For Flow-based approvals: see **sf-flow**
- For Apex approval logic: see **sf-apex**
- For deployment: see **sf-deploy**
