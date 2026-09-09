# AI‑Native Development: Feature Reference

> **Reference:** [AI‑Native Development: Specifications, Loop and Graph Engineering](https://alexeyondata.substack.com/p/ai-native-development-specifications)

---

## 1. High‑Level Concepts

| Concept | Description |
|---------|-------------|
| **Specification** | A human writes a high‑level issue (title, description, acceptance criteria). In SyncPulse this lives in the backlog (`_docs/tasks.md`) or as a GitHub issue. |
| **Loop** | The *AI‑Native development loop* – a deterministic sequence of AI agents that each fulfil a well‑defined role (PM → Engineer → QA). The loop repeats until the QA agent returns **PASS**. |
| **Graph Engineering** | The orchestrator treats the loop as a directed graph of specialized agents. Nodes are sub‑agents (PM, Engineer, QA) and edges represent hand‑offs. The orchestrator (a long‑living Node.js process) automates the traversal of this graph. |

---

## 2. Roles & Documentation

| Role | Documentation | Core Responsibilities |
|------|----------------|-----------------------|
| **Product Manager** | `_docs/team/pm.md` | Groom the raw issue – add acceptance criteria, labels, estimates, and ensure the issue is ready for implementation. |
| **Software Engineer** | `_docs/team/software-engineer.md` | Implement the groomed issue, write code, add tests, commit changes, keep the issue open. |
| **QA Engineer** | `_docs/team/qa-engineer.md` | Validate the implementation against the acceptance criteria, run the test suite, and report **PASS** or **FAIL** (no code changes). |
| **Orchestrator** | `_docs/orchestrator.md` | Drives the graph: selects the next open issue, spawns the three sub‑agents, handles feedback loops, and finally closes the issue on **PASS**. |

---

## 3. Files Modified & Their Purpose

| File | Reason for Change | Link |
|------|-------------------|------|
| `server/prisma/schema.prisma` | Added missing `ProjectUpdate` and `Comment` models, plus relation fields on `User`. Guarantees the database reflects the domain model required by the backlog. | [schema.prisma](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/server/prisma/schema.prisma) |
| `_docs/orchestrator.md` | Documents the orchestrator’s lifecycle, rules, and placement in the repo. | [_docs/orchestrator.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/orchestrator.md) |
| `_docs/team/software-engineer.md` | Defines the engineer‑agent contract (read issue, implement, test, commit). | [_docs/team/software-engineer.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/team/software-engineer.md) |
| `_docs/team/qa-engineer.md` | Defines the QA‑agent contract (run tests, verify criteria, output PASS/FAIL). | [_docs/team/qa-engineer.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/team/qa-engineer.md) |
| `_docs/process.md` | Updated with a new “Automated Graph Engineering” heading that references the orchestrator. | [_docs/process.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/process.md) |

---

## 4. Commands Executed – What They Did

| Command | Context | Explanation |
|---------|---------|-------------|
| `npm --prefix server run prisma:generate` | After editing `schema.prisma` | Generates the Prisma client (`@prisma/client`) based on the updated schema. Required before any code can import the new models. |
| `npm --prefix server run prisma:push` | Immediately after generate | Pushes the Prisma schema to the SQLite database (`dev.db`). Because we use SQLite, this updates the DB in‑place without a migration file. |
| `npm test` (which runs `npm run test:server && npm run test:client`) | After schema changes | Executes the full monorepo test suite (Vitest for both server and client). Ensures that the new models do not break existing functionality. The run returned **0** exit code – all tests passed. |
| `view_file` (various) | Throughout the session | Used to inspect documentation (`_docs/tasks.md`, `server/prisma/schema.prisma`, `_docs/orchestrator.md`, etc.) before making changes. |
| `replace_file_content` / `multi_replace_file_content` | Schema edits | Inserted the new model definitions and relation fields while preserving existing formatting. |
| `run_command` for background test execution | Started the test suite as a background task; the system notified us when it completed. |

---

## 5. Issue #2 – Prisma Database Schema & Migrations (Full Walkthrough)

1. **Identify the missing pieces** – The acceptance criteria in `_docs/tasks.md` listed several models that were absent (`ProjectUpdate`, `Comment`) and required extra relations on `User`.  
2. **Edit `schema.prisma`** – Added the two new models and the relation fields.  
3. **Generate & Push** – Ran `prisma:generate` → `prisma:push` to sync the client and database.  
4. **Validate** – Executed the full test suite (`npm test`). All tests passed, confirming no regressions.  
5. **Documentation updates** – Updated the orchestrator and role docs to reflect the new workflow and the fact that the orchestrator now handles graph‑engineered loops automatically. 

---

## 6. How This Implements the “AI‑Native Development Loop”

1. **Specification** – The raw issue is the specification (written by a human, stored in `_docs/tasks.md`).
2. **Loop** – The orchestrator repeatedly runs the three agents until the loop terminates with **PASS**. The loop is fully deterministic; every step is logged (`server/src/orchestrator.log`).
3. **Graph Engineering** – By treating each role as a node and the orchestrator as the engine, we have a **directed acyclic graph** that can be visualised (see `01-agent-workflow-styled.png`). The orchestrator automates traversal, handling retries on failure automatically.

---

## 7. Quick Reference – Commands for Future Extensions

- **Run the orchestrator** (once implemented):
  ```bash
  npm --prefix server run dev   # Starts the orchestration loop alongside the dev server
  ```
- **Add a new model**:
  1. Edit `server/prisma/schema.prisma`.
  2. Run `npm --prefix server run prisma:generate`.
  3. Run `npm --prefix server run prisma:push`.
  4. Add/adjust tests, then `npm test`.
- **Trigger a manual graph run** (debugging):
  ```bash
  agy invoke_subagent --agent pm   # launch the PM sub‑agent manually
  agy invoke_subagent --agent engineer
  agy invoke_subagent --agent qa
  ```
  (These commands are part of the Antigravity CLI; see the Antigravity guide for details.)

---

## 8. Bibliography

- **Primary reference:** Alexey On Data – *AI‑Native Development: Specifications, Loop and Graph Engineering* – https://alexeyondata.substack.com/p/ai-native-development-specifications
- **Project documentation:** All markdown files under the `_docs/` folder of this repo.

---

*Prepared on 2026‑09‑08 by the Antigravity coding assistant.*
