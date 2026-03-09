---
name: sf-devhub
description: >
  Manages Salesforce DevHub including scratch org pools, shape orgs,
  namespace management, and scratch org configuration. Use when setting
  up DevHub, managing scratch org definitions, creating org shapes, or
  troubleshooting scratch org limits. Do NOT use for regular deployment
  (use sf-deploy) or package versioning (use sf-package).
---

# DevHub Management

## Core Responsibilities

1. Configure and manage DevHub org
2. Create and manage scratch org definitions
3. Set up org shapes for scratch org cloning
4. Manage scratch org pools for CI/CD
5. Monitor scratch org limits and usage

## Scratch Org Lifecycle

```bash
# Set default DevHub
sf config set target-dev-hub=mydevhub

# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias dev --duration-days 7 --set-default

# Push source
sf project deploy start --target-org dev

# Assign permission sets
sf org assign permset --name My_Permissions --target-org dev

# Import test data
sf data import tree --files data/Account.json --target-org dev

# Open org
sf org open --target-org dev

# Delete when done
sf org delete scratch --target-org dev --no-prompt
```

## Scratch Org Definition Files

### Standard Development

```json
{
    "orgName": "Development Scratch",
    "edition": "Developer",
    "features": ["EnableSetPasswordInApi"],
    "settings": {
        "lightningExperienceSettings": {
            "enableS1DesktopEnabled": true
        },
        "languageSettings": {
            "enableTranslationWorkbench": false
        }
    }
}
```

### With Communities

```json
{
    "orgName": "Community Dev",
    "edition": "Developer",
    "features": [
        "Communities",
        "ServiceCloud",
        "EnableSetPasswordInApi"
    ],
    "settings": {
        "communitiesSettings": {
            "enableNetworksEnabled": true
        },
        "experienceBundleSettings": {
            "enableExperienceBundleMetadata": true
        }
    }
}
```

### With Shield / Event Monitoring

```json
{
    "orgName": "Security Dev",
    "edition": "Developer",
    "features": [
        "PlatformEncryption",
        "EventMonitoring",
        "FieldAuditTrail"
    ]
}
```

## Org Shape

Org shapes clone configuration from a source org:

```bash
# Create org shape from source org
sf org create shape --target-org source-org

# List org shapes
sf org list shape --target-org devhub

# Use shape in scratch def
# Add "sourceOrg": "<orgId>" to project-scratch-def.json

# Delete shape
sf org delete shape --target-org devhub --no-prompt
```

## Monitoring Scratch Org Limits

```bash
# Check remaining scratch org count
sf org list limits --target-org devhub

# List all active scratch orgs
sf org list --all

# List with details
sf data query --query "SELECT Id, SignupUsername, ExpirationDate, Status, OrgName FROM ScratchOrgInfo WHERE Status = 'Active' ORDER BY ExpirationDate" --target-org devhub
```

### Limits Reference

| Edition | Active Scratch Orgs | Daily Scratch Orgs |
|---|---|---|
| Developer Edition | 3 | 6 |
| Enterprise/Unlimited | 40 | 80 |
| Performance | 100 | 200 |
| With Add-On | Up to 200 | Up to 400 |

## Scratch Org Pool Script (CI/CD)

```bash
#!/usr/bin/env bash
POOL_SIZE=5
DURATION=3

active=$(sf data query --query "SELECT COUNT() FROM ScratchOrgInfo WHERE Status = 'Active'" --target-org devhub --result-format csv | tail -1)

needed=$((POOL_SIZE - active))
if [ "$needed" -gt 0 ]; then
    for i in $(seq 1 $needed); do
        sf org create scratch \
            --definition-file config/project-scratch-def.json \
            --alias "pool-$i" \
            --duration-days $DURATION \
            --target-dev-hub devhub \
            --no-prompt
    done
fi
```

## Best Practices

- Use `--duration-days 7` or less for development (save limits)
- Create org definitions per use case (dev, QA, integration)
- Automate data loading with `sf data import tree`
- Use org shapes to replicate production config
- Monitor daily limits in CI/CD pipelines

## Cross-Skill References

- For deployment to scratch orgs: see **sf-deploy**
- For package testing in scratch orgs: see **sf-package**
- For test data loading: see **sf-data**
- For scratch org definition features: see **sf-metadata**
