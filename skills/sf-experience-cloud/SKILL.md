---
name: sf-experience-cloud
description: >
  Builds and configures Salesforce Experience Cloud sites (formerly
  Communities). Use when creating community sites, configuring guest
  user access, setting up sharing sets, managing site navigation,
  or building community-specific LWC components. Do NOT use for
  internal LWC (use sf-lwc) or permission sets (use sf-permissions).
---

# Experience Cloud

## Core Responsibilities

1. Create and configure Experience Cloud sites
2. Manage guest user access and sharing sets
3. Build community-specific LWC components
4. Configure site navigation, branding, and SEO
5. Set up self-registration and login flows

## Site Types

| Template | Use Case |
|---|---|
| Customer Service | Self-service portal with Knowledge, Cases |
| Partner Central | Partner portal with Leads, Opportunities |
| Customer Account Portal | Account management, order tracking |
| Build Your Own (LWR) | Full custom using Lightning Web Runtime |
| Help Center | Public Knowledge base |

## Site Configuration

### Create via CLI

```bash
# List existing sites
sf data query --query "SELECT Id, Name, UrlPathPrefix, Status FROM Site" --target-org <alias>

# Retrieve site metadata
sf project retrieve start --metadata ExperienceBundle --target-org <alias>

# Deploy site changes
sf project deploy start --metadata ExperienceBundle --target-org <alias>
```

### Site Metadata Structure

```
force-app/main/default/
├── experiences/
│   └── My_Portal1/
│       ├── config/
│       │   └── My_Portal1.json
│       ├── routes/
│       ├── views/
│       └── themes/
├── networks/
│   └── My_Portal.network-meta.xml
└── networkBranding/
    └── My_Portal.networkBranding-meta.xml
```

## Guest User Security

Guest user access is the most critical security concern:

### Sharing Sets (replace sharing rules for external users)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<SharingSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <accessMappings>
        <accessLevel>Read</accessLevel>
        <object>Knowledge__kav</object>
        <objectField>IsPublished</objectField>
        <userField>$User.Id</userField>
    </accessMappings>
    <label>Guest Knowledge Access</label>
    <profiles>
        <profile>My Portal Profile</profile>
    </profiles>
</SharingSet>
```

### Guest User Security Checklist

- [ ] Guest profile has minimum permissions (no Create/Edit/Delete)
- [ ] No access to sensitive objects (Account, Contact, Opportunity)
- [ ] Sharing sets used instead of sharing rules for guest
- [ ] Public API access disabled unless required
- [ ] Rate limiting enabled
- [ ] CAPTCHA on all forms
- [ ] Secure cookies enabled

## Community LWC Considerations

```javascript
import { LightningElement } from 'lwc';
import isGuest from '@salesforce/user/isGuest';
import communityBasePath from '@salesforce/community/basePath';
import communityId from '@salesforce/community/Id';

export default class CommunityComponent extends LightningElement {
    get isGuestUser() {
        return isGuest;
    }

    get loginUrl() {
        return communityBasePath + '/login';
    }
}
```

### Meta XML for Community Components

```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightningCommunity__Page</target>
        <target>lightningCommunity__Default</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightningCommunity__Default">
            <property name="title" type="String" label="Card Title" default="Welcome"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

## Self-Registration Flow

```
Guest visits site → Register button
  → Screen Flow (collects Name, Email, Password)
  → Create Contact + User (Community License)
  → Assign Permission Set
  → Redirect to home page
```

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Guest profile with CRUD access | Remove all CRUD, use sharing sets for read |
| No rate limiting | Enable in Site Settings |
| Internal LWC targets on community page | Use `lightningCommunity__Page` target |
| Hardcoded internal URLs | Use `communityBasePath` import |
| No login redirect for protected pages | Use `@salesforce/user/isGuest` check |

## Cross-Skill References

- For LWC components: see **sf-lwc**
- For permissions: see **sf-permissions**
- For security review: see **sf-security**
- For deployment: see **sf-deploy**
