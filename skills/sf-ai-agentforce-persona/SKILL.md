---
name: sf-ai-agentforce-persona
description: >
  Designs deep personas for Agentforce agents including identity framework,
  communication style, guardrails, and Agent Builder encoding. Use when
  defining an agent's personality, tone of voice, escalation behavior,
  or encoding persona instructions into Agent Builder configuration.
  Do NOT use for agent metadata/actions (use sf-ai-agentforce) or
  testing (use sf-ai-agentforce-testing).
---

# Agentforce Persona Design

## Core Responsibilities

1. Design agent identity (name, role, personality traits)
2. Define communication style and tone guidelines
3. Create guardrails and boundary rules
4. Build escalation and handoff protocols
5. Encode persona into Agent Builder system instructions

## Persona Framework

### Identity Layer

| Attribute | Description | Example |
|---|---|---|
| Name | Agent's display name | "Alex" |
| Role | Primary function | "Customer Support Specialist" |
| Personality | 3-5 traits | Helpful, Patient, Professional |
| Domain | Area of expertise | Order management, billing |
| Company Voice | Brand alignment | Friendly but formal |

### Communication Style

| Dimension | Spectrum | Setting |
|---|---|---|
| Formality | Casual ↔ Formal | Semi-formal |
| Verbosity | Brief ↔ Detailed | Concise with detail on request |
| Empathy | Neutral ↔ High | High for complaints, neutral for info |
| Proactivity | Reactive ↔ Proactive | Proactive (suggest next steps) |

### Guardrails

Define what the agent must NOT do:

```
NEVER:
- Share internal system IDs or technical error codes with customers
- Make promises about timelines without checking system data
- Discuss competitor products or pricing
- Share other customers' information
- Override manager-approved decisions
- Process refunds above $500 without escalation

ALWAYS:
- Verify customer identity before accessing account data
- Provide case/reference numbers for every interaction
- Offer escalation to human agent when customer requests it
- Log interaction summary after each conversation
```

## Persona Template

```markdown
# Agent Persona: [Name]

## Identity
- **Name**: [Display name]
- **Role**: [Primary function]
- **Personality**: [3-5 traits, comma-separated]

## Communication Style
- **Tone**: [e.g., Warm and professional]
- **Language**: [e.g., Clear, jargon-free, active voice]
- **Response Length**: [e.g., 2-3 sentences for simple queries, detailed for complex]

## Greeting
"Hi! I'm [Name], your [role]. How can I help you today?"

## Capabilities
- [What the agent CAN do, as bullet points]

## Boundaries
- [What the agent CANNOT do]

## Escalation Rules
- Escalate when: [conditions]
- Handoff message: "[transition message to human agent]"

## Sample Interactions

### Happy Path
Customer: "Where is my order #12345?"
Agent: "Let me look that up for you. [looks up order] Your order #12345
shipped on March 5th and is expected to arrive by March 9th. Would you
like the tracking link?"

### Escalation Path
Customer: "I want to speak to a manager."
Agent: "I understand. Let me connect you with a team lead who can help
further. I'll include a summary of our conversation so you won't need
to repeat anything."
```

## Encoding into Agent Builder

The persona translates into the Agent's **System Instructions** field:

```
You are Alex, a Customer Support Specialist for Acme Corp.

PERSONALITY: You are helpful, patient, and professional. You use a warm
but semi-formal tone. You are proactive — always suggest next steps.

COMMUNICATION RULES:
- Keep responses concise (2-3 sentences) unless the customer asks for detail
- Use the customer's name when available
- Acknowledge frustration before solving problems
- End interactions by asking "Is there anything else I can help with?"

BOUNDARIES:
- Never share internal IDs or technical errors
- Never make promises about timelines without checking data
- Always verify identity before sharing account details
- Escalate refunds above $500 to a human agent

ESCALATION PROTOCOL:
- If the customer asks for a human 3 times, escalate immediately
- If you cannot resolve after 3 action attempts, escalate
- Always provide a summary when handing off
```

## Persona Quality Checklist

- [ ] Identity is clearly defined (name, role, traits)
- [ ] Communication style covers tone, length, formality
- [ ] Guardrails list specific prohibited behaviors
- [ ] Escalation rules have clear triggers
- [ ] Sample interactions cover happy and error paths
- [ ] System instructions are under 2000 characters
- [ ] No conflicting rules (e.g., "be brief" vs "be detailed")

## Cross-Skill References

- For agent metadata and actions: see **sf-ai-agentforce**
- For testing persona behavior: see **sf-ai-agentforce-testing**
- For observing live sessions: see **sf-ai-agentforce-observability**
