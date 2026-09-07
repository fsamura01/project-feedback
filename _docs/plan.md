# Weekly Feedback & Project Collaboration Tool — MVP Scope

## 1. Product Overview

A single-project team collaboration and weekly feedback tool where every team member contributes updates, feedback, blockers, and project status.

The MVP is intentionally focused on:
- Weekly accountability
- Anytime project updates
- Blocker visibility and notification
- Team-wide transparency
- Task management
- Project status tracking
- AI-generated weekly summaries

## 2. Core Product Model

### Project Structure
- One project per workspace for the MVP.
- Every team member can see everyone else's feedback, updates, blockers, statuses, and project information.
- The Project Admin manages project-level configuration.

### Roles

#### Project Admin
Can:
- Add/remove team members
- Edit weekly check-in questions
- Set/change weekly deadline
- Configure notification settings
- Configure data-retention period
- Generate AI weekly summaries
- Reopen resolved blockers
- Manage project tasks

#### Team Member
Can:
- Submit weekly check-ins
- Create anytime updates
- Create and resolve their own blockers
- Comment/reply to other updates and blockers
- Use @mentions
- Manually update their own project status
- Create and manage tasks
- Assign tasks to other team members
- Manage subtasks

## 3. Weekly Check-In

Every team member must submit a required weekly check-in.

### Required Questions
1. What did I accomplish?
2. What am I currently working on?
3. What blockers/issues do I have?
4. What is working?
5. What is not working?

Each question has an optional comments field.

### Editing Rules
- Team members can edit their weekly check-in until the weekly deadline.
- Once the deadline passes, the check-in becomes read-only.
- Submitted check-ins cannot be deleted.
- Check-ins remain available according to the configured retention period.

### Weekly Deadline
- The deadline is configurable.
- Project Admin controls the deadline.
- The system reminds people who have not submitted.

## 4. Anytime Updates

Team members can post project updates at any time during the week.

Updates are visible to the entire team.

Other team members can:
- Comment
- Reply
- Use @mentions

Updates cannot be deleted by the team member after submission because the system maintains project history/auditability.

## 5. Blockers

Team members can report blockers as part of their feedback or project activity.

### Blocker Behavior
- Blockers are visible to the entire team.
- A blocker triggers an in-app notification.
- The person who created the blocker can mark it as resolved.
- Resolved blockers remain visible in project history.
- Project Admin can reopen a resolved blocker.

### Notification Decision
The MVP uses in-app notifications only.

Project Admin can independently enable/disable:
- Weekly reminders
- Blocker notifications
- @mention notifications

### Why In-App Only
This keeps the MVP self-contained and reduces infrastructure complexity around email delivery, providers, templates, bounce handling, and external notification configuration.

Email notifications can be considered for a future version.

## 6. Team Member Project Status

Each team member has a current project status visible to everyone.

### Profile Information
- Name
- Role
- Current project status
- Optional status explanation

### Status Options
- On Track
- At Risk
- Blocked
- Completed

Team members manually update their own status.

The system does not automatically change a member's status when they create a blocker.

## 7. Team Dashboard

The dashboard provides a shared view of the current state of the project.

### Dashboard Information
- Team participation
- Each person's current project status
- Project completion percentage
- Accomplishments
- Current work
- Blockers
- Risks
- What is working
- What is not working

### Project Completion Percentage
The completion percentage is calculated automatically using:
- Project tasks
- Team member project status

## 8. AI Weekly Summary

The system can generate an AI-powered weekly project summary.

### Generation
- Project Admin manually clicks a button to generate the summary.
- The AI uses the week's available project information.

### Summary Focus
The AI summary covers:
- Overall project progress
- Key accomplishments
- Current/ongoing work
- Blockers and risks
- What is working
- What is not working

### Visibility
The generated summary is visible to everyone on the team.

### Why Manual Generation
Manual generation gives the Project Admin control over when the weekly information is considered complete.

## 9. Task Management

The MVP includes full project task management.

### Task Fields
Every task supports:
- Title
- Description
- Assignee
- Priority
- Due date
- Status
- Attachments
- Dependencies
- Subtasks

### Priority Levels
- Low
- Medium
- High
- Critical

### Task Statuses
- To Do
- In Progress
- Completed

### Due Date
Every task must have a due date.

### Attachments
Tasks support attachments such as documents and screenshots.

## 10. Subtasks

Subtasks use the same feature model as regular tasks.

Each subtask supports:
- Assignee
- Priority
- Due date
- Status
- Attachments
- Dependencies

## 11. Task Assignment

Team members can:
- Create tasks
- Manage tasks
- Assign tasks to themselves
- Assign tasks to other team members

The Project Admin also has task-management capabilities.

## 12. Task Dependencies

A task can depend on multiple other tasks.

### Decision
Use multiple dependencies rather than restricting a task to one dependency.

### Why
Real project work frequently requires several prerequisites.

## 13. Data Retention

Historical weekly check-ins and project updates are retained only for a configurable period.

### Configuration
- Project Admin controls the retention period.

## 14. Visibility Model

The MVP uses a highly transparent team model.

Everyone on the team can see:
- Weekly check-ins
- Anytime updates
- Blockers
- Resolved blockers/history
- Comments/replies
- @mentions
- Team member statuses
- Project dashboard
- AI weekly summaries
- Project tasks

## 15. MVP Design Principles

### Team Transparency
Everyone should have a clear view of project progress and issues.

### Low Friction
Weekly reporting should be structured but quick to complete.

### Actionable Blockers
Blockers should immediately become visible through in-app notifications.

### Accountability
Weekly check-ins are required and become read-only after the deadline.

### Historical Context
Submitted updates and resolved blockers remain available according to the retention policy.

### Admin Control
Project Admin controls the major project-level settings.

### Controlled AI
AI summarizes project information but does not automatically change project data or status.

## 16. Explicit MVP Decisions

| Area | MVP Decision |
|---|---|
| Projects | One project per workspace |
| Team visibility | Everyone sees everything |
| Weekly updates | Required |
| Anytime updates | Supported |
| Weekly check-in editing | Until weekly deadline |
| Submitted check-in deletion | Not allowed |
| Blocker notification | In-app |
| Blocker resolution | Creator resolves |
| Blocker reopening | Project Admin |
| Resolved blocker history | Kept |
| Comments/replies | Supported |
| @mentions | Supported |
| AI summary | Supported |
| AI generation | Manual by Project Admin |
| AI summary visibility | Everyone |
| Team status | Manual |
| Status visibility | Everyone |
| Project completion | Automatically calculated |
| Task management | Full task management |
| Subtasks | Supported |
| Dependencies | Multiple |
| Priorities | Low / Medium / High / Critical |
| Due date | Required |
| Task statuses | To Do / In Progress / Completed |
| Attachments | Supported |
| Task assignment | Any team member |
| Retention | Configurable |
| Retention control | Project Admin |

## 17. Design Decisions Made By Recommendation

### In-App Notifications Only
Chosen instead of email + in-app for the MVP.

**Reason:** Lower implementation and operational complexity while still providing immediate visibility.

**Alternative considered:** Email + in-app.

### Manual AI Summary Generation
Chosen instead of automatic generation.

**Reason:** Gives the Project Admin control over when the weekly information is sufficiently complete.

**Alternative considered:** Automatic end-of-week generation.

### Multiple Task Dependencies
Chosen instead of a single dependency.

**Reason:** Better represents real project workflows with multiple prerequisites.

**Alternative considered:** One dependency per task, which is simpler but more restrictive.

### No Deletion of Submitted Check-Ins
Chosen to preserve project history and accountability.

**Alternative considered:** Allow users to delete their own submissions.

## 18. Recommended Next Phase

The MVP scope is sufficiently defined.

The next design step should be to define the application's actual screens and user flows before implementation.

Recommended screen set:
1. Login / Project Access
2. Project Dashboard
3. Weekly Check-In
4. Anytime Updates Feed
5. Blockers
6. Tasks
7. Task Detail
8. Team Members
9. AI Weekly Summary
10. Project Admin Settings

For each screen, define:
- Purpose
- Components
- Actions
- Permissions
- Data required
- Notifications triggered
- Empty states
- Error states

This should be completed before database and API implementation so the product stays tightly scoped.

## 19. Current Project Definition

**Working concept:**

A transparent, single-project team workspace that combines weekly accountability, continuous project updates, blocker management, task tracking, team status, and AI-generated weekly reporting.

The MVP should prioritize clarity, transparency, and ease of use rather than becoming a full project-management platform.
