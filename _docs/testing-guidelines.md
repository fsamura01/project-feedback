# Testing Guidelines

## Framework & Runner
- **Test Runner**: Vitest (`v3.x`) for both `server` and `client`.
- **Root execution**: `npm test` runs all tests across workspaces.
- **Targeted execution**:
  - Server: `npm --prefix server test`
  - Client: `npm --prefix client test`
  - Single file: `npx vitest run <path/to/test>`

## Server Testing Rules
1. **Unit & Integration**: Test controllers, service logic, and middleware in isolation using mock requests/responses or test database transactions.
2. **Business Rules to Cover**:
   - Deadline locking: Ensure submissions/edits are rejected once the deadline passes.
   - Task dependency cycle detection: Ensure circular graphs ($A \rightarrow B \rightarrow A$) are detected and rejected.
   - Permission guards: Verify `PROJECT_ADMIN` vs `TEAM_MEMBER` authorization checks.
   - Non-deletion audit rules: Verify check-in and update records cannot be hard deleted.

## Client Testing Rules
1. **Component Sanity**: Test rendering, state changes, and key user interactions.
2. **Deterministic Assertions**: Avoid flaky timeouts; mock Socket.io and API fetch responses where appropriate.
