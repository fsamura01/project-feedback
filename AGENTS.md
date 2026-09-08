# AGENTS.md

## Project Overview
SyncPulse is a single-project team collaboration and weekly feedback tool built as a TypeScript monorepo with `server` (Node.js/Express, Socket.io, SQLite/Prisma) and `client` (React/Vite).


## Documents
- `_docs/process.md` — how work is organized, task workflows, and quality gates
- For grooming tasks, read `_docs/team/pm.md` and use `_docs/task-template.md`
- Before writing tests, read `_docs/testing-guidelines.md`
- For anything touching the UI, read `_docs/design-system.md`
- For system architecture and data models, read `_docs/architecture.md`
- Product specification: `_docs/plan.md`
- Task backlog: `_docs/tasks.md`
- GitHub issues: [https://github.com/fsamura01/project-feedback/issues](https://github.com/fsamura01/project-feedback/issues)

## Essential Commands

### Install Dependencies
- `npm install` — install dependencies for root and all workspaces (`server` and `client`)

### Testing
- `npm test` — run the entire test suite across server and client
- `npm --prefix server test` — run server tests only (Vitest)
- `npm --prefix client test` — run client tests only (Vitest)
- `npx vitest run <path-to-test>` — run a specific test file

### Building & Type Checking
- `npm run build` — compile both server (`tsc`) and client (`tsc && vite build`)
- `npm --prefix server run build` — compile server TypeScript
- `npm --prefix client run build` — compile and bundle client

### Local Development
- `npm run dev` — start both server (port 5000) and client (port 5173) concurrently
- `npm --prefix server run dev` — run server in watch mode with `tsx`
- `npm --prefix client run dev` — run client with Vite dev server

### Database (Server)
- `npm --prefix server run prisma:generate` — generate Prisma client
- `npm --prefix server run prisma:push` — push schema changes to local SQLite database
- `npm --prefix server run prisma:seed` — reseed database with demo users and data

## Working Rules
- Dependencies: Do not add new npm packages without asking first.
- Module Imports: Omit file extensions in `client/` (e.g. `import App from './App'`); use explicit `.js` extensions in `server/` (NodeNext ESM).
- Living Docs: Always commit current working code before updating documents when learning from corrections.
