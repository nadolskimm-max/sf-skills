# Apex Patterns Reference

## Trigger Actions Framework (TAF)

### Trigger (one per object)

```apex
trigger AccountTrigger on Account (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    new TriggerActionFlow().run();
}
```

### TAF Handler Class

```apex
public class TA_AccountBeforeInsert1 implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Account> newList) {
        for (Account acc : newList) {
            if (String.isBlank(acc.Industry)) {
                acc.Industry = 'Other';
            }
        }
    }
}
```

Register the handler in **Trigger_Action__mdt** custom metadata:
- Apex_Class_Name: `TA_AccountBeforeInsert1`
- Object__c: `Account`
- Flow_Process_Type__c: (blank for Apex)
- Order__c: `1`
- Bypass_Execution__c: `false`

## Bulkification Patterns

### Map-Based Lookup (avoid SOQL in loop)

```apex
Set<Id> accountIds = new Set<Id>();
for (Contact c : Trigger.new) {
    accountIds.add(c.AccountId);
}
Map<Id, Account> accountMap = new Map<Id, Account>(
    [SELECT Id, Name, Industry FROM Account WHERE Id IN :accountIds]
);
for (Contact c : Trigger.new) {
    Account acc = accountMap.get(c.AccountId);
    if (acc != null) {
        c.Description = 'Account: ' + acc.Name;
    }
}
```

### Collect-then-DML (avoid DML in loop)

```apex
List<Task> tasksToInsert = new List<Task>();
for (Opportunity opp : Trigger.new) {
    if (opp.StageName == 'Closed Won') {
        tasksToInsert.add(new Task(
            WhatId = opp.Id,
            Subject = 'Follow up on closed deal',
            OwnerId = opp.OwnerId
        ));
    }
}
if (!tasksToInsert.isEmpty()) {
    insert tasksToInsert;
}
```

## Batch Apex Template

```apex
public class LeadCleanupBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Integer processedCount = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Lead
            WHERE IsConverted = false AND CreatedDate < LAST_N_DAYS:365
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        delete scope;
        processedCount += scope.size();
    }

    public void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, 'Cleaned up ' + processedCount + ' leads');
    }
}
```

## Queueable Template

```apex
public class AccountSyncQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> accountIds;

    public AccountSyncQueueable(List<Id> accountIds) {
        this.accountIds = accountIds;
    }

    public void execute(QueueableContext context) {
        List<Account> accounts = [
            SELECT Id, Name, BillingCity FROM Account WHERE Id IN :accountIds
        ];
        // callout or processing logic here
    }
}
```

## Test Class Template

```apex
@IsTest
private class AccountServiceTest {
    @TestSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
    }

    @IsTest
    static void testBulkInsert() {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(200, accounts.size(), 'Should have created 200 accounts');
    }

    @IsTest
    static void testNegativeCase() {
        try {
            insert new Account(); // Name is required
            System.assert(false, 'Should have thrown DmlException');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('REQUIRED_FIELD_MISSING'),
                'Expected REQUIRED_FIELD_MISSING error');
        }
    }
}
```

## Governor Limits Quick Reference

| Limit | Synchronous | Asynchronous |
|---|---|---|
| SOQL queries | 100 | 200 |
| SOQL rows | 50,000 | 50,000 |
| DML statements | 150 | 150 |
| DML rows | 10,000 | 10,000 |
| CPU time | 10,000 ms | 60,000 ms |
| Heap size | 6 MB | 12 MB |
| Callouts | 100 | 100 |
| Future calls | 50 | 0 (in future) |
| Queueable jobs | 50 | 1 |
