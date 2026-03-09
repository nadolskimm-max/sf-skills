# Salesforce Skills for Cursor IDE

A collection of **52 reusable AI skills** for Salesforce development in Cursor IDE, enabling code generation, validation, testing, debugging, and deployment across the entire Salesforce platform.

## Available Skills (52)

### Development (4)

| Skill | Description |
|-------|-------------|
| **sf-apex** | Apex generation, Trigger Actions Framework, bulk patterns |
| **sf-flow** | Flow creation, bulk validation, error handling patterns |
| **sf-lwc** | Lightning Web Components, Jest tests, Lightning Message Service |
| **sf-soql** | Natural language to SOQL, query optimization, selective indexing |

### Quality & Review (4)

| Skill | Description |
|-------|-------------|
| **sf-testing** | Apex test runner, coverage analysis, bulk test patterns |
| **sf-debug** | Debug log analysis, governor limit diagnosis |
| **sf-code-review** | Structured code review rubric, severity levels, PR templates |
| **sf-performance** | Cross-platform performance optimization (Apex, SOQL, LWC, Flow) |

### Foundation (7)

| Skill | Description |
|-------|-------------|
| **sf-metadata** | Metadata generation, org describe queries, custom objects/fields |
| **sf-data** | SOQL queries, test data factories, Bulk API operations |
| **sf-permissions** | Permission Set analysis, profile comparison, "Who has access?" |
| **sf-formula** | Formula fields, validation rules, REGEX patterns, null handling |
| **sf-security** | Sharing rules, OWD, encryption, CRUD/FLS enforcement, security review |
| **sf-custom-metadata** | Custom Metadata Types vs Custom Settings vs Custom Labels |
| **sf-file-management** | ContentDocument, ContentVersion, file uploads, attachments |

### Automation (3)

| Skill | Description |
|-------|-------------|
| **sf-approval** | Approval processes, email alerts, field updates, Apex approvals |
| **sf-email** | Email templates, email alerts, inbound email services, mass email |
| **sf-automation-strategy** | Flow vs Apex vs Scheduled decision guide, migration from Process Builder |

### Advanced Apex (2)

| Skill | Description |
|-------|-------------|
| **sf-async-patterns** | Queueable chaining, batch orchestration, Finalizers, Platform Event async |
| **sf-api-design** | Custom REST/SOAP endpoints (@RestResource), Composite API, versioning |

### Data Quality (2)

| Skill | Description |
|-------|-------------|
| **sf-duplicate-management** | Duplicate Rules, Matching Rules, merge operations, data quality |
| **sf-migration** | Org-to-org migration, metadata comparison, data migration strategies |

### Integration (4)

| Skill | Description |
|-------|-------------|
| **sf-connected-apps** | OAuth configuration, External Client Apps, JWT Bearer flow |
| **sf-integration** | Named Credentials, REST/SOAP callouts, Platform Events, CDC |
| **sf-mulesoft** | MuleSoft Anypoint, API-led connectivity, DataWeave, SF Connector |
| **sf-slack** | Slack apps for Salesforce, Block Kit messages, interactive actions |

### AI & Agentforce (5)

| Skill | Description |
|-------|-------------|
| **sf-ai-agentforce** | Agent Builder, PromptTemplate, Models API, GenAi metadata |
| **sf-ai-agentforce-persona** | Persona design, identity framework, Agent Builder encoding |
| **sf-ai-agentforce-testing** | Agent test specs, agentic fix loops |
| **sf-ai-agentforce-observability** | Session tracing, Data Cloud extraction |
| **sf-ai-agentscript** | Agent Script DSL, FSM patterns |

### DevOps & Tooling (5)

| Skill | Description |
|-------|-------------|
| **sf-deploy** | CI/CD automation with Salesforce CLI v2 |
| **sf-package** | Unlocked/managed packages, versioning, dependencies |
| **sf-devhub** | Scratch org pools, org shapes, DevHub management |
| **sf-diagram-mermaid** | Mermaid diagrams for ERD, OAuth flows, architecture |
| **sf-reporting** | Reports, dashboards, custom report types, performance |

### Monitoring (2)

| Skill | Description |
|-------|-------------|
| **sf-event-monitoring** | EventLogFiles, login analysis, Transaction Security, Shield |
| **sf-crm-analytics** | CRM Analytics (Tableau CRM), SAQL, datasets, dataflows |

### Legacy & Migration (2)

| Skill | Description |
|-------|-------------|
| **sf-aura** | Aura component maintenance, Aura-to-LWC migration guide |
| **sf-visualforce** | VF page maintenance, PDF generation, VF-to-LWC migration |

### Clouds (5)

| Skill | Description |
|-------|-------------|
| **sf-cloud-sales** | Opportunity products, Quotes, Forecasting, Territory Management |
| **sf-cloud-service** | Cases, Omni-Channel, Knowledge, Entitlements, Milestones |
| **sf-experience-cloud** | Community sites, guest user access, sharing sets, LWR |
| **sf-field-service** | Work orders, service appointments, scheduling, mobile flows |
| **sf-commerce** | B2B/B2C Commerce storefronts, product catalog, checkout, payments |

### Products (3)

| Skill | Description |
|-------|-------------|
| **sf-data-cloud** | DMOs, segments, calculated insights, identity resolution |
| **sf-omnistudio** | OmniScripts, FlexCards, DataRaptors, Integration Procedures |
| **sf-cpq** | Configure-Price-Quote, product bundles, price rules, discounts |

### Marketing (1)

| Skill | Description |
|-------|-------------|
| **sf-marketing-cloud** | MC Connect, Journey Builder, AMPscript, data extensions |

### Industries (3)

| Skill | Description |
|-------|-------------|
| **sf-industry-health** | Health Cloud, FHIR R4, Care Plans, HIPAA compliance |
| **sf-industry-finserv** | Financial Services Cloud, KYC, AML, wealth management |
| **sf-nonprofit** | Nonprofit Cloud (NPSP), donations, recurring giving, programs |

## Installation

### Windows (PowerShell)

```powershell
# Install all skills
.\install.ps1

# List available skills
.\install.ps1 -List

# Install specific skills only
.\install.ps1 -Skills sf-apex,sf-lwc,sf-flow

# Install skills + Cursor rules for current project
.\install.ps1 -WithRules

# Uninstall all skills
.\install.ps1 -Uninstall
```

### macOS / Linux (Bash)

```bash
# Install all skills
./install.sh

# List available skills
./install.sh --list

# Install specific skills only
./install.sh --skills sf-apex,sf-lwc,sf-flow

# Install skills + Cursor rules for current project
./install.sh --with-rules

# Uninstall all skills
./install.sh --uninstall
```

After installation, restart Cursor to pick up the new skills.

## Prerequisites

- **Cursor IDE** (latest version)
- **Salesforce CLI v2** (`sf`) — `npm install -g @salesforce/cli`
- **Authenticated Salesforce Org** — DevHub, Sandbox, or Scratch Org
- **sfdx-project.json** — Standard DX project structure

## Usage Examples

```
"Generate an Apex trigger for Account using Trigger Actions Framework"
"Create a screen flow for account creation with validation"
"Build a datatable LWC to display Accounts with sorting"
"Query all Accounts with more than 5 Contacts"
"Create a Connected App for API integration with JWT Bearer flow"
"Deploy my Apex classes to sandbox with tests"
"Create an ERD diagram for Account, Contact, Opportunity"
"Review my AccountService class for best practices"
"Create an approval process for invoices over $1000"
"Set up org-wide defaults and sharing rules for Case"
"Build a custom REST API endpoint for invoice management"
"Should I use Flow or Apex for this automation?"
"Create a MuleSoft integration for Salesforce-to-ERP sync"
"Send a Slack notification when an Opportunity is Closed Won"
"Configure CPQ product bundles with volume discounts"
"Build a KYC onboarding flow for Financial Services Cloud"
```

## Cursor Rules

Optional `.cursor/rules/*.mdc` files provide persistent Salesforce conventions:

- **salesforce-apex.mdc** — Apex coding standards (triggers, bulk patterns, naming)
- **salesforce-lwc.mdc** — LWC component patterns (SLDS, accessibility, reactivity)
- **salesforce-conventions.mdc** — General Salesforce project conventions

Install rules with `.\install.ps1 -WithRules` or `./install.sh --with-rules`.

## License

MIT
