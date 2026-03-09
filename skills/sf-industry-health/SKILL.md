---
name: sf-industry-health
description: >
  Builds Health Cloud features including FHIR integration, Care Plans,
  Patient/Member data models, and healthcare compliance patterns. Use
  when working with Health Cloud objects, implementing FHIR resources,
  building care coordination, or ensuring HIPAA compliance patterns.
  Do NOT use for general Salesforce objects (use sf-metadata) or
  standard integrations (use sf-integration).
---

# Health Cloud

## Core Responsibilities

1. Configure Health Cloud data model (Patient, CarePlan, CareProgram)
2. Implement FHIR R4 resource integration
3. Build Care Plan templates and care coordination
4. Ensure HIPAA compliance patterns in Apex/LWC
5. Configure Provider and Patient portal experiences

## Health Cloud Data Model

### Core Objects

| Object | Description | Standard Equivalent |
|---|---|---|
| Account (Person Account) | Patient / Member | Account |
| CarePlan | Treatment plan | Custom |
| CarePlanGoal | Goals within a care plan | Custom |
| CarePlanActivity | Tasks/actions in a care plan | Custom |
| CareProgram | Program enrollment | Custom |
| HealthCondition | Diagnosis / condition | Custom |
| ClinicalEncounter | Visit / encounter | Custom |
| MedicationStatement | Active medications | Custom |

### Key Queries

```sql
-- Patients with active care plans
SELECT Id, Name, PersonEmail,
    (SELECT Id, Name, Status FROM CarePlans__r WHERE Status = 'Active')
FROM Account
WHERE RecordType.DeveloperName = 'PersonAccount'
  AND IsPersonAccount = true

-- Care plan with goals and activities
SELECT Id, Name, Status,
    (SELECT Id, Name, GoalStatus FROM CarePlanGoals__r),
    (SELECT Id, Name, ActivityStatus FROM CarePlanActivities__r)
FROM CarePlan
WHERE Status = 'Active'
```

## FHIR Integration

### FHIR R4 Resources Mapping

| FHIR Resource | Salesforce Object |
|---|---|
| Patient | Account (Person Account) |
| Condition | HealthCondition |
| CarePlan | CarePlan |
| Encounter | ClinicalEncounter |
| MedicationRequest | MedicationStatement |
| Observation | ClinicalObservation |
| Practitioner | Contact (Provider) |

### FHIR REST Callout

```apex
public class FHIRService {
    private static final String FHIR_ENDPOINT = 'callout:FHIR_Server';

    public static Map<String, Object> getPatient(String patientId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(FHIR_ENDPOINT + '/Patient/' + patientId);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/fhir+json');
        req.setTimeout(30000);

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        }
        throw new CalloutException('FHIR error: ' + res.getStatusCode());
    }
}
```

## HIPAA Compliance Patterns

### Apex Security

```apex
// Always use with sharing for patient data
public with sharing class PatientService {

    public static List<Account> getPatients(Set<Id> patientIds) {
        // Enforce FLS
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Name, PersonEmail, HealthCloudGA__MedicalRecordNumber__pc
             FROM Account WHERE Id IN :patientIds]
        );
        return decision.getRecords();
    }
}
```

### Compliance Checklist

- [ ] All patient data classes use `with sharing`
- [ ] FLS enforced via `stripInaccessible` or `WITH SECURITY_ENFORCED`
- [ ] Shield Platform Encryption on PHI fields
- [ ] Audit trail enabled for patient record access
- [ ] No PHI in debug logs or error messages
- [ ] Session timeout configured (15 min recommended)
- [ ] IP restrictions on health data profiles

## Cross-Skill References

- For FHIR API integration: see **sf-integration**
- For patient portal: see **sf-experience-cloud**
- For security/encryption: see **sf-security**
- For care plan automation: see **sf-flow**
