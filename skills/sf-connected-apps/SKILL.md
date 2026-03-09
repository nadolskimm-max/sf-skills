---
name: sf-connected-apps
description: >
  Creates and manages Salesforce Connected Apps and External Client Apps
  for OAuth integrations. Use when configuring OAuth flows (JWT Bearer,
  Authorization Code, Client Credentials, PKCE), creating Connected App
  metadata, or migrating to External Client Apps. Do NOT use for Named
  Credentials (use sf-integration) or general API callouts (use sf-integration).
---

# Connected Apps & OAuth

## Core Responsibilities

1. Generate Connected App metadata XML
2. Configure OAuth flows (JWT Bearer, Auth Code + PKCE, Client Credentials)
3. Create External Client Apps (ECA) for new integrations
4. Review security best practices for OAuth configurations
5. Guide migration from Connected Apps to External Client Apps

## OAuth Flow Selection

| Flow | Use Case | Security Level |
|---|---|---|
| JWT Bearer | Server-to-server, no user interaction | High (certificate-based) |
| Authorization Code + PKCE | Web/mobile apps with user login | High (no client secret exposed) |
| Client Credentials | Backend service accounts | Medium (secret-based) |
| Device Flow | CLI tools, IoT devices | Medium |
| Refresh Token | Long-lived sessions | Depends on storage |

## Workflow

### Phase 1 — Requirements

- Identify the integration type (server-to-server vs user-facing)
- Determine the OAuth flow needed
- Identify required OAuth scopes
- Plan certificate/key management for JWT

### Phase 2 — Generate

### Connected App (JWT Bearer)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ConnectedApp xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>My Integration App</label>
    <contactEmail>admin@example.com</contactEmail>
    <oauthConfig>
        <callbackUrl>https://login.salesforce.com/services/oauth2/callback</callbackUrl>
        <certificate>MyCertificate</certificate>
        <isAdminApproved>true</isAdminApproved>
        <isConsumerSecretOptional>false</isConsumerSecretOptional>
        <scopes>Api</scopes>
        <scopes>RefreshToken</scopes>
    </oauthConfig>
    <oauthPolicy>
        <ipRelaxation>ENFORCE</ipRelaxation>
        <refreshTokenPolicy>specific_lifetime</refreshTokenPolicy>
        <singleLogoutUrl></singleLogoutUrl>
    </oauthPolicy>
</ConnectedApp>
```

### Connected App (Client Credentials)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ConnectedApp xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Backend Service App</label>
    <contactEmail>admin@example.com</contactEmail>
    <oauthConfig>
        <callbackUrl>https://login.salesforce.com/services/oauth2/callback</callbackUrl>
        <isAdminApproved>true</isAdminApproved>
        <scopes>Api</scopes>
    </oauthConfig>
    <oauthPolicy>
        <ipRelaxation>ENFORCE</ipRelaxation>
        <refreshTokenPolicy>specific_lifetime</refreshTokenPolicy>
    </oauthPolicy>
</ConnectedApp>
```

### Phase 3 — Configure in Org

```bash
# Deploy Connected App
sf project deploy start --metadata ConnectedApp:My_Integration_App --target-org <alias>

# Create certificate (for JWT)
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt
```

## External Client Apps (ECA)

ECAs are the modern replacement for Connected Apps (API v61.0+):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ExternalClientApp xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Mobile Client App</label>
    <contactEmail>admin@example.com</contactEmail>
    <description>Mobile application OAuth client</description>
    <oauthConfig>
        <callbackUrl>myapp://oauth/callback</callbackUrl>
        <scopes>Api</scopes>
        <scopes>RefreshToken</scopes>
        <isClientCredentialsEnabled>false</isClientCredentialsEnabled>
        <isPkceRequired>true</isPkceRequired>
    </oauthConfig>
</ExternalClientApp>
```

## Security Best Practices

| Practice | Detail |
|---|---|
| Use JWT Bearer for server-to-server | No secrets stored, certificate-based auth |
| Enable PKCE for public clients | Prevents authorization code interception |
| Enforce IP restrictions | Set `ipRelaxation` to `ENFORCE` |
| Limit OAuth scopes | Grant only required scopes |
| Rotate certificates annually | Set calendar reminders for cert expiry |
| Use Named Credentials | Never hardcode tokens in Apex |
| Enable Admin Pre-Authorization | Prevent unauthorized app access |

## Cross-Skill References

- For Named Credentials: see **sf-integration**
- For deploying connected apps: see **sf-deploy**
- For OAuth flow diagrams: see **sf-diagram-mermaid**
