---
name: sf-package
description: >
  Manages Salesforce package development including unlocked packages,
  managed packages, versioning, and dependency management. Use when
  creating packages, managing package versions, resolving dependencies,
  or setting up package-based development. Do NOT use for basic deployment
  (use sf-deploy) or scratch org management (use sf-devhub).
---

# Salesforce Package Development

## Core Responsibilities

1. Create and manage unlocked and managed packages
2. Handle package versioning and ancestry
3. Resolve package dependencies
4. Configure `sfdx-project.json` for multi-package projects
5. Promote and install package versions

## Package Types

| Type | Use Case | Upgradeable | Namespace |
|---|---|---|---|
| Unlocked | Internal modular development | Yes | Optional |
| Managed | ISV / AppExchange distribution | Yes | Required |
| Org-Dependent Unlocked | Quick modular, allows org refs | Yes | Optional |

## Workflow

### Phase 1 — Configure Project

```json
{
    "packageDirectories": [
        {
            "path": "force-app/core",
            "default": true,
            "package": "MyApp-Core",
            "versionName": "Spring '26",
            "versionNumber": "1.2.0.NEXT",
            "versionDescription": "Core business logic"
        },
        {
            "path": "force-app/ui",
            "package": "MyApp-UI",
            "versionName": "Spring '26",
            "versionNumber": "1.1.0.NEXT",
            "dependencies": [
                {
                    "package": "MyApp-Core",
                    "versionNumber": "1.2.0.LATEST"
                }
            ]
        }
    ],
    "namespace": "",
    "sfdcLoginUrl": "https://login.salesforce.com",
    "sourceApiVersion": "62.0",
    "packageAliases": {
        "MyApp-Core": "0Ho...",
        "MyApp-UI": "0Ho...",
        "MyApp-Core@1.2.0-1": "04t..."
    }
}
```

### Phase 2 — Create Package

```bash
# Create unlocked package
sf package create --name MyApp-Core --package-type Unlocked --path force-app/core --target-dev-hub <devhub>

# Create managed package
sf package create --name MyApp-Core --package-type Managed --path force-app/core --namespace myns --target-dev-hub <devhub>
```

### Phase 3 — Create Version

```bash
# Create package version (beta)
sf package version create --package MyApp-Core --installation-key <key> --wait 20 --target-dev-hub <devhub>

# Create with code coverage check
sf package version create --package MyApp-Core --installation-key <key> --code-coverage --wait 20 --target-dev-hub <devhub>

# Check creation status
sf package version create report --package-create-request-id <id> --target-dev-hub <devhub>
```

### Phase 4 — Promote & Install

```bash
# Promote to released (non-beta)
sf package version promote --package "MyApp-Core@1.2.0-1" --target-dev-hub <devhub>

# Install in target org
sf package install --package "MyApp-Core@1.2.0-1" --installation-key <key> --wait 15 --target-org <alias>

# Check install status
sf package install report --request-id <id> --target-org <alias>

# List installed packages
sf package installed list --target-org <alias>
```

## Multi-Package Architecture

```
sfdx-project.json
├── MyApp-Core (core objects, Apex services)
│   └── force-app/core/
├── MyApp-UI (LWC, layouts, tabs)
│   ├── depends on: MyApp-Core
│   └── force-app/ui/
└── MyApp-Integration (callouts, events)
    ├── depends on: MyApp-Core
    └── force-app/integration/
```

## Version Numbering

Format: `MAJOR.MINOR.PATCH.BUILD`

| Segment | When to Increment |
|---|---|
| MAJOR | Breaking changes (field removal, API change) |
| MINOR | New features (backward compatible) |
| PATCH | Bug fixes |
| BUILD | Auto-incremented (use `NEXT`) |

## Common Issues

| Issue | Fix |
|---|---|
| `Package version not found` | Check aliases in sfdx-project.json |
| `Dependency version mismatch` | Use `LATEST` for dev, pin for release |
| `Code coverage < 75%` | Add `--code-coverage` flag, fix tests |
| `Ancestor version conflict` | Set `ancestorVersion` correctly in project config |
| `Component already in package` | One component can only belong to one package |

## Cross-Skill References

- For basic deployment: see **sf-deploy**
- For scratch org testing: see **sf-devhub**
- For metadata in packages: see **sf-metadata**
- For test coverage: see **sf-testing**
