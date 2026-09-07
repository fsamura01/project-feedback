# Implementation Plan: Option 3 (Node.js/Express + React/Vite + Socket.io + SQLite/Prisma)

A single-project team collaboration and weekly feedback MVP based on [_docs/plan.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/plan.md), featuring weekly check-ins with deadline locking, anytime updates feed, blocker management with in-app notifications, team member project statuses, DAG task management with attachments & dependencies, and admin-triggered AI weekly summaries.

## User Review Required

> [!IMPORTANT]
> **Database Choice**: We propose using **SQLite via Prisma ORM** for local zero-dependency development (no external database server needed), with full schema compatibility to switch to **PostgreSQL** by changing the provider in the Prisma schema.
> 
> **Real-time Engine**: **Socket.io** will handle bidirectional instant in-app alerts (blockers created/reopened, @mentions, and live status changes).
> 
> **AI Summary Provider**: We will support the **Google Gemini API** (via `@google/genai`) using an environment variable `GEMINI_API_KEY`.

---

## Architecture & Project Structure

The project will be organized as a clean full-stack monorepo with `client` and `server` folders:

```
project-feedback/
├── client/                     # Vite + React (TypeScript) SPA
│   ├── src/
│   │   ├── components/         # Reusable UI (Navbar, Modals, Badges, NotificationBell)
│   │   ├── context/            # AuthContext, SocketContext, NotificationContext
│   │   ├── pages/              # 10 core screens specified in plan.md
│   │   ├── services/           # API clients & socket listeners
│   │   └── styles/             # Modern CSS tokens, responsive layout, glassmorphism
│   ├── index.html
│   ├── package.json
│   └── vite.config.ts
├── server/                     # Node.js + Express + Socket.io (TypeScript)
│   ├── prisma/
│   │   └── schema.prisma       # Prisma data model & migrations
│   ├── src/
│   │   ├── controllers/        # Auth, CheckIns, Updates, Blockers, Tasks, AI, Admin
│   │   ├── middleware/         # Auth verification, role guards (Admin vs Member), uploads
│   │   ├── routes/             # REST endpoints
│   │   ├── services/           # AI summary generator, socket emitter, retention cron
│   │   ├── socket/             # Socket.io connection & room management
│   │   └── index.ts            # HTTP server & WebSocket bootstrap
│   ├── uploads/                # Local storage for task attachment documents/images
│   ├── package.json
│   └── tsconfig.json
├── package.json                # Root package.json with concurrent dev scripts
└── README.md
```

---

## Core Data Models (Prisma Schema)

1. **User**:
   - `id`, `name`, `email`, `passwordHash`, `role` (`PROJECT_ADMIN` | `TEAM_MEMBER`), `status` (`ON_TRACK` | `AT_RISK` | `BLOCKED` | `COMPLETED`), `statusExplanation`.
2. **WeeklyCheckIn**:
   - `id`, `userId`, `weekNumber`, `year`, `qAccomplished`, `qWorkingOn`, `qBlockers`, `qWorking`, `qNotWorking`, `comments`, `submittedAt`, `isLocked`.
3. **ProjectUpdate**:
   - `id`, `userId`, `content`, `createdAt` (non-deletable for auditability).
4. **Comment & Mention**:
   - `id`, `updateId`, `userId`, `content`, `parentId` (for replies), `createdAt`.
   - Mentions parsed and linked to `Notification`.
5. **Blocker**:
   - `id`, `creatorId`, `title`, `description`, `status` (`OPEN` | `RESOLVED`), `resolvedAt`, `reopenedAt`, `createdAt`.
6. **Task & TaskDependency**:
   - `id`, `title`, `description`, `assigneeId`, `priority` (`LOW` | `MEDIUM` | `HIGH` | `CRITICAL`), `status` (`TODO` | `IN_PROGRESS` | `COMPLETED`), `dueDate`, `parentId` (for subtasks).
   - `TaskDependency`: `taskId`, `dependsOnTaskId` (allows multiple prerequisites, validates against cyclic loops).
   - `TaskAttachment`: `id`, `taskId`, `fileName`, `fileUrl`, `fileType`, `uploadedAt`.
7. **Notification**:
   - `id`, `userId`, `type` (`BLOCKER_CREATED`, `BLOCKER_REOPENED`, `MENTION`, `WEEKLY_REMINDER`), `message`, `linkUrl`, `isRead`, `createdAt`.
8. **AiWeeklySummary**:
   - `id`, `weekNumber`, `year`, `generatedByUserId`, `contentMarkdown`, `createdAt`.
9. **ProjectSettings**:
   - `weeklyDeadlineDay` (e.g. Friday), `weeklyDeadlineTime` (e.g. 17:00), `retentionDays`, `notifyWeeklyReminder`, `notifyBlockers`, `notifyMentions`.

---

## Planned Screens (Following Section 18 of plan.md)

1. **Login & Project Access**: Simple authentication screen, pre-seeded with a Project Admin and sample Team Members.
2. **Project Dashboard**: Overall completion gauge, participation stats, team status board, active blockers banner, accomplishments & risks highlights.
3. **Weekly Check-In**: Structured form with the 5 required questions + comments; countdown to deadline; auto-locks when deadline passes.
4. **Anytime Updates Feed**: Chronological feed with rich text, threaded comments, `@mentions` autocomplete, and audit timestamps.
5. **Blockers Board**: Active vs. resolved blockers list, creator resolve action, admin reopen action, and resolution timeline.
6. **Tasks & Subtasks Board**: Kanban & List views with priority indicators, due dates, assignee avatars, subtask rollups, and dependency status badges.
7. **Task Detail Modal/View**: Manage subtasks, attach files/screenshots, inspect prerequisite dependencies, and update status.
8. **Team Members Directory**: Live list of members, their current statuses (`On Track`, `At Risk`, `Blocked`, `Completed`), and personal status notes.
9. **AI Weekly Summary**: Admin one-click "Generate Summary" button; markdown view of progress, accomplishments, blockers, and risks for the team.
10. **Project Admin Settings**: Configure weekly deadline, data retention duration, notification toggles, and team member management.

---

## Proposed Implementation Phases

### Phase 1: Workspace & Backend Setup
- Initialize root `package.json`, `server/`, and `client/`.
- Configure TypeScript, Express, Socket.io, and Prisma with SQLite.
- Write initial seed script with dummy team members, admin, and default settings.
- Implement Auth and REST endpoints (Users, Status, Settings).

### Phase 2: Core Feedback & Collaboration APIs
- Implement Weekly Check-In endpoints (with deadline checking logic).
- Implement Updates feed with threaded comments and `@mentions` parsing.
- Implement Blockers workflow with Socket.io real-time broadcast and notification creation.
- Set up `node-cron` for deadline locking and retention cleanup.

### Phase 3: Task Management & Attachments
- Implement Tasks CRUD with subtasks and multiple dependency support.
- Implement cycle-detection for task dependencies (preventing A -> B -> A).
- Implement `multer` for task attachments (screenshots, docs) and static file serving.
- Calculate dynamic project completion percentage.

### Phase 4: AI Weekly Summary Engine
- Integrate `@google/genai` (Google Gemini API).
- Create aggregation service to compile the week's check-ins, updates, tasks, and blockers into a structured prompt.
- Implement Admin-only trigger endpoint and persistence.

### Phase 5: Frontend Interface & Real-time Integration
- Setup Vite + React with custom modern design system (CSS custom properties, glassmorphism, responsive navigation, notification bell).
- Build the 10 screens with responsive layouts and empty/loading states.
- Connect Socket.io client for real-time notification toasts and badge counts.

---

## Verification Plan

### Automated Tests:
- Run Prisma migrations and seed script: `npx prisma db push && npx prisma db seed`
- Run API unit/integration tests for:
  - Task dependency cycle detection.
  - Deadline locking rule (editing rejected after deadline).
  - In-app notification creation on blocker submission and `@mention`.

### Manual Verification:
- Log in as **Project Admin** and configure a deadline.
- Log in as **Team Member**, submit a check-in, create an anytime update with `@mention`, and submit a blocker.
- Verify real-time notification badge and popup appear on the Admin's screen via Socket.io.
- Create tasks with dependencies and upload attachments; verify completion percentage updates.
- Trigger AI weekly summary generation as Admin and verify output across team views.
