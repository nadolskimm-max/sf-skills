---
name: sf-aura
description: >
  Maintains and migrates Salesforce Aura components to Lightning Web
  Components. Use when working with existing Aura components, planning
  Aura-to-LWC migration, understanding Aura event architecture, or
  building Aura wrappers for LWC interop. Do NOT use for new component
  development (use sf-lwc instead — LWC is the current standard).
---

# Aura Components & Migration to LWC

## Core Responsibilities

1. Maintain existing Aura components
2. Plan and execute Aura-to-LWC migration
3. Build Aura wrapper components for LWC interop
4. Map Aura patterns to LWC equivalents
5. Identify migration-ready vs stay-on-Aura candidates

## Migration Decision Matrix

| Scenario | Recommendation |
|---|---|
| New component | Always use LWC |
| Simple Aura component (< 200 lines) | Migrate to LWC |
| Complex Aura with many events | Migrate incrementally |
| Aura using unsupported LWC features | Wrap LWC inside Aura |
| Aura app-level events heavily used | Migrate to LMS |
| Component rarely changed | Low priority, migrate later |

## Aura → LWC Mapping

### Component Structure

| Aura | LWC |
|---|---|
| `myComponent.cmp` | `myComponent.html` |
| `myComponentController.js` | `myComponent.js` |
| `myComponentHelper.js` | (merged into .js) |
| `myComponent.css` | `myComponent.css` |
| `myComponent.design` | `myComponent.js-meta.xml` |

### Syntax Mapping

| Aura | LWC |
|---|---|
| `<aura:attribute name="title" type="String"/>` | `@api title;` |
| `{!v.title}` | `{title}` |
| `<aura:if isTrue="{!v.show}">` | `<template lwc:if={show}>` |
| `<aura:iteration items="{!v.items}" var="item">` | `<template for:each={items} for:item="item">` |
| `component.get('v.title')` | `this.title` |
| `component.set('v.title', val)` | `this.title = val;` |
| `$A.createComponent(...)` | Dynamic component import |
| `helper.doSomething(component)` | `this.doSomething()` |

### Event Mapping

| Aura Pattern | LWC Equivalent |
|---|---|
| Component Event | `CustomEvent` + `dispatchEvent` |
| Application Event | Lightning Message Service (LMS) |
| `<aura:handler>` | `on{eventname}` attribute in parent template |
| `event.getParam('data')` | `event.detail.data` |
| `$A.get('e.c:MyEvent')` | `import CHANNEL from '@salesforce/messageChannel/...'` |

### Data Access

| Aura | LWC |
|---|---|
| `<aura:handler name="init" action="{!c.doInit}"/>` | `connectedCallback()` |
| Apex `@AuraEnabled` + `action.setCallback` | `@wire` or imperative import |
| `$A.enqueueAction(action)` | `import method from '@salesforce/apex/...'` |

## Aura Wrapper for LWC

When you need Aura features not yet in LWC:

```xml
<!-- auraWrapper.cmp -->
<aura:component implements="flexipage:availableForAllPageTypes">
    <c:myLwcComponent
        recordId="{!v.recordId}"
        onselect="{!c.handleSelect}">
    </c:myLwcComponent>
</aura:component>
```

## Migration Workflow

```
1. INVENTORY: List all Aura components, categorize by complexity
2. PRIORITIZE: High-use, simple components first
3. MIGRATE: Rewrite in LWC following patterns above
4. TEST: Verify same behavior (Jest + manual)
5. DEPLOY: Replace Aura with LWC on pages
6. CLEANUP: Remove old Aura components
```

## Cross-Skill References

- For LWC development: see **sf-lwc**
- For LMS (replacing app events): see **sf-lwc** references/patterns.md
- For Apex controllers: see **sf-apex**
- For deployment: see **sf-deploy**
