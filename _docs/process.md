# Process & Workflow Guidelines

## 1. Task Execution
- Tasks are tracked as individual GitHub issues ([Issues](https://github.com/fsamura01/project-feedback/issues)) and cataloged in [_docs/tasks.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/tasks.md).
- Work strictly on **one task at a time**. Do not implement premature features or jump ahead to unassigned tasks.
- Always read and understand the task's **Goal** and **Description** (acceptance criteria) before starting work, and review them again before closing the task.

## 2. Verification & Quality Gates
- Before considering any task complete:
  - Run the full test suite (`npm test`) — all tests must pass with 0 errors.
  - Run the build check (`npm run build`) — TypeScript compilation and Vite packaging must succeed with 0 errors.
- Never disable or skip existing tests.

## 3. Version Control & Commits
- Commit regularly with concise, descriptive commit messages describing the change (e.g. `feat(server): add task dependency cycle detection`).
- Keep commits scoped to the active task.
- Always **commit the current working code before updating documentation** when recording corrections or learnings.

## 4. Dependencies & Architecture Integrity
- Do not install new npm packages or external dependencies without asking first.
- Maintain data integrity: never implement hard deletion for weekly check-ins or project updates (auditability requirement).

## 5. Living Documentation & Continuous Improvement

## Roles
- PM — grooms a task before anyone implements it, follows `_docs/team/pm.md`
- Engineer — implements one groomed task, follows `_docs/team/software-engineer.md`
- QA — checks the result against the acceptance criteria, follows `_docs/team/qa-engineer.md`
- **Labels**: `AMVP` (Assumed Minimum Viable Product) for core MVP issues (2‑31); `post‑MVP` for out‑of‑scope issues.

- All documents in `_docs/` and `AGENTS.md` are living documents.
- When corrections, feedback, or operational clarifications occur during a session, identify the relevant document (`_docs/process.md`, `_docs/testing-guidelines.md`, `_docs/design-system.md`, etc.) and update it.
- Updating documentation prevents recurring errors and ensures subsequent sessions retain full project knowledge.

## 6. Coding & Module Import Conventions
- **Client (React + Vite)**: Uses bundler resolution. Omit file extensions when importing local `.ts` or `.tsx` files (e.g., `import App from './App'`). Do not use `./App.js` in the client.
- **Server (Node.js + ESM)**: Uses `NodeNext` resolution. Always include the explicit `.js` extension for relative imports (e.g., `import prisma from '../prisma.js'`).
