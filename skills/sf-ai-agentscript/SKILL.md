---
name: sf-ai-agentscript
description: >
  Creates Agent Script DSL files for defining conversational flows
  using finite state machine patterns. Use when writing .agent script
  files, designing conversation state machines, defining agent dialog
  trees, or working with Agent Script syntax. Do NOT use for Agent
  Builder configuration (use sf-ai-agentforce) or persona design
  (use sf-ai-agentforce-persona).
---

# Agent Script DSL

## Core Responsibilities

1. Write Agent Script files (.agent) using the DSL syntax
2. Design finite state machine (FSM) conversation flows
3. Define states, transitions, conditions, and actions
4. Integrate script-defined flows with Agentforce agents
5. Validate script syntax and logic

## Agent Script Syntax

### Basic Structure

```
agent CustomerSupport {
    description: "Handles customer support inquiries"
    version: "1.0"

    state Start {
        entry {
            say "Hello! How can I help you today?"
        }
        on "order" -> OrderInquiry
        on "return" -> ReturnProcess
        on "billing" -> BillingHelp
        fallback -> Clarify
    }

    state Clarify {
        entry {
            say "I can help with orders, returns, or billing. Which area do you need help with?"
        }
        on "order" -> OrderInquiry
        on "return" -> ReturnProcess
        on "billing" -> BillingHelp
        max_attempts: 3
        on_max_attempts -> Escalate
    }

    state OrderInquiry {
        entry {
            ask "What is your order number?"
            store -> orderNumber
        }
        validate {
            match orderNumber /^ORD-\d{4,}$/
            on_invalid {
                say "Please provide a valid order number (e.g., ORD-1001)"
                retry
            }
        }
        action {
            invoke OrderLookupAction(orderNumber: orderNumber)
            store result -> orderDetails
        }
        on success -> ShowOrderDetails
        on error -> OrderNotFound
    }

    state ShowOrderDetails {
        entry {
            say "Your order {{orderDetails.status}}. Expected delivery: {{orderDetails.deliveryDate}}"
            say "Is there anything else I can help with?"
        }
        on "yes" -> Start
        on "no" -> End
    }

    state OrderNotFound {
        entry {
            say "I couldn't find that order number. Let me connect you with a specialist."
        }
        -> Escalate
    }

    state ReturnProcess {
        entry {
            ask "What is the order number for the item you'd like to return?"
            store -> returnOrderNumber
        }
        action {
            invoke InitiateReturnAction(orderNumber: returnOrderNumber)
        }
        on success -> ReturnConfirmed
        on error -> Escalate
    }

    state ReturnConfirmed {
        entry {
            say "Your return has been initiated. You'll receive an email with a shipping label."
        }
        -> End
    }

    state Escalate {
        entry {
            say "Let me connect you with a team member who can help further."
            handoff reason: "Agent script escalation"
        }
    }

    state End {
        entry {
            say "Thank you for contacting us. Have a great day!"
            close
        }
    }
}
```

## DSL Elements

### States

| Keyword | Description |
|---|---|
| `state <Name>` | Define a named state |
| `entry { }` | Actions executed when entering the state |
| `on "<trigger>" -> <State>` | Transition on user input match |
| `fallback -> <State>` | Default transition for unmatched input |
| `-> <State>` | Unconditional transition |

### Actions

| Keyword | Description |
|---|---|
| `say "<message>"` | Send message to user |
| `ask "<question>"` | Prompt user for input |
| `store -> <variable>` | Store user response in variable |
| `invoke <Action>(params)` | Call an external action |
| `handoff reason: "<text>"` | Escalate to human agent |
| `close` | End the conversation |

### Control Flow

| Keyword | Description |
|---|---|
| `validate { }` | Input validation block |
| `match <var> /<regex>/` | Regex validation |
| `on_invalid { }` | Handler for invalid input |
| `retry` | Re-prompt for input |
| `max_attempts: <n>` | Max retries before fallback |
| `on_max_attempts -> <State>` | Transition after max retries |

### Conditions

| Keyword | Description |
|---|---|
| `on success -> <State>` | Transition on action success |
| `on error -> <State>` | Transition on action failure |
| `when <condition> -> <State>` | Conditional transition |

## FSM Design Patterns

### Linear Flow
```
Start -> CollectInfo -> Process -> Confirm -> End
```

### Branching Flow
```
Start -> Classify
  ├── Topic A -> Process A -> Confirm -> End
  ├── Topic B -> Process B -> Confirm -> End
  └── Unknown -> Clarify -> Start
```

### Loop with Retry
```
AskInput -> Validate
  ├── valid -> Process
  └── invalid -> AskInput (max 3, then Escalate)
```

## Best Practices

- Keep state names descriptive and PascalCase
- Every script must have `Start` and `End` states
- Always include an `Escalate` state as safety net
- Use `fallback` transitions to prevent dead ends
- Validate user input before passing to actions
- Limit `max_attempts` to prevent infinite loops (3 is typical)
- Store all action results for use in later states

## Cross-Skill References

- For Apex invocable actions referenced by `invoke`: see **sf-apex**
- For agent configuration in Agent Builder: see **sf-ai-agentforce**
- For testing conversation flows: see **sf-ai-agentforce-testing**
