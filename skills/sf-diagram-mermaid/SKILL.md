---
name: sf-diagram-mermaid
description: >
  Generates Mermaid diagrams for Salesforce architecture documentation
  including ERD diagrams, OAuth flow sequences, integration architecture,
  and system landscape diagrams. Use when creating visual documentation,
  data model diagrams, flow diagrams, or architecture overviews.
  Do NOT use for code generation (use respective skills).
---

# Mermaid Diagrams for Salesforce

## Core Responsibilities

1. Generate Entity Relationship Diagrams (ERD) for Salesforce objects
2. Create sequence diagrams for OAuth flows
3. Build integration architecture diagrams
4. Design system landscape and deployment diagrams
5. Visualize Flow logic and agent conversation trees

## Diagram Types

### ERD — Entity Relationship Diagram

```mermaid
erDiagram
    Account ||--o{ Contact : "has many"
    Account ||--o{ Opportunity : "has many"
    Opportunity ||--o{ OpportunityLineItem : "has many"
    OpportunityLineItem }o--|| Product2 : "references"
    Contact ||--o{ Case : "has many"
    Account ||--o{ Case : "has many"

    Account {
        Id Id PK
        String Name
        String Industry
        String Phone
        String BillingCity
    }
    Contact {
        Id Id PK
        Id AccountId FK
        String FirstName
        String LastName
        String Email
    }
    Opportunity {
        Id Id PK
        Id AccountId FK
        String Name
        String StageName
        Date CloseDate
        Currency Amount
    }
```

### Sequence — JWT Bearer OAuth Flow

```mermaid
sequenceDiagram
    participant App as Client App
    participant SF as Salesforce Auth
    participant API as Salesforce API

    App->>App: Create JWT with claims
    App->>App: Sign JWT with private key
    App->>SF: POST /oauth2/token (grant_type=jwt-bearer)
    SF->>SF: Validate JWT signature
    SF->>SF: Check Connected App config
    SF-->>App: Access Token + Instance URL
    App->>API: GET /services/data/v62.0/sobjects (Bearer token)
    API-->>App: Response data
```

### Sequence — Authorization Code + PKCE

```mermaid
sequenceDiagram
    participant User
    participant App as Client App
    participant SF as Salesforce Auth

    App->>App: Generate code_verifier + code_challenge
    App->>SF: GET /authorize (code_challenge, response_type=code)
    SF->>User: Login page
    User->>SF: Enter credentials
    SF-->>App: Authorization code (redirect)
    App->>SF: POST /token (code + code_verifier)
    SF->>SF: Verify code_challenge matches
    SF-->>App: Access Token + Refresh Token
```

### Flowchart — Integration Architecture

```mermaid
flowchart LR
    subgraph Salesforce
        Apex[Apex Callout]
        PE[Platform Events]
        NC[Named Credentials]
    end

    subgraph External ["External Systems"]
        REST[REST API]
        Queue[Message Queue]
        ERP[ERP System]
    end

    Apex -->|HTTPS| NC
    NC -->|Auth + Call| REST
    PE -->|Pub/Sub| Queue
    Queue -->|Subscribe| ERP
    ERP -->|Webhook| Apex
```

### Flowchart — Deployment Pipeline

```mermaid
flowchart TD
    Dev[Developer Scratch Org] -->|Push| Repo[Git Repository]
    Repo -->|PR| Review{Code Review}
    Review -->|Approved| CI[CI Validation]
    CI -->|Tests Pass| Sandbox[Deploy to Sandbox]
    Sandbox -->|UAT Approved| Staging[Deploy to Staging]
    Staging -->|Sign-off| Prod[Deploy to Production]
    Review -->|Changes Requested| Dev
    CI -->|Tests Fail| Dev
```

### Class Diagram — Apex Architecture

```mermaid
classDiagram
    class AccountTrigger {
        +TriggerActionFlow run()
    }
    class AccountService {
        +processAccounts(List~Account~) void
        +getAccountsWithContacts(Set~Id~) Map
    }
    class AccountSelector {
        +getById(Set~Id~) List~Account~
        +getWithContacts(Set~Id~) List~Account~
    }
    class AccountServiceTest {
        +testBulkInsert() void
        +testNegativeCase() void
    }

    AccountTrigger --> AccountService : delegates
    AccountService --> AccountSelector : queries via
    AccountServiceTest ..> AccountService : tests
```

## Workflow

### Phase 1 — Gather Context

- Identify the objects, relationships, or flows to diagram
- Determine the diagram type (ERD, sequence, flowchart, class)
- Identify the audience (technical vs business)

### Phase 2 — Generate

- Use the appropriate Mermaid syntax for the diagram type
- Keep diagrams readable (max ~15 nodes per diagram)
- Use clear labels and descriptive relationship text
- Split large diagrams into multiple focused diagrams

### Phase 3 — Render

Mermaid diagrams render natively in:
- GitHub Markdown files
- Cursor IDE preview
- Confluence (with Mermaid plugin)
- VS Code Markdown preview

## Best Practices

- Use PascalCase for node names (no spaces)
- Keep diagrams focused — one concept per diagram
- Add descriptions to relationships
- Use subgraphs to group related elements
- Limit complexity: if > 15 nodes, split into sub-diagrams
- Use consistent direction (TD for hierarchies, LR for flows)

## Cross-Skill References

- For object metadata to diagram: see **sf-metadata**
- For OAuth flows: see **sf-connected-apps**
- For integration architecture: see **sf-integration**
- For agent conversation flows: see **sf-ai-agentscript**
