# Orchestrator

**Purpose**: The Orchestrator is the central session that automates the hand‑off between the three core roles in SyncPulse – Product Manager (PM), Software Engineer, and QA Engineer. It never performs grooming, implementation, or testing itself; instead it spawns sub‑agents that each act as the corresponding role.

## Lifecycle

1. **Select Issue** – Query the backlog (`_docs/tasks.md` or GitHub issues) for the next *open* issue.
2. **PM Grooming** – Launch a **PM sub‑agent** to flesh out the issue (add acceptance criteria, labels, estimate, etc.).
3. **Implementation** – Launch a **Software Engineer sub‑agent**. It receives the groomed issue data and produces a PR/commit that implements the feature.
4. **Verification** – Launch a **QA sub‑agent**. It runs the test suite, checks the acceptance criteria, and outputs **PASS** or **FAIL**.
5. **Feedback Loop** – If QA returns **FAIL**, the orchestrator feeds the QA comment back to the Engineer sub‑agent and repeats step 3.
6. **Completion** – When QA returns **PASS**, the orchestrator closes the issue (GitHub `close` action) and records the success.
7. **Repeat** – Continue from step 1 until the backlog is empty.

## Rules (Enforced by the Orchestrator)

- **Step 2 (PM grooming) is mandatory** – an issue cannot be implemented until it has been groomed.
- **Engineers never close issues** – the orchestrator performs the final `close` after a PASS.
- **QA only reports PASS/FAIL** – no code changes are made by QA.
- **Fail → Re‑implementation** – on a FAIL the Engineer receives the QA comment as input and re‑runs implementation.
- **Pass → Close** – only after a PASS does the orchestrator close the issue.

## How It Works Internally

- The orchestrator runs as a long‑living Node.js script (`orchestrator.ts`) that uses the Antigravity agent APIs (`agy invoke_subagent`).
- It communicates with sub‑agents via JSON payloads:
  ```json
  { "issueId": 42, "title": "…", "description": "…" }
  ```
- After each sub‑agent finishes, the orchestrator evaluates the result and decides the next step.
- Logging and state are persisted to `server/src/orchestrator.log` for auditability.

## Placement in the Repository

- **File**: `server/src/orchestrator.ts`
- **Documentation**: This file (`_docs/orchestrator.md`) – referenced from `_docs/process.md` under a new heading *Automated Graph Engineering*.

---

*This orchestrator codifies the “graph engineering” concept: a directed graph of specialized agents (PM → Engineer → QA) with deterministic edges that automate the full issue lifecycle without manual hand‑offs.*
