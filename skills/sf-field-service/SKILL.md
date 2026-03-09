---
name: sf-field-service
description: >
  Configures Salesforce Field Service including work orders, service
  appointments, scheduling, service territories, and mobile workforce
  management. Use when setting up Field Service, configuring scheduling
  policies, building dispatch console, or creating mobile flows.
  Do NOT use for standard Case management (use sf-cloud-service) or
  general Flow (use sf-flow).
---

# Field Service

## Core Responsibilities

1. Configure work orders and service appointments
2. Set up service territories and operating hours
3. Configure scheduling policies and optimization
4. Build dispatch console customizations
5. Create mobile-optimized flows for field technicians

## Field Service Data Model

```
Work Order
├── Work Order Line Item (individual tasks)
├── Service Appointment (scheduled time slot)
│   ├── Assigned Resource (technician)
│   └── Service Territory
├── Required Skill (skills needed)
└── Product Required / Consumed
    └── Product Item (inventory)

Service Resource (technician)
├── Service Territory Member (territory assignments)
├── Resource Skill (technician skills)
├── Resource Capacity (working hours)
└── Service Crew Member (team assignments)
```

## Key Objects

| Object | Description |
|---|---|
| Work Order | Job to be completed |
| Service Appointment | Scheduled time for the job |
| Service Resource | Technician / field worker |
| Service Territory | Geographic area |
| Operating Hours | Business hours for scheduling |
| Scheduling Policy | Rules for auto-scheduling |
| Skill | Required competency |

## Work Order Configuration

```sql
-- Work orders with appointments
SELECT Id, WorkOrderNumber, Status, Priority,
    (SELECT Id, Status, SchedStartTime, SchedEndTime,
            ServiceResource.Name
     FROM ServiceAppointments)
FROM WorkOrder
WHERE Status != 'Completed'
ORDER BY Priority DESC
```

## Scheduling Policies

| Policy Type | Description |
|---|---|
| Customer First | Minimize customer wait time |
| High Intensity | Maximize resource utilization |
| Soft Boundaries | Allow overflow between territories |
| Emergency | Override normal scheduling rules |

### Scheduling Objectives (weighted)

| Objective | Description |
|---|---|
| Minimize Travel | Reduce drive time between appointments |
| Minimize Overtime | Stay within working hours |
| Match Skills | Assign qualified technicians |
| Priority | Honor work order priority |
| Preferred Resource | Assign customer's preferred tech |
| Territory | Keep resources in their territory |

## Service Territory Setup

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ServiceTerritory xmlns="http://soap.sforce.com/2006/04/metadata">
    <name>San Francisco Bay Area</name>
    <isActive>true</isActive>
    <operatingHoursId>BusinessHours_Standard</operatingHoursId>
    <parentTerritoryId>California</parentTerritoryId>
</ServiceTerritory>
```

## Mobile Flow for Technicians

```
Service Appointment opened on mobile
├── Screen: Confirm arrival (update status to "In Progress")
├── Screen: Checklist of tasks
│   └── Loop: For each Work Order Line Item
│       ├── Checkbox: Task completed
│       └── Text: Notes
├── Screen: Parts consumed
│   └── Add Product Consumed records
├── Screen: Customer signature (capture component)
└── Update: Service Appointment status → "Completed"
```

## Common Queries

```sql
-- Unassigned appointments
SELECT Id, AppointmentNumber, ParentRecordId, Status
FROM ServiceAppointment
WHERE Status = 'None' AND SchedStartTime = TODAY

-- Resource availability
SELECT Id, ServiceResource.Name, ServiceTerritory.Name,
       EffectiveStartDate, EffectiveEndDate
FROM ServiceTerritoryMember
WHERE ServiceResource.IsActive = true

-- Skill matching
SELECT Id, ServiceResource.Name, Skill.MasterLabel, SkillLevel
FROM ServiceResourceSkill
WHERE Skill.MasterLabel = 'Electrical'
```

## Cross-Skill References

- For case-to-work-order automation: see **sf-cloud-service**
- For scheduling flows: see **sf-flow**
- For mobile LWC: see **sf-lwc**
- For deployment: see **sf-deploy**
