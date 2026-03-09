---
name: sf-testing
description: >
  Manages Apex test execution, code coverage analysis, and test data
  generation. Use when running tests, checking coverage, generating test
  classes, creating bulk test data (200+ records), or debugging test
  failures. Do NOT use for non-test Apex (use sf-apex) or Jest/LWC tests
  (use sf-lwc).
---

# Salesforce Apex Testing

## Core Responsibilities

1. Generate test classes with 90%+ code coverage
2. Run tests and analyze results via Salesforce CLI
3. Create bulk test data (200+ records for trigger testing)
4. Build mock frameworks for HTTP callouts
5. Diagnose test failures and isolation issues

## Test Class Structure

Every test class must:
- Be annotated with `@IsTest`
- Use `@TestSetup` for shared data across test methods
- Test bulk scenarios (200+ records minimum for triggers)
- Include positive, negative, and boundary test cases
- Use `System.assert*` with descriptive messages

## Workflow

### Phase 1 — Analyze

- Identify the class/trigger under test
- Map all code paths (if/else, try/catch, loops)
- Identify external dependencies (callouts, other objects)

### Phase 2 — Generate

```apex
@IsTest
private class MyServiceTest {
    @TestSetup
    static void setup() {
        // Create shared test data — runs once, rolled back after class
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test ' + i));
        }
        insert accounts;
    }

    @IsTest
    static void testPositiveCase() {
        // Arrange
        List<Account> accounts = [SELECT Id FROM Account];
        // Act
        Test.startTest();
        MyService.processAccounts(accounts);
        Test.stopTest();
        // Assert
        List<Account> updated = [SELECT Id, Status__c FROM Account];
        for (Account a : updated) {
            System.assertEquals('Processed', a.Status__c,
                'Account should be marked as Processed');
        }
    }

    @IsTest
    static void testNegativeCase() {
        // Test with empty list
        Test.startTest();
        MyService.processAccounts(new List<Account>());
        Test.stopTest();
        // No exception expected
    }

    @IsTest
    static void testBulkOperation() {
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(200, accounts.size(), 'Setup should create 200 records');
        Test.startTest();
        MyService.processAccounts(accounts);
        Test.stopTest();
        // Verify no governor limit exceptions
    }
}
```

### Phase 3 — Run

```bash
# Run specific test class
sf apex run test --class-names MyServiceTest --result-format human --code-coverage --target-org <alias>

# Run all tests
sf apex run test --test-level RunLocalTests --result-format human --code-coverage --target-org <alias>

# Run specific test method
sf apex run test --tests MyServiceTest.testPositiveCase --result-format human --target-org <alias>

# Get coverage for specific class
sf apex get test --test-run-id <id> --code-coverage --target-org <alias>
```

## HTTP Callout Mock

```apex
@IsTest
private class ExternalServiceTest {
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    @IsTest
    static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        String result = ExternalService.callApi();
        Test.stopTest();
        System.assertEquals('success', result, 'Should parse API response');
    }
}
```

## Coverage Targets

| Deployment Target | Minimum Coverage |
|---|---|
| Production | 75% overall, each trigger > 1% |
| Best Practice | 90%+ per class |
| Scratch Org | No minimum (but aim for 90%+) |

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| `SeeAllData=true` | Remove — create test data in `@TestSetup` |
| Testing only with 1 record | Use 200+ records for trigger tests |
| No assertions | Every test method must assert expected outcomes |
| Hardcoded record IDs | Query or create records in test setup |
| Missing `Test.startTest()/stopTest()` | Wrap the action under test to reset governor limits |

## Cross-Skill References

- For test class templates: see **sf-apex**
- For test data factories: see **sf-data**
- For Jest/LWC tests: see **sf-lwc**
