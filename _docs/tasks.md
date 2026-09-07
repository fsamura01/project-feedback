# Project Backlog — SyncPulse MVP

This backlog defines self-contained tasks for implementing the Weekly Feedback & Project Collaboration Tool specified in [_docs/plan.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/plan.md) and [_docs/architecture.md](file:///d:/Learning/ai-dev-tools-experiment/project-feedback/_docs/architecture.md).

---

## 1. Empty Project Setup with a Passing Test
Goal: Initialize the repository workspace with client and server scaffolding and a working automated test.
Description: Set up the root monorepo structure with `server` (Node.js/Express, TypeScript) and `client` (React/Vite, TypeScript) packages and install core build tooling. Configure a testing framework such as Vitest or Jest with a basic sanity test that asserts true in the test runner. Ensure that running `npm test` from the root executes cleanly and exits with a success code.

## 2. Prisma Database Schema and Migrations
Goal: Define the complete relational database schema for the single-project workspace using Prisma ORM.
Description: Create the Prisma schema file specifying models for `User`, `WeeklyCheckIn`, `ProjectUpdate`, `Comment`, `Blocker`, `Task`, `TaskDependency`, `TaskAttachment`, `Notification`, `AiWeeklySummary`, and `ProjectSettings`. Configure SQLite as the primary database provider with foreign key cascades and appropriate unique constraints. Run the initial migration or schema push command to generate the local database file and TypeScript client.

## 3. Database Seeding Script with Demo Personas
Goal: Create an automated database seed script populated with realistic project data and test users.
Description: Implement a seed script that resets existing data and populates a Project Admin (`alex@team.com`), multiple Team Members with distinct statuses (`On Track`, `At Risk`, `Blocked`), and default project settings. Include sample weekly check-ins, anytime updates with comments, an active blocker, and tasks with subtasks and prerequisites. Add a script command in `package.json` to allow developers to reseed the database in one step.

## 4. User Authentication and JWT Role Guard API
Goal: Implement authentication endpoints and role-based middleware for Project Admins and Team Members.
Description: Build a login endpoint that verifies user email and bcrypt-hashed password, returning a signed JSON Web Token (JWT) along with profile information. Create an `authenticate` middleware that extracts and validates the Bearer token, attaching the authenticated user to the request context. Add a `requireAdmin` route guard that checks if the requesting user holds the `PROJECT_ADMIN` role, rejecting unauthorized requests with an HTTP 403 status.

## 5. Team Member Status Update API
Goal: Implement endpoints allowing team members to view all members and manually update their own project status.
Description: Build a `GET /api/users` endpoint returning all team members, their assigned roles, current statuses (`ON_TRACK`, `AT_RISK`, `BLOCKED`, `COMPLETED`), and status explanations. Implement a `PATCH /api/users/me/status` endpoint enabling authenticated members to update only their own status and optional explanation text. Ensure validation restricts values to the four approved statuses and emits a workspace update event upon completion.

## 6. Real-Time Socket.io Server and Room Infrastructure
Goal: Establish a bi-directional Socket.io server with authentication and room management.
Description: Initialize Socket.io on top of the Express HTTP server and configure CORS for the client application. Implement connection middleware to verify user JWTs and automatically place users into a shared `workspace` room and a private `user:<id>` room. Create server-side helper functions for emitting workspace-wide events and targeting direct notifications to individual user rooms.

## 7. Weekly Check-In Submission and Editing API
Goal: Build endpoints for submitting and editing weekly check-ins with deadline enforcement.
Description: Create an endpoint for team members to submit responses to the five mandatory check-in questions along with an optional comments field. Implement logic that checks whether the current timestamp is past the configured weekly deadline, rejecting submissions or edits with HTTP 403 once locked. Ensure that submitted check-ins cannot be deleted via the API and provide a retrieval endpoint for current and past weekly submissions.

## 8. Automated Weekly Deadline Locking and Reminder Cron Job
Goal: Implement background scheduling to lock check-ins when deadlines pass and dispatch reminders.
Description: Configure a `node-cron` scheduled job that runs periodically to inspect the current time against the project's configured deadline day and time. Automatically mark all check-ins for the active week as locked (`isLocked: true`) once the deadline timestamp has passed. Dispatch in-app notification records and socket events to any team members who have not yet submitted a check-in within 24 hours of the deadline.

## 9. Anytime Updates Feed and Threaded Comments API
Goal: Create endpoints for posting chronological project updates and threaded replies.
Description: Implement a `POST /api/updates` endpoint allowing team members to publish project updates at any time, enforcing that updates cannot be deleted once created. Build a `POST /api/updates/:id/comments` endpoint supporting threaded comments and replies with optional `parentId` references. Return updates in reverse chronological order with populated user avatars, roles, and nested comment chains.

## 10. In-App @Mention Parsing and Notification Pipeline
Goal: Detect @mentions within updates and comments and deliver in-app notifications.
Description: Write a text-parsing utility that scans update and comment text for `@username` patterns and matches them against active team members. When a match is detected, create a `Notification` database record with type `MENTION` and an actionable deep link to the relevant update. Dispatch a real-time `notification:new` event over Socket.io to the mentioned user's private room if mention notifications are enabled in project settings.

## 11. Blocker Reporting, Resolution, and Admin Reopening API
Goal: Build endpoints for managing blockers with creator resolution and admin-only reopening rules.
Description: Implement a `POST /api/blockers` endpoint that records new blockers and automatically broadcasts in-app notifications to the team. Create a `PATCH /api/blockers/:id/resolve` endpoint restricted to the blocker's creator (or admin) that records resolution timestamp and changes status to `RESOLVED`. Build a `PATCH /api/blockers/:id/reopen` endpoint strictly guarded by `requireAdmin` that allows the Project Admin to reopen a resolved blocker with an audit timestamp.

## 12. Task and Subtask CRUD API
Goal: Build endpoints to create, read, update, and delete tasks and hierarchical subtasks.
Description: Implement task management endpoints supporting mandatory title, due date, priority (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`), status (`TODO`, `IN_PROGRESS`, `COMPLETED`), and assignee. Allow tasks to reference an optional `parentId` to function as subtasks with identical field support. Return tasks with associated assignees, subtasks, and dependency metadata for easy consumption by dashboard and board views.

## 13. Task Dependency Graph Engine and Cycle Detection
Goal: Implement multi-dependency task linking with cycle-prevention validation.
Description: Create endpoints to assign multiple prerequisite dependencies to a task via the `TaskDependency` junction model. Implement a graph traversal algorithm (such as Depth-First Search) that verifies whether adding a proposed dependency would introduce a circular deadlock (e.g., A depends on B, B depends on A). Return an explicit validation error if a cycle is detected, rejecting the operation before database persistence.

## 14. Task File Attachment Upload and Serving API
Goal: Build file upload endpoints for attaching screenshots and documents to tasks.
Description: Configure `multer` middleware to accept image and document attachments on a `POST /api/tasks/:id/attachments` endpoint with a 15 MB file size limit. Store uploaded files in a dedicated `/uploads` directory on disk with unique filenames, saving the original name, MIME type, and size to `TaskAttachment`. Serve the uploaded assets statically through an Express route and broadcast an attachment event to connected clients.

## 15. Dynamic Project Completion Percentage Calculation Service
Goal: Implement an automated calculation engine that computes overall project completion percentage.
Description: Create a service function that calculates the project's overall progress by combining task completion ratios with individual team member project statuses. Weight completed tasks against total active tasks while incorporating member status factors (e.g., penalizing blocked statuses and crediting completed statuses). Expose the resulting percentage and breakdown metrics through a `GET /api/dashboard/stats` endpoint.

## 16. Data Retention Policy Cleanup Background Job
Goal: Implement automated background data pruning for historical check-ins and updates.
Description: Create a scheduled `node-cron` task that reads the configurable `retentionDays` setting from the database. Identify and delete all weekly check-ins and project updates whose creation timestamps are older than the retention horizon. Ensure the deletion process logs pruned record counts and runs safely without interrupting active database transactions.

## 17. Project Admin Settings Management API
Goal: Build endpoints for configuring deadlines, data retention, and notification toggles.
Description: Implement a `GET /api/admin/settings` endpoint to retrieve project settings and a `PUT /api/admin/settings` endpoint protected by `requireAdmin`. Allow the Project Admin to update the weekly deadline day, deadline time, retention period in days, and independently toggle blocker, mention, and reminder notifications. Emit a `settings:updated` event to the workspace room when configuration changes are saved.

## 18. AI Weekly Summary Aggregation and Prompt Generation Service
Goal: Build a server service that gathers the week's data and structures it into an AI prompt.
Description: Create an aggregation function that collects the current week's check-ins, active and resolved blockers, task progress, and member statuses. Format this data into a structured system prompt requesting the seven mandated summary sections: Progress, Accomplishments, Current Work, Blockers/Risks, What's Working, What's Not Working, and Recommendations. Implement the call using the Google Gemini API (`@google/genai`), including an algorithmic synthesis fallback if no API key is set.

## 19. AI Weekly Summary Trigger and History API
Goal: Expose endpoints for the Project Admin to trigger summary generation and for the team to view it.
Description: Create a `POST /api/summary/generate` endpoint restricted to `PROJECT_ADMIN` that invokes the AI summary service and stores the Markdown result in `AiWeeklySummary`. Build a `GET /api/summary/current` and `GET /api/summary/history` endpoint accessible to all team members to view current and historical generated summaries. Broadcast a `summary:generated` event to the workspace room upon successful generation.

## 20. Frontend Design System and App Shell Layout
Goal: Build the responsive client layout shell with custom CSS design tokens and theme variables.
Description: Create the core CSS design system with CSS custom properties for typography, sleek dark/light color palettes, glassmorphism cards, and badge accents. Implement the top navigation bar with the project title, current week indicator, persona switcher, and interactive notification bell. Add responsive navigation links to switch between Dashboard, Check-In, Updates, Blockers, Tasks, Team, Summaries, and Settings.

## 21. Frontend Authentication and Demo Persona Switcher
Goal: Implement the client-side authentication provider, login view, and one-click persona switcher.
Description: Build an `AuthContext` to manage the active user session, JWT storage in local storage, and Axios/Fetch authorization headers. Create a polished Login screen with form validation, error banners, and quick-action buttons to instantly log in as the Project Admin or any of the demo Team Members. Ensure unauthenticated users are redirected to the login view when accessing protected views.

## 22. Frontend In-App Notification Bell and Real-Time Toast System
Goal: Build the real-time notification drawer and floating toast alerts on the client.
Description: Connect the client to Socket.io and establish a `NotificationContext` that listens for `notification:new` events. Display an animated unread badge on the navigation bell and render an interactive dropdown list of recent notifications with "Mark as Read" actions. Trigger brief floating toast notifications whenever high-priority events (such as new blockers or direct mentions) arrive in real time.

## 23. Frontend Project Dashboard View
Goal: Build the main project dashboard screen displaying overall status and progress metrics.
Description: Implement the Dashboard view featuring a circular or linear project completion percentage gauge, team participation statistics, and active blocker alerts. Display categorized cards summarizing current accomplishments, ongoing work, and what is/isn't working extracted from the week's activity. Include an interactive status strip allowing the logged-in user to quickly toggle their own project status directly from the dashboard.

## 24. Frontend Weekly Check-In Screen
Goal: Build the structured weekly check-in form with countdown timer and read-only locked state.
Description: Create the check-in page presenting the five required question fields and the optional comments textarea with auto-saving draft support. Display an active countdown timer indicating hours and minutes remaining until the weekly deadline. When the deadline passes or the record is locked, switch the interface to a read-only presentation displaying a lock badge and submission timestamp.

## 25. Frontend Anytime Updates Feed with Threaded Comments
Goal: Build the continuous project updates feed with threaded replies and @mention autocomplete.
Description: Implement the chronological updates feed featuring a post composer, author avatars, role badges, and relative timestamps. Add an expandable comment section under each update supporting threaded replies and nested comment trees. Integrate `@mention` text suggestions that appear when typing `@` to allow easy tagging of teammates.

## 26. Frontend Blockers Board with Resolution Actions
Goal: Build the blockers management screen with active blocker lists and resolution workflows.
Description: Create a view with tabs for "Active Blockers" and "Resolved History", highlighting critical blockers with distinct visual styling. Include a "Report Blocker" modal with title and description inputs accessible to all team members. Provide an inline "Resolve Blocker" button visible only to the blocker's creator and a "Reopen Blocker" button visible strictly to the Project Admin.

## 27. Frontend Tasks Board (Kanban & List Views)
Goal: Build the interactive tasks interface with status columns, filters, and subtask indicators.
Description: Implement a tasks screen with a toggle between a Kanban board (To Do, In Progress, Completed columns) and a sortable table list view. Render task cards showing priority flags (Low, Medium, High, Critical), assignees, due dates, dependency count badges, and subtask completion bars. Provide filtering by assignee, priority, and status, along with a prominent "+ New Task" action modal.

## 28. Frontend Task Detail Modal with Dependencies and Attachments
Goal: Build a comprehensive task detail modal for managing subtasks, dependencies, and file attachments.
Description: Create a detailed modal allowing users to edit task descriptions, assignees, due dates, and priorities. Include a subtask checklist where subtasks can be added and checked off, a dependency picker showing prerequisites and dependent tasks, and an attachment dropzone. Implement drag-and-drop file uploading for screenshots and documents, rendering previews and downloadable links.

## 29. Frontend Team Members Directory Screen
Goal: Build a team directory view showing each member's role, status badge, and explanation note.
Description: Implement a responsive grid of team member cards displaying avatars, full names, emails, and role badges (`Project Admin` vs `Team Member`). Display each member's current status pill (`On Track`, `At Risk`, `Blocked`, `Completed`) accompanied by their latest status explanation. Provide an "Update My Status" modal allowing the current user to update their status and note with instant optimistic UI updates.

## 30. Frontend AI Weekly Summary Screen
Goal: Build the AI weekly summary view with Admin generation trigger and formatted report reader.
Description: Create a screen displaying the latest AI-generated weekly summary rendered in formatted Markdown with clear section headers. For Project Admins, provide a prominent "Generate Weekly Summary" action button with a loading skeleton during generation. For all team members, provide a week-selector dropdown to browse historical summaries, along with a "Copy to Clipboard" utility.

## 31. Frontend Project Admin Settings Screen
Goal: Build the administrative configuration screen for deadlines, retention, and notifications.
Description: Implement a dedicated settings screen accessible only to users with the `PROJECT_ADMIN` role (redirecting or blocking non-admins). Provide form controls to select the weekly deadline day of the week and cutoff time, a slider/input for the data retention period in days, and toggle switches for blocker, mention, and reminder notifications. Include a "Save Configuration" button that validates inputs, calls the update API, and displays a success confirmation toast.

## 32. End-to-End Integration and Verification Suite
Goal: Conduct end-to-end verification of the collaboration workflow across roles and real-time events.
Description: Write an integration test suite or scripted browser verification verifying key user flows: logging in as Admin to configure deadline, logging in as Member to submit a check-in and post an update with `@mention`, and reporting a blocker. Verify that real-time Socket.io notifications appear for recipient users, task dependencies reject circular loops, and deadline locking prevents late submissions. Validate that the AI summary generates successfully and is readable by all team members.
