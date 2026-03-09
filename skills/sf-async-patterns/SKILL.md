---
name: sf-async-patterns
description: >
  Implements advanced asynchronous Apex patterns including Queueable
  chaining, batch orchestration, Finalizers, Platform Event-driven
  async, and scheduled job management. Use when designing complex async
  workflows, chaining jobs, handling async error recovery, or choosing
  between Future/Queueable/Batch/Scheduled. Do NOT use for basic
  Apex (use sf-apex) or Platform Events messaging (use sf-integration).
---

# Asynchronous Apex Patterns

## Core Responsibilities

1. Design async job chains (Queueable → Queueable)
2. Implement batch orchestration (batch → batch)
3. Use Finalizers for error recovery and cleanup
4. Choose the correct async pattern for each use case
5. Monitor and manage async job execution

## Async Pattern Selection

| Pattern | Max Records | Chaining | Callouts | Use Case |
|---|---|---|---|---|
| `@future` | Small (< 200) | No | With flag | Simple fire-and-forget |
| `Queueable` | Medium | Yes (1 child) | With interface | Complex logic, chaining |
| `Batch` | Millions | Via finish() | With interface | Large data processing |
| `Schedulable` | N/A (triggers batch) | Launches batch | No | Time-based triggers |
| Platform Event | Unlimited | Via trigger | Yes (in subscriber) | Event-driven async |

## Queueable Chaining

### Basic Chain

```apex
public class Step1Queueable implements Queueable {
    private List<Id> recordIds;

    public Step1Queueable(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    public void execute(QueueableContext context) {
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :recordIds];
        // Process accounts...

        // Chain to next step
        if (!Test.isRunningTest()) {
            System.enqueueJob(new Step2Queueable(recordIds));
        }
    }
}
```

### Chaining with Depth Tracking

```apex
public class ChainableJob implements Queueable {
    private Integer depth;
    private List<List<Id>> batches;
    private static final Integer MAX_DEPTH = 5;

    public ChainableJob(List<List<Id>> batches, Integer depth) {
        this.batches = batches;
        this.depth = depth;
    }

    public void execute(QueueableContext context) {
        if (batches.isEmpty() || depth >= MAX_DEPTH) return;

        List<Id> currentBatch = batches.remove(0);
        // Process currentBatch...

        if (!batches.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new ChainableJob(batches, depth + 1));
        }
    }
}
```

## Finalizers (Transaction Finalizer)

Finalizers run after a Queueable completes, even on failure:

```apex
public class MyQueueable implements Queueable {
    public void execute(QueueableContext context) {
        System.attachFinalizer(new MyFinalizer());
        // Main logic that might fail...
    }
}

public class MyFinalizer implements Finalizer {
    public void execute(FinalizerContext context) {
        switch on context.getResult() {
            when SUCCESS {
                System.debug('Job completed successfully');
            }
            when UNHANDLED_EXCEPTION {
                String error = context.getException().getMessage();
                // Log error, send notification, or retry
                insert new Async_Job_Log__c(
                    Status__c = 'Failed',
                    Error_Message__c = error,
                    Job_Id__c = context.getAsyncApexJobId()
                );

                // Retry (re-enqueue)
                System.enqueueJob(new MyQueueable());
            }
        }
    }
}
```

## Batch Orchestration

### Batch Chain via finish()

```apex
public class Step1Batch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Account WHERE NeedsProcessing__c = true
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // Process records
    }

    public void finish(Database.BatchableContext bc) {
        // Launch next batch in chain
        Database.executeBatch(new Step2Batch(), 200);
    }
}
```

### Batch with Error Tracking (Database.Stateful)

```apex
public class RobustBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<String> errors = new List<String>();
    private Integer successCount = 0;
    private Integer failCount = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name FROM Account]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Database.SaveResult> results = Database.update(scope, false);
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                successCount++;
            } else {
                failCount++;
                for (Database.Error err : results[i].getErrors()) {
                    errors.add(scope[i].Id + ': ' + err.getMessage());
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!errors.isEmpty()) {
            insert new Batch_Log__c(
                Success_Count__c = successCount,
                Fail_Count__c = failCount,
                Errors__c = String.join(errors, '\n').left(131072)
            );
        }
    }
}
```

## Platform Event-Driven Async

Use Platform Events to decouple and parallelize:

```apex
// Publisher (in trigger/service)
EventBus.publish(new Process_Request__e(
    Record_Id__c = accountId,
    Action__c = 'sync_external'
));

// Subscriber trigger (runs in its own transaction)
trigger ProcessRequestTrigger on Process_Request__e (after insert) {
    for (Process_Request__e event : Trigger.new) {
        if (event.Action__c == 'sync_external') {
            System.enqueueJob(new ExternalSyncQueueable(event.Record_Id__c));
        }
    }
}
```

## Scheduled Jobs

```apex
public class DailyCleanupScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CleanupBatch(), 200);
    }
}

// Schedule via Apex
String cronExp = '0 0 2 * * ?'; // Daily at 2 AM
System.schedule('Daily Cleanup', cronExp, new DailyCleanupScheduler());
```

### Cron Expression Reference

| Expression | Schedule |
|---|---|
| `0 0 * * * ?` | Every hour |
| `0 0 2 * * ?` | Daily at 2 AM |
| `0 0 8 ? * MON-FRI` | Weekdays at 8 AM |
| `0 0 0 1 * ?` | First of every month |

## Monitoring

```bash
# Check async job status
sf data query --query "SELECT Id, JobType, Status, NumberOfErrors, TotalJobItems FROM AsyncApexJob WHERE Status != 'Completed' ORDER BY CreatedDate DESC LIMIT 20" --target-org <alias>
```

## Cross-Skill References

- For basic Apex patterns: see **sf-apex**
- For Platform Events: see **sf-integration**
- For batch testing: see **sf-testing**
- For performance: see **sf-performance**
