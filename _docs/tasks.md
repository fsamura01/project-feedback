# Project Backlog — SyncPulse MVP (Groomed)

This backlog defines fully groomed, checkable specifications for every task in the SyncPulse project based on [_docs/plan.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/plan.md), [_docs/architecture.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/architecture.md), and [_docs/task-template.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/task-template.md).

---

## 1. Empty Project Setup with a Passing Test
[Completed] Root monorepo scaffolding with server (Node.js/Express, TypeScript) and client (React/Vite, TypeScript), core build tooling, passing Vitest sanity tests, and clean `npm test` execution.


---

# 2. Prisma Database Schema and Migrations
[GitHub Issue #2](https://github.com/fsamura01/project-feedback/issues/2)

## Goal
Define the complete relational database schema for the SyncPulse project using Prisma with SQLite, generating all models, relations, and the local SQLite database.

## Acceptance criteria
- [ ] `server/prisma/schema.prisma` defines all required models: `User`, `WeeklyCheckIn`, `ProjectUpdate`, `Comment`, `Blocker`, `Task`, `TaskDependency`, `TaskAttachment`, `Notification`, `AiWeeklySummary`, and `ProjectSettings`
- [ ] `WeeklyCheckIn` contains fields for the 5 mandatory questions (`qAccomplished`, `qWorkingOn`, `qBlockers`, `qWorking`, `qNotWorking`), optional `comments`, `weekNumber`, `year`, `userId`, `submittedAt`, and boolean `isLocked` (default false)
- [ ] `WeeklyCheckIn` enforces a compound unique constraint on `[userId, weekNumber, year]`
- [ ] `Blocker` model includes `creatorId`, `title`, `description`, `status` (`OPEN` / `RESOLVED`), nullable `resolvedAt`, and nullable `reopenedAt`
- [ ] `Task` model includes `title`, `description`, `assigneeId`, `priority` (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`), `status` (`TODO`, `IN_PROGRESS`, `COMPLETED`), required `dueDate`, and self-referencing `parentId` for subtasks
- [ ] `TaskDependency` model supports multiple prerequisites via composite unique `[taskId, dependsOnTaskId]`
- [ ] `ProjectSettings` includes `weeklyDeadlineDay` (default 5 for Friday), `weeklyDeadlineTime` (default "17:00"), `retentionDays` (default 90), and boolean toggles for `notifyWeeklyReminder`, `notifyBlockers`, and `notifyMentions`
- [ ] Running `npm --prefix server run prisma:generate` generates the Prisma client without errors
- [ ] Running `npm --prefix server run prisma:push` applies schema to local SQLite database `server/prisma/dev.db` cleanly

## Out of scope
- Populating sample users and mock data, moved to #3
- API endpoints connecting to Prisma, moved to #4 through #19

## Constraints
- Files must stay inside `server/prisma/` and `server/package.json`
- SQLite database provider (`file:./dev.db`)
- Follow data architecture in `_docs/architecture.md` Section 3

---

# 3. Database Seeding Script with Demo Personas
[GitHub Issue #3](https://github.com/fsamura01/project-feedback/issues/3)

## Goal
Create an automated database seed script that populates the database with realistic demo users, check-ins, updates, blockers, and tasks for local development and testing.

## Acceptance criteria
- [ ] `server/prisma/seed.ts` cleans up existing records before insertion to guarantee idempotent re-runs
- [ ] Seeds 1 Project Admin user (`alex@team.com` / password: `password123`) with role `PROJECT_ADMIN`
- [ ] Seeds at least 3 Team Member users (`maya@team.com`, `jordan@team.com`, `carlos@team.com` / password: `password123`) with role `TEAM_MEMBER`
- [ ] Seeds distinct member statuses: at least one `ON_TRACK`, one `AT_RISK`, and one `BLOCKED` with status explanations
- [ ] Seeds default `ProjectSettings` (Friday 17:00, 90 days retention, notification toggles enabled)
- [ ] Seeds at least 2 weekly check-in records for the current calendar week and year
- [ ] Seeds at least 1 anytime project update with comments and an `@mention`
- [ ] Seeds at least 1 active blocker and 1 resolved blocker with `resolvedAt` timestamp
- [ ] Seeds tasks with subtasks and multiple dependencies (e.g. Task 2 depends on Task 1)
- [ ] Running `npm --prefix server run prisma:seed` executes cleanly with code 0 and logs credentials to stdout

## Out of scope
- Auth login endpoint, moved to #4
- Frontend persona switcher UI, moved to #21

## Constraints
- Files must stay inside `server/prisma/seed.ts` and `server/package.json`
- Use `bcryptjs` for password hashing
- Passwords must be hashed with salt factor 10

---

# 4. User Authentication and JWT Role Guard API
[GitHub Issue #4](https://github.com/fsamura01/project-feedback/issues/4)

## Goal
Implement authentication endpoints and middleware to authenticate users via JWT and enforce role-based access control for Project Admins and Team Members.

## Acceptance criteria
- [ ] `POST /api/auth/login` accepts `email` and `password`, returns HTTP 200 with JWT token and user profile object on valid credentials
- [ ] `POST /api/auth/login` returns HTTP 401 on invalid email or incorrect password
- [ ] `POST /api/auth/login` normalizes email to lowercase and trims whitespace
- [ ] `GET /api/auth/me` returns HTTP 200 with currently logged-in user profile when supplied valid Bearer token
- [ ] `GET /api/auth/me` returns HTTP 401 when Bearer token is missing, malformed, or expired
- [ ] `authenticate` middleware attaches decoded user (`id`, `email`, `name`, `role`) to Express `req.user`
- [ ] `requireAdmin` middleware allows requests from users with `role === 'PROJECT_ADMIN'` and returns HTTP 403 for `TEAM_MEMBER`

## Out of scope
- Password reset and email verification, deferred post-MVP
- User status update API, moved to #5
- Frontend login page, moved to #21

## Constraints
- Stay inside `server/src/middleware/auth.ts`, `server/src/controllers/authController.ts`, and `server/src/routes/`
- Use `jsonwebtoken` and `bcryptjs`
- Follow RBAC matrix in `_docs/architecture.md` Section 8

---

# 5. Team Member Status Update API
[GitHub Issue #5](https://github.com/fsamura01/project-feedback/issues/5)

## Goal
Implement API endpoints allowing team members to view all members and manually update their own project status and explanation.

## Acceptance criteria
- [ ] `GET /api/users` returns HTTP 200 with an array of all team members including `id`, `name`, `email`, `role`, `status`, `statusExplanation`, and `avatar`
- [ ] `PATCH /api/users/me/status` accepts `status` and optional `statusExplanation` string
- [ ] `PATCH /api/users/me/status` validates `status` against allowed values: `ON_TRACK`, `AT_RISK`, `BLOCKED`, `COMPLETED`; rejects invalid values with HTTP 400
- [ ] `PATCH /api/users/me/status` updates only the authenticated user's record in the database
- [ ] `PATCH /api/users/me/status` returns HTTP 200 with the updated user profile
- [ ] Creating a blocker does NOT automatically alter user status (manual control preserved per plan.md Section 6)
- [ ] Emits a real-time event (`user:status_updated`) if Socket.io is connected

## Out of scope
- Modifying other users' statuses (each member updates only their own)
- Frontend status dropdown UI, moved to #23 and #29

## Constraints
- Stay inside `server/src/controllers/authController.ts` or `server/src/controllers/userController.ts`
- Protect endpoints with `authenticate` middleware
- Follow Status Options in `_docs/plan.md` Section 6

---

# 6. Real-Time Socket.io Server and Room Infrastructure
[GitHub Issue #6](https://github.com/fsamura01/project-feedback/issues/6)

## Goal
Establish a bidirectional Socket.io server integrated with Express HTTP server, supporting token authentication, workspace broadcast rooms, and individual user notification rooms.

## Acceptance criteria
- [ ] Socket.io server attaches to the existing Express HTTP server on the same port
- [ ] Configures CORS to permit connections from client dev URL (`http://localhost:5173`)
- [ ] Authenticates incoming socket connections via JWT passed in `handshake.auth.token`
- [ ] Automatically joins authenticated sockets into the global workspace room: `workspace`
- [ ] Automatically joins authenticated sockets into a private user room: `user:<userId>`
- [ ] Exposes helper functions: `notifyUser(userId, notification)`, `broadcastNotification(notification, excludeUserId)`, and `emitWorkspaceEvent(event, data)`
- [ ] Gracefully handles socket disconnections without server crashes or memory leaks

## Out of scope
- Specific event dispatchers for check-ins or blockers, moved to #7, #10, and #11
- Client-side notification toast listener, moved to #22

## Constraints
- Stay inside `server/src/socket/` and `server/src/index.ts`
- Use `socket.io` library already installed
- Follow Socket topology in `_docs/architecture.md` Section 5

---

# 7. Weekly Check-In Submission and Editing API
[GitHub Issue #7](https://github.com/fsamura01/project-feedback/issues/7)

## Goal
Build endpoints for submitting, editing, and viewing weekly check-ins with deadline locking and auditability rules.

## Acceptance criteria
- [ ] `GET /api/checkins/info` returns current `weekNumber`, `year`, configured deadline, and boolean `isDeadlinePassed`
- [ ] `GET /api/checkins` returns all check-ins for a specified week and year, along with participation rate and list of missing members
- [ ] `GET /api/checkins/me` returns authenticated user's check-in for the current week, plus `canEdit` boolean flag
- [ ] `POST /api/checkins` validates that all 5 required questions (`qAccomplished`, `qWorkingOn`, `qBlockers`, `qWorking`, `qNotWorking`) are non-empty strings
- [ ] `POST /api/checkins` creates or updates the user's weekly check-in via upsert on `[userId, weekNumber, year]`
- [ ] If the current timestamp is past the configured deadline or record is marked `isLocked: true`, `POST /api/checkins` rejects request with HTTP 403 Forbidden
- [ ] Hard deletion of submitted check-ins is prohibited (no DELETE endpoint exposed per plan.md Section 3)
- [ ] Emits `checkin:submitted` event to workspace room on successful submission

## Out of scope
- Automatic deadline background lock cron, moved to #8
- Frontend check-in form UI, moved to #24

## Constraints
- Stay inside `server/src/controllers/checkInController.ts` and `server/src/routes/`
- Follow Questions and Editing Rules in `_docs/plan.md` Section 3

---

# 8. Automated Weekly Deadline Locking and Reminder Cron Job
[GitHub Issue #8](https://github.com/fsamura01/project-feedback/issues/8)

## Goal
Implement a background cron scheduler that automatically locks weekly check-ins once the deadline passes and dispatches reminder notifications to members who have not submitted.

## Acceptance criteria
- [ ] Configures a `node-cron` job running on a regular schedule (e.g. every 10 minutes)
- [ ] Compares current day and time against `ProjectSettings.weeklyDeadlineDay` and `ProjectSettings.weeklyDeadlineTime`
- [ ] When deadline has passed, batch-updates all unlocked check-ins for the active week to `isLocked: true`
- [ ] Emits `checkins:locked` event to workspace room when check-ins are locked
- [ ] When within 24 hours of deadline and `notifyWeeklyReminder` is enabled, identifies team members who have not yet submitted a check-in
- [ ] Creates a `Notification` of type `WEEKLY_REMINDER` for unsubmitted members and emits `notification:new` to their user room
- [ ] Avoids sending duplicate reminders to the same user within a 24-hour window

## Out of scope
- Data retention cron job, moved to #16
- Project admin settings configuration API, moved to #17

## Constraints
- Stay inside `server/src/services/cron.ts`
- Use `node-cron`
- Follow sequence diagram in `_docs/architecture.md` Section 6

---

# 9. Anytime Updates Feed and Threaded Comments API
[GitHub Issue #9](https://github.com/fsamura01/project-feedback/issues/9)

## Goal
Implement API endpoints for publishing anytime project updates and threaded comments with non-deletable audit enforcement.

## Acceptance criteria
- [ ] `GET /api/updates` returns all project updates in reverse chronological order with author info and nested comments
- [ ] `POST /api/updates` creates a new update with non-empty string `content` authored by the authenticated user
- [ ] `POST /api/updates` rejects empty or whitespace-only content with HTTP 400 Bad Request
- [ ] Updates cannot be deleted by users after submission (no DELETE endpoint exposed per plan.md Section 4)
- [ ] `POST /api/updates/:updateId/comments` adds a comment to an update, supporting optional `parentId` for threaded replies
- [ ] Emits `update:created` and `comment:created` events to the workspace room over Socket.io

## Out of scope
- In-app @mention parsing and notification dispatch, moved to #10
- Frontend feed and composer view, moved to #25

## Constraints
- Stay inside `server/src/controllers/updatesController.ts` and `server/src/routes/`
- Authenticate all endpoints with `authenticate` middleware
- Follow Anytime Updates spec in `_docs/plan.md` Section 4

---

# 10. In-App @Mention Parsing and Notification Pipeline
[GitHub Issue #10](https://github.com/fsamura01/project-feedback/issues/10)

## Goal
Detect @mentions in updates and comments, create in-app notification records, and deliver real-time alerts to tagged users.

## Acceptance criteria
- [ ] Scans update and comment content for `@username` patterns using regex
- [ ] Matches mentions against first names and full names of active users case-insensitively
- [ ] Checks `ProjectSettings.notifyMentions` before dispatching; skips notification if disabled
- [ ] Creates a `Notification` record in database with `type: 'MENTION'`, title, snippet message, and deep link `linkUrl: '/updates'`
- [ ] Dispatches real-time `notification:new` event to the mentioned user's private socket room (`user:<userId>`)
- [ ] Does not trigger a notification if a user mentions themselves

## Out of scope
- Email notifications (explicitly excluded for MVP per plan.md Section 5)
- Frontend toast and notification bell UI, moved to #22

## Constraints
- Stay inside `server/src/controllers/updatesController.ts` or dedicated notification service
- Use existing Socket.io helper `notifyUser`
- Follow In-App Only decision in `_docs/plan.md` Section 5

---

# 11. Blocker Reporting, Resolution, and Admin Reopening API
[GitHub Issue #11](https://github.com/fsamura01/project-feedback/issues/11)

## Goal
Build endpoints for reporting blockers with automatic team notifications, creator-only resolution, and admin-only reopening.

## Acceptance criteria
- [ ] `GET /api/blockers` returns all blockers ordered with `OPEN` blockers first, followed by resolved history
- [ ] `POST /api/blockers` requires non-empty `title` and `description`, sets status to `OPEN`, and records `creatorId`
- [ ] When blocker is created and `ProjectSettings.notifyBlockers` is true, creates in-app notifications for all other team members and broadcasts `notification:new`
- [ ] `PATCH /api/blockers/:id/resolve` allows only the blocker's creator (or Project Admin) to resolve it, setting `status: 'RESOLVED'` and `resolvedAt` timestamp
- [ ] If non-creator attempts to resolve, returns HTTP 403 Forbidden
- [ ] `PATCH /api/blockers/:id/reopen` allows strictly users with `role: 'PROJECT_ADMIN'` to reopen a resolved blocker, setting `status: 'OPEN'` and `reopenedAt`
- [ ] If team member attempts to reopen, returns HTTP 403 Forbidden
- [ ] Resolved blockers remain accessible in project history and are never deleted

## Out of scope
- Changing user's project status on blocker creation (explicitly prohibited per plan.md Section 6)
- Frontend blockers board, moved to #26

## Constraints
- Stay inside `server/src/controllers/blockersController.ts` and `server/src/routes/`
- Follow Blocker Behavior in `_docs/plan.md` Section 5

---

# 12. Task and Subtask CRUD API
[GitHub Issue #12](https://github.com/fsamura01/project-feedback/issues/12)

## Goal
Build REST endpoints to create, read, update, and delete project tasks and hierarchical subtasks with assignee, priority, status, and due date.

## Acceptance criteria
- [ ] `GET /api/tasks` returns all root tasks (`parentId: null`) populated with subtasks, assignees, attachments, and dependency links
- [ ] `GET /api/tasks/:id` returns single task detail with subtasks and dependencies
- [ ] `POST /api/tasks` validates that `title` and `dueDate` are present; returns HTTP 400 if missing
- [ ] `POST /api/tasks` validates `priority` (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`) and `status` (`TODO`, `IN_PROGRESS`, `COMPLETED`)
- [ ] Supports `parentId` field to create subtasks using the exact same model attributes as top-level tasks
- [ ] `PUT /api/tasks/:id` updates task attributes and emits `task:updated` over Socket.io
- [ ] `DELETE /api/tasks/:id` deletes task and cascades to subtasks, attachments, and dependencies

## Out of scope
- Dependency cycle graph validation, moved to #13
- File attachment uploads, moved to #14
- Frontend tasks board, moved to #27

## Constraints
- Stay inside `server/src/controllers/tasksController.ts` and `server/src/routes/`
- Follow Task Management specifications in `_docs/plan.md` Sections 9, 10, and 11

---

# 13. Task Dependency Graph Engine and Cycle Detection
[GitHub Issue #13](https://github.com/fsamura01/project-feedback/issues/13)

## Goal
Implement multiple prerequisite dependency linking for tasks with graph traversal cycle detection to prevent circular deadlocks.

## Acceptance criteria
- [ ] A task can declare dependencies on multiple other tasks via `TaskDependency` junction model
- [ ] Before linking task A as dependent on task B, algorithm checks if task A is already reachable from B (e.g. via DFS traversal)
- [ ] If adding dependency would create a cycle (e.g. A -> B -> A or A -> B -> C -> A), request is rejected with HTTP 400 Bad Request and descriptive error message
- [ ] Self-dependency (task depending on itself) is rejected with HTTP 400
- [ ] Valid dependencies are saved and returned with task queries (`dependencies` and `requiredBy`)
- [ ] Unit tests in `server/src/services/dependencyGraph.test.ts` verify cycle detection for direct (2-node) and indirect (3+ node) loops

## Out of scope
- Gantt chart visualization
- Frontend dependency picker modal, moved to #28

## Constraints
- Algorithm in `server/src/controllers/tasksController.ts` or `server/src/services/dependencyGraph.ts`
- Follow Multiple Task Dependencies decision in `_docs/plan.md` Section 12

---

# 14. Task File Attachment Upload and Serving API
[GitHub Issue #14](https://github.com/fsamura01/project-feedback/issues/14)

## Goal
Implement file upload endpoints allowing screenshots and documents to be attached to tasks, storing files safely and serving them statically.

## Acceptance criteria
- [ ] Configures `multer` middleware with a 15 MB file size limit
- [ ] `POST /api/tasks/:id/attachments` accepts single file upload (`multipart/form-data`)
- [ ] Stores files on disk in `server/uploads/` with sanitized, cryptographically unique filenames to prevent overwrites
- [ ] Creates a `TaskAttachment` record with `taskId`, `fileName`, `originalName`, `fileUrl`, `fileType`, and `fileSize`
- [ ] Static route `/uploads/:filename` serves uploaded files with correct MIME headers
- [ ] Emits `task:attachment_added` event to workspace room over Socket.io

## Out of scope
- Cloud storage integration (S3/Cloudflare R2), deferred post-MVP
- Frontend drag-and-drop attachment UI, moved to #28

## Constraints
- Stay inside `server/src/middleware/upload.ts`, `server/src/controllers/tasksController.ts`, and `server/src/index.ts`
- Store files locally in `server/uploads/` with `.gitkeep` preserving directory

---

# 15. Dynamic Project Completion Percentage Calculation Service
[GitHub Issue #15](https://github.com/fsamura01/project-feedback/issues/15)

## Goal
Build a calculation service that computes the project's overall completion percentage based on tasks and team member statuses.

## Acceptance criteria
- [ ] Implements formula combining task completion ratios and team member project statuses
- [ ] Accounts for completed tasks (`status === 'COMPLETED'`) out of total active tasks
- [ ] Accounts for team member statuses (`ON_TRACK`, `AT_RISK`, `BLOCKED`, `COMPLETED`)
- [ ] Handles zero-task edge case gracefully (returns 0% instead of NaN or division by zero)
- [ ] Returns clamped percentage between 0 and 100 as an integer
- [ ] `GET /api/dashboard/stats` returns the calculated percentage, task count breakdown, and team status breakdown
- [ ] Unit tests verify formula outputs for various combinations of task statuses and member states

## Out of scope
- Full dashboard frontend widgets, moved to #23

## Constraints
- Stay inside `server/src/services/completionCalculator.ts` and `server/src/controllers/dashboardController.ts`
- Follow Project Completion Percentage in `_docs/plan.md` Section 7

---

# 16. Data Retention Policy Cleanup Background Job
[GitHub Issue #16](https://github.com/fsamura01/project-feedback/issues/16)

## Goal
Implement automated background cleanup that permanently removes weekly check-ins and project updates older than the configured retention period.

## Acceptance criteria
- [ ] Reads `retentionDays` from `ProjectSettings` table (default 90 days)
- [ ] Computes cutoff timestamp: `now - (retentionDays * 24 * 60 * 60 * 1000)`
- [ ] Deletes `WeeklyCheckIn` records submitted prior to cutoff date
- [ ] Deletes `ProjectUpdate` records (and cascaded comments) created prior to cutoff date
- [ ] Does NOT delete user accounts, active tasks, or project settings
- [ ] If `retentionDays` is set to 0 or null, skips pruning
- [ ] Integrated into `server/src/services/cron.ts` to execute periodically (e.g. daily or every 10 minutes)
- [ ] Logs count of pruned records to console

## Out of scope
- Admin settings UI slider for retention days, moved to #31

## Constraints
- Stay inside `server/src/services/cron.ts`
- Follow Data Retention in `_docs/plan.md` Section 13

---

# 17. Project Admin Settings Management API
[GitHub Issue #17](https://github.com/fsamura01/project-feedback/issues/17)

## Goal
Build endpoints allowing the Project Admin to read and update workspace settings, including deadline, retention period, and notification toggles.

## Acceptance criteria
- [ ] `GET /api/admin/settings` returns HTTP 200 with current project settings (accessible to all authenticated team members for UI context)
- [ ] `PUT /api/admin/settings` is protected by `requireAdmin` and returns HTTP 403 for regular `TEAM_MEMBER`
- [ ] `PUT /api/admin/settings` validates `weeklyDeadlineDay` is an integer between 0 and 6
- [ ] `PUT /api/admin/settings` validates `weeklyDeadlineTime` matches `HH:mm` format (e.g. "17:00")
- [ ] `PUT /api/admin/settings` validates `retentionDays` is a positive integer
- [ ] `PUT /api/admin/settings` updates boolean flags: `notifyWeeklyReminder`, `notifyBlockers`, `notifyMentions`
- [ ] Emits `settings:updated` to workspace room over Socket.io upon saving

## Out of scope
- Frontend settings screen, moved to #31

## Constraints
- Stay inside `server/src/controllers/adminController.ts` and `server/src/routes/`
- Follow Admin Control in `_docs/plan.md` Sections 2 and 16

---

# 18. AI Weekly Summary Aggregation and Prompt Generation Service
[GitHub Issue #18](https://github.com/fsamura01/project-feedback/issues/18)

## Goal
Create an AI summary aggregation service that compiles the active week's check-ins, tasks, blockers, and updates into a structured prompt and generates an executive summary using Google Gemini.

## Acceptance criteria
- [ ] Gathers all weekly check-ins for the active week and year
- [ ] Gathers active and recently resolved blockers
- [ ] Gathers task progress (completed, in progress, todo)
- [ ] Gathers team member statuses and recent anytime updates
- [ ] Constructs system prompt enforcing the 7 required sections from plan.md Section 8: Overall Progress, Key Accomplishments, Current Work, Blockers/Risks, What Is Working, What Is Not Working, Recommendations
- [ ] Calls Google Gemini API (`@google/genai`) when `GEMINI_API_KEY` is configured
- [ ] Includes an algorithmic synthesis fallback if `GEMINI_API_KEY` is absent or API call fails, returning a fully formatted Markdown report
- [ ] Unit test verifies the prompt compilation and fallback generator output structure

## Out of scope
- Trigger endpoint for admin, moved to #19
- Frontend summary viewer, moved to #30

## Constraints
- Stay inside `server/src/services/aiSummary.ts`
- Use `@google/genai` library
- Follow AI Weekly Summary in `_docs/plan.md` Section 8

---

# 19. AI Weekly Summary Trigger and History API
[GitHub Issue #19](https://github.com/fsamura01/project-feedback/issues/19)

## Goal
Expose REST endpoints for the Project Admin to manually trigger AI weekly summary generation and for team members to read current and past summaries.

## Acceptance criteria
- [ ] `POST /api/summary/generate` is guarded by `requireAdmin`; rejects team members with HTTP 403 Forbidden
- [ ] `POST /api/summary/generate` triggers aggregation service for current (or requested) week and stores result in `AiWeeklySummary` table
- [ ] If a summary already exists for that week, updates the existing summary record with newly generated content
- [ ] Emits `summary:generated` event to the workspace room over Socket.io
- [ ] `GET /api/summary/current` returns HTTP 200 with the latest generated summary (accessible to everyone)
- [ ] `GET /api/summary/history` returns list of all generated summaries by week number and year
- [ ] Returns HTTP 404 with descriptive message if no summary has been generated yet for requested week

## Out of scope
- Automatic end-of-week generation (explicitly manual per plan.md Section 8)
- Frontend summary reader view, moved to #30

## Constraints
- Stay inside `server/src/controllers/summaryController.ts` and `server/src/routes/`
- Follow Manual Generation decision in `_docs/plan.md` Section 17

---

# 20. Frontend Design System and App Shell Layout
[GitHub Issue #20](https://github.com/fsamura01/project-feedback/issues/20)

## Goal
Build the responsive client application shell, modern design token system, top navigation bar, and routing framework.

## Acceptance criteria
- [ ] Implements CSS custom properties in `client/src/styles/` defining color tokens, fonts, spacing, glassmorphism, and status colors
- [ ] Configures Google Fonts (`Outfit` and `Inter`) in `client/index.html`
- [ ] Top navbar displays project branding ("SyncPulse"), current week number, active user pill, and notification bell
- [ ] Navigation menu provides links to: Dashboard, Check-In, Updates, Blockers, Tasks, Team, AI Summary, and Settings
- [ ] Settings navigation item visually indicates Admin-only access (or is hidden for non-admins)
- [ ] Layout is responsive on desktop and mobile viewports
- [ ] Client builds with `npm --prefix client run build` with 0 TypeScript and bundling errors

## Out of scope
- Specific page contents, moved to #23 through #31
- Notification drawer popover, moved to #22

## Constraints
- Stay inside `client/src/styles/`, `client/src/components/`, and `client/src/App.tsx`
- Use Vanilla CSS design tokens; do NOT install Tailwind
- Follow guidelines in `_docs/design-system.md`

---

# 21. Frontend Authentication and Demo Persona Switcher
[GitHub Issue #21](https://github.com/fsamura01/project-feedback/issues/21)

## Goal
Implement client-side authentication provider, login screen, and one-click demo persona switcher.

## Acceptance criteria
- [ ] `AuthContext` stores current user state, token in `localStorage`, and provides `login`, `logout`, and `switchUser` methods
- [ ] Automatically attaches `Authorization: Bearer <token>` to all outbound API requests
- [ ] Unauthenticated users are redirected to `/login` when attempting to access protected routes
- [ ] Login screen provides email and password inputs with validation and error banner on failure
- [ ] Login screen features one-click "Demo Personas" buttons for instant login as Admin (Alex) or Team Members (Maya, Jordan, Carlos)
- [ ] Displays active persona badge in navigation with a "Sign Out" action

## Out of scope
- Registration or password reset screens (not in MVP scope)
- Backend auth endpoints (completed in #4)

## Constraints
- Stay inside `client/src/context/AuthContext.tsx` and `client/src/pages/LoginPage.tsx`
- Use React Router v6
- Follow Login / Project Access spec in `_docs/architecture.md` Section 4

---

# 22. Frontend In-App Notification Bell and Real-Time Toast System
[GitHub Issue #22](https://github.com/fsamura01/project-feedback/issues/22)

## Goal
Build the real-time notification listener, navigation bell badge, notification dropdown drawer, and floating toast alert system.

## Acceptance criteria
- [ ] Connects to Socket.io server upon user authentication using stored JWT token
- [ ] `NotificationContext` listens for `notification:new` events in real time
- [ ] Navigation bell displays unread count badge; badge clears or decrements when items are read
- [ ] Clicking bell opens a dropdown showing recent notifications with timestamps and type icons (blocker, mention, reminder)
- [ ] Clicking a notification marks it as read and navigates to the relevant deep link (`/blockers`, `/updates`, etc.)
- [ ] Provides a "Mark all as read" button
- [ ] Displays a floating toast notification for 5 seconds when high-priority alerts (e.g. new blocker, @mention) arrive

## Out of scope
- Browser native push notifications or email notifications (in-app only per plan.md Section 5)

## Constraints
- Stay inside `client/src/context/NotificationContext.tsx` and `client/src/components/NotificationBell.tsx`
- Use `socket.io-client` and `lucide-react` icons
- Follow Real-Time Architecture in `_docs/architecture.md` Section 5

---

# 23. Frontend Project Dashboard View
[GitHub Issue #23](https://github.com/fsamura01/project-feedback/issues/23)

## Goal
Build the central Project Dashboard screen displaying the project completion gauge, team participation, active blockers alert, and weekly highlights.

## Acceptance criteria
- [ ] Displays dynamic project completion percentage gauge calculated from API stats
- [ ] Displays weekly check-in participation rate (e.g. "3 of 4 submitted - 75%")
- [ ] Displays prominent red alert banner if any active blockers exist, linking directly to `/blockers`
- [ ] Displays team status breakdown bar showing count of members in `On Track`, `At Risk`, `Blocked`, and `Completed`
- [ ] Displays categorized cards for Accomplishments, Current Work, What's Working, and Risks
- [ ] Includes quick-action bar allowing the logged-in user to change their current project status directly from the dashboard
- [ ] Shows clear empty state cards when no weekly data is yet submitted

## Out of scope
- Task creation modal, moved to #27
- Full check-in submission form, moved to #24

## Constraints
- Stay inside `client/src/pages/DashboardPage.tsx` and sub-components
- Follow Dashboard specs in `_docs/plan.md` Section 7 and `_docs/architecture.md` Section 4

---

# 24. Frontend Weekly Check-In Screen
[GitHub Issue #24](https://github.com/fsamura01/project-feedback/issues/24)

## Goal
Build the structured weekly check-in screen featuring the 5 mandatory questions, countdown to weekly deadline, and read-only locked presentation.

## Acceptance criteria
- [ ] Presents inputs for the 5 required questions: 1. Accomplishments, 2. Working on, 3. Blockers, 4. Working, 5. Not Working, plus optional Comments
- [ ] Pre-fills existing check-in data if user already submitted for current week
- [ ] Displays live countdown banner showing time remaining until configured weekly deadline
- [ ] If deadline has passed or check-in is locked, disables inputs and displays a prominent "Read-Only / Deadline Passed" badge
- [ ] Validates that all 5 required fields contain text before allowing submission
- [ ] Shows success confirmation toast upon saving
- [ ] Displays tabs or dropdown to review historical check-ins from previous weeks

## Out of scope
- Modifying other members' check-ins (each user manages their own)
- Hard deletion of submitted check-in (not permitted per plan.md Section 3)

## Constraints
- Stay inside `client/src/pages/CheckInPage.tsx`
- Follow Weekly Check-In specification in `_docs/plan.md` Section 3

---

# 25. Frontend Anytime Updates Feed with Threaded Comments
[GitHub Issue #25](https://github.com/fsamura01/project-feedback/issues/25)

## Goal
Build the anytime updates feed with composer, threaded comment drawer, @mention tagging autocomplete, and real-time live updates.

## Acceptance criteria
- [ ] Displays chronological feed of team updates with author avatars, names, role tags, and timestamps
- [ ] Top composer textarea enables posting an update at any time with a "Post Update" button
- [ ] Composer does not allow deleting updates once posted (no delete button rendered per plan.md Section 4)
- [ ] Typing `@` in composer or comment input triggers an autocomplete popup listing team members
- [ ] Each update card features an expandable comment section with nested reply support
- [ ] Submitting a comment updates the thread immediately without full-page reload
- [ ] Real-time Socket.io listener automatically inserts new updates and comments into the feed as they arrive

## Out of scope
- Direct messaging or private chat (all updates transparent per plan.md Section 14)

## Constraints
- Stay inside `client/src/pages/UpdatesPage.tsx` and related feed components
- Follow Anytime Updates in `_docs/plan.md` Section 4

---

# 26. Frontend Blockers Board with Resolution Actions
[GitHub Issue #26](https://github.com/fsamura01/project-feedback/issues/26)

## Goal
Build the blockers board with tabs for Active Blockers and Resolved History, creator resolve button, and admin reopen button.

## Acceptance criteria
- [ ] Displays two tabs: "Active Blockers" (highlighted with urgent crimson badges) and "Resolved History"
- [ ] "+ Report Blocker" button opens modal with title and description inputs accessible to any team member
- [ ] Each active blocker displays title, description, reporter avatar/name, creation timestamp, and status pill
- [ ] "Resolve Blocker" button is visible and active ONLY for the user who created the blocker (or Project Admin)
- [ ] "Reopen Blocker" button on resolved blockers is visible and active ONLY for users with `role === 'PROJECT_ADMIN'`
- [ ] Action buttons trigger API calls and update blocker status with instant feedback
- [ ] Shows "No active blockers" congratulatory empty state illustration when 0 blockers are open

## Out of scope
- Automatic status update to BLOCKED on team member (status remains manual per plan.md Section 6)

## Constraints
- Stay inside `client/src/pages/BlockersPage.tsx`
- Follow Blocker specifications in `_docs/plan.md` Section 5

---

# 27. Frontend Tasks Board (Kanban & List Views)
[GitHub Issue #27](https://github.com/fsamura01/project-feedback/issues/27)

## Goal
Build the interactive tasks interface with toggle between Kanban columns and tabular list view, priority indicators, and filtering.

## Acceptance criteria
- [ ] Toggle switch allows switching between Kanban Board view (To Do, In Progress, Completed) and Table List view
- [ ] Task cards render priority badges (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL` with distinct theme colors)
- [ ] Task cards render due date, assignee avatar, subtask progress indicator (e.g. "2/3"), and dependency badge
- [ ] Filter controls allow filtering tasks by assignee, priority, and completion status
- [ ] "+ New Task" button opens task creation modal requiring title, assignee, priority, and due date
- [ ] Clicking a task card opens the comprehensive Task Detail modal (#28)

## Out of scope
- Drag-and-drop file attachment uploads, moved to #28
- Complex Gantt chart rendering

## Constraints
- Stay inside `client/src/pages/TasksPage.tsx` and `client/src/components/tasks/`
- Follow Task Management in `_docs/plan.md` Section 9

---

# 28. Frontend Task Detail Modal with Dependencies and Attachments
[GitHub Issue #28](https://github.com/fsamura01/project-feedback/issues/28)

## Goal
Build the task detail modal allowing users to edit task attributes, check off subtasks, link prerequisite dependencies, and upload attachments.

## Acceptance criteria
- [ ] Modal displays full task information with editable title, description, assignee, priority, status, and due date
- [ ] Subtasks section allows adding subtasks and checking them off as completed
- [ ] Dependencies section lists prerequisite tasks and allows adding new dependencies from a task selector
- [ ] If user selects a dependency that creates a cycle, displays the backend error message in an alert banner
- [ ] Attachments section provides drag-and-drop zone and file input for documents/screenshots (up to 15 MB)
- [ ] Uploaded attachments are listed with filename, size, and download/preview links
- [ ] Changes save and broadcast update events to connected team members

## Out of scope
- Bulk task import/export

## Constraints
- Stay inside `client/src/components/tasks/TaskDetailModal.tsx`
- Follow Task Dependencies & Attachments in `_docs/plan.md` Sections 9, 10, and 12

---

# 29. Frontend Team Members Directory Screen
[GitHub Issue #29](https://github.com/fsamura01/project-feedback/issues/29)

## Goal
Build the team members directory screen showing each member's role, status pill, status explanation, and personal status updater.

## Acceptance criteria
- [ ] Displays grid of team member cards with avatar, name, email, and role badge (`Project Admin` or `Team Member`)
- [ ] Displays current status badge on each card: `On Track` (green), `At Risk` (amber), `Blocked` (red), `Completed` (blue)
- [ ] Displays latest status explanation text below the status badge
- [ ] Includes "Update My Status" button opening a modal with status selector radio cards and optional explanation textarea
- [ ] Saving updates user status immediately and updates the card across all open clients via Socket.io
- [ ] Users cannot update other members' statuses (only their own)

## Out of scope
- Adding/removing members from the team, moved to Admin Settings #31

## Constraints
- Stay inside `client/src/pages/TeamPage.tsx`
- Follow Team Member Project Status in `_docs/plan.md` Section 6

---

# 30. Frontend AI Weekly Summary Screen
[GitHub Issue #30](https://github.com/fsamura01/project-feedback/issues/30)

## Goal
Build the AI weekly summary screen featuring the Admin generation button with loading state, Markdown report reader, and historical week selector.

## Acceptance criteria
- [ ] Renders formatted Markdown summary with styled headings matching the 7 mandatory sections
- [ ] For users with `role === 'PROJECT_ADMIN'`, displays a prominent "Generate AI Weekly Summary" button
- [ ] Clicking "Generate" triggers API and displays an animated loading skeleton or spinner during generation
- [ ] For non-admin members, hides the generate button and shows summary as read-only
- [ ] Week selector dropdown allows browsing and viewing summaries from previous weeks
- [ ] Provides a "Copy to Clipboard" button with confirmation feedback
- [ ] Displays friendly empty state when no summary has yet been generated for the selected week

## Out of scope
- Automatic scheduled summary generation (strictly manual trigger per plan.md Section 8)

## Constraints
- Stay inside `client/src/pages/AiSummaryPage.tsx`
- Follow AI Weekly Summary in `_docs/plan.md` Section 8

---

# 31. Frontend Project Admin Settings Screen
[GitHub Issue #31](https://github.com/fsamura01/project-feedback/issues/31)

## Goal
Build the administrative configuration screen for weekly deadlines, data retention duration, and notification toggles.

## Acceptance criteria
- [ ] Accessible strictly to users with `role === 'PROJECT_ADMIN'`; non-admins navigating to `/settings` are redirected or shown a 403 Access Denied view
- [ ] Form controls to configure weekly deadline day of the week (dropdown Monday–Sunday) and time (`HH:mm` time picker)
- [ ] Number input or slider for data retention period (in days, e.g. 30, 60, 90, 180)
- [ ] Independent toggle switches for: 1. Weekly check-in reminders, 2. Blocker notifications, 3. @Mention notifications
- [ ] "Save Settings" button validates form, submits to `PUT /api/admin/settings`, and shows success toast
- [ ] Loaded values reflect current database settings on page open

## Out of scope
- Deleting the workspace or multi-workspace management (single-project MVP per plan.md Section 2)

## Constraints
- Stay inside `client/src/pages/SettingsPage.tsx`
- Follow Admin Control in `_docs/plan.md` Sections 2 and 16

---

# 32. End-to-End Integration and Verification Suite
[GitHub Issue #32](https://github.com/fsamura01/project-feedback/issues/32)

## Goal
Conduct comprehensive end-to-end verification of all core user flows, permissions, deadline locking, and real-time events.

## Acceptance criteria
- [ ] Automated integration test or scripted verification covers:
  - Admin login and settings configuration
  - Member check-in submission and rejection after deadline
  - Anytime update posting and @mention notification delivery
  - Blocker reporting, creator-only resolution, and admin-only reopening
  - Task creation with multiple dependencies and rejection of circular dependencies
  - Dynamic completion percentage calculation
  - AI weekly summary generation and team-wide readability
- [ ] Both test commands (`npm test` across server and client) pass with 0 failures
- [ ] Build command (`npm run build`) succeeds with 0 TypeScript or packaging errors
- [ ] Full end-to-end verification walkthrough documented in `walkthrough.md`

## Out of scope
- Production cloud deployment (local development verification for MVP)

## Constraints
- Stay within root testing tools
- Follow quality gates in `_docs/process.md` Section 2
