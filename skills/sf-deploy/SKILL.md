---
name: sf-deploy
description: >
  Automates Salesforce metadata deployment using Salesforce CLI v2.
  Use when deploying metadata to orgs, running deploy validations,
  managing scratch orgs, creating packages, or troubleshooting deployment
  errors. Do NOT use for writing Apex/Flow/LWC code (use respective skills)
  or metadata generation (use sf-metadata).
---

# Salesforce Deployment

## Core Responsibilities

1. Deploy metadata to sandboxes and production
2. Run deployment validations (dry runs)
3. Manage scratch org creation and configuration
4. Troubleshoot deployment errors and test failures
5. Automate CI/CD workflows

## Workflow

### Phase 1 — Validate

Always validate before deploying:

```bash
# Validate deployment (dry run)
sf project deploy start --source-dir force-app --dry-run --test-level RunLocalTests --target-org <alias>

# Validate specific metadata
sf project deploy start --metadata ApexClass:MyService --dry-run --target-org <alias>

# Quick deploy after successful validation
sf project deploy quick --job-id <validationId> --target-org <alias>
```

### Phase 2 — Deploy

```bash
# Deploy all source
sf project deploy start --source-dir force-app --target-org <alias>

# Deploy with tests
sf project deploy start --source-dir force-app --test-level RunLocalTests --target-org <alias>

# Deploy specific types
sf project deploy start --metadata ApexClass,ApexTrigger,CustomObject --target-org <alias>

# Deploy to production (requires tests)
sf project deploy start --source-dir force-app --test-level RunLocalTests --target-org production
```

### Phase 3 — Verify

```bash
# Check deploy status
sf project deploy report --job-id <deployId> --target-org <alias>

# Resume a failed deploy
sf project deploy resume --job-id <deployId> --target-org <alias>

# Cancel an in-progress deploy
sf project deploy cancel --job-id <deployId> --target-org <alias>
```

## Test Levels

| Level | When to Use | Description |
|---|---|---|
| `NoTestRun` | Sandbox only | Skip all tests |
| `RunSpecifiedTests` | When you know which tests | Run only listed tests |
| `RunLocalTests` | Standard deploy | Run all non-managed tests |
| `RunAllTestsInOrg` | Production (required) | Run everything including managed |

## Scratch Org Management

```bash
# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias my-scratch --duration-days 7 --set-default

# Push source to scratch
sf project deploy start --source-dir force-app --target-org my-scratch

# Pull changes from scratch
sf project retrieve start --target-org my-scratch

# Open scratch org in browser
sf org open --target-org my-scratch

# List scratch orgs
sf org list --all

# Delete scratch org
sf org delete scratch --target-org my-scratch --no-prompt
```

### Scratch Org Definition

```json
{
    "orgName": "My Project Scratch",
    "edition": "Developer",
    "features": ["EnableSetPasswordInApi", "Communities"],
    "settings": {
        "lightningExperienceSettings": {
            "enableS1DesktopEnabled": true
        },
        "securitySettings": {
            "passwordPolicies": {
                "enableSetPasswordInApi": true
            }
        }
    }
}
```

## Retrieve Metadata

```bash
# Retrieve from org
sf project retrieve start --target-org <alias>

# Retrieve specific metadata
sf project retrieve start --metadata ApexClass:MyService --target-org <alias>

# Retrieve by package.xml
sf project retrieve start --manifest manifest/package.xml --target-org <alias>
```

## Common Deployment Errors

| Error | Cause | Fix |
|---|---|---|
| `MISSING_ORGANIZATION_FEATURE` | Feature not enabled in org | Enable feature in Setup or use correct org edition |
| `INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY` | Missing dependency | Deploy dependencies first or include in same deploy |
| `TEST_FAILURE` | Tests fail during deploy | Fix tests locally, validate with dry-run first |
| `UNKNOWN_EXCEPTION` | Org-specific issue | Check Setup Audit Trail, retry |
| `DUPLICATE_VALUE` | Metadata already exists with conflict | Retrieve from org, merge changes |
| `FIELD_INTEGRITY_EXCEPTION` | Required field missing in metadata | Check XML for required attributes |

## CI/CD Pipeline Pattern

```yaml
# Example GitHub Actions workflow
name: Deploy to Sandbox
on:
  push:
    branches: [develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install SF CLI
        run: npm install -g @salesforce/cli
      - name: Authenticate
        run: sf org login jwt --client-id ${{ secrets.SF_CLIENT_ID }} --jwt-key-file server.key --username ${{ secrets.SF_USERNAME }} --instance-url https://test.salesforce.com --alias target
      - name: Validate
        run: sf project deploy start --source-dir force-app --dry-run --test-level RunLocalTests --target-org target
      - name: Deploy
        run: sf project deploy start --source-dir force-app --test-level RunLocalTests --target-org target
```

## Cross-Skill References

- For metadata to deploy: see **sf-metadata**, **sf-apex**, **sf-flow**, **sf-lwc**
- For running tests during deploy: see **sf-testing**
- For Connected App auth in CI/CD: see **sf-connected-apps**
