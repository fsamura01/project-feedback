# Household Chore App — MVP Definition

## 1. MVP Product Definition

A simple shared household chore application where household members can create, assign, edit, delete, and complete one-time or recurring chores. Each chore has a name, description, assignee, and due date/time. Completion records who completed the chore and when.

## 2. Core User Flow

- Creating a chore
- Completing a chore

```text
Sign up / Log in
       │
       ▼
Create or Join Household
       │
       ▼
     Chores
       │
 ┌─────┼──────────┐
 ▼     ▼          ▼
View  Complete   Manage
      chore      chores
```

## 3. MVP Data Model

Four primary entities: **Household**, **Member**, **Chore**, **User**.

- A user can belong to a household; the household is the shared boundary for chores.
- Authentication information is handled by the authentication system rather than a custom auth database.

```
household
├── id
├── name
├── created_by
└── created_at

member
├── id
├── user_id
├── household_id
└── joined_at

chore
├── id
├── household_id
├── name
├── description
├── assigned_to
├── due_at
├── recurrence
├── status
├── completed_by
├── completed_at
├── deleted_at
└── created_at

user
├── id
├── name
├── email
└── authentication_provider
```

## 4. Recurrence Model

- No sophisticated scheduling engine needed for MVP.
- Recurrence types:

```
recurrence_type
├── NONE
├── DAILY
├── WEEKLY
└── MONTHLY
```

- For weekly chores, also store the applicable day. Example:

```
Clean bathroom
recurrence = WEEKLY
day = SUNDAY
```

## 5. Main Screens

**Screen 1 — Chores** (most important screen)
- One list. No complicated dashboard.

```
┌─────────────────────────────┐
│ Smith Household       +     │
├─────────────────────────────┤
│                             │
│ Take out trash              │
│ Alex • Today 6:00 PM        │
│ Weekly              [✓]     │
│                             │
│ Clean bathroom              │
│ Maria • Tomorrow 10:00 AM   │
│ Weekly              [✓]     │
│                             │
│ Buy groceries               │
│ Alex • Sep 12 5:00 PM       │
│ One-time             [✓]    │
│                             │
└─────────────────────────────┘
```

**Screen 2 — Create/Edit Chore** (Delete available when editing)

```
Name
Description

Assigned to
[ Member ▼ ]

Due date
Due time

Repeat
[ None ▼ ]

        Save
```

**Screen 3 — Members**

```
Household Members

Alex
5 active chores

Maria
3 active chores

John
2 active chores

       + Invite Member
```

**Screen 4 — Settings** (essential only)
- Household name
- Account
- Leave household
- Sign out

## 6. Important MVP Rules

| Rule | Decision |
|---|---|
| Assignment | Every chore has exactly one assigned member. |
| Completion | Any household member can mark a chore complete — the assigned person may not always be able to finish it. |
| Editing | Every member can edit every chore. |
| Deletion | Soft delete. |
| Recurring chores | Completion creates the next occurrence. |
| Editing recurring chores | Changes apply to the current and future occurrences. |
| Deleting recurring chores | Stops future occurrences; current occurrence is removed from the active list; completion records remain internally; no recovery/restore UI in MVP. |
| Overdue chores | Remain visible in the list, clearly marked as overdue. Not auto-completed or moved. (Rejected alternative: auto-rolling the due date forward, since it hides missed chores and blurs accountability.) |
| Permissions | All household members have the same permissions. |

## 7. Completion Flow

```text
To Do
  │
  ▼
Complete
  │
  ├── status = completed
  ├── completed_by = member
  └── completed_at = timestamp
           │
           ▼
    If recurring
           │
           ▼
    Create next occurrence
```

## 8. What We Are NOT Building (Out of Scope for MVP)

- Points/rewards
- Gamification
- Leaderboards
- Chat
- Comments
- Photos
- Attachments
- Notifications
- Email reminders
- Push notifications
- Multiple household memberships
- Admin/member roles
- Advanced recurrence rules
- Calendar view
- Analytics
- Reporting
- Chore history UI
- Automatic chore reassignment
- Priority levels

These are all reasonable future features, but they would dilute the MVP.

## 9. Next Decision

Architecture and technology — comparing options such as React + Node.js, Next.js, serverless AWS, and Firebase/Supabase, chosen specifically for this MVP.
