# AI‑Enabled Household Chore App (Homework 1)

This repository contains the solution for **Homework 1: AI‑Native Developer Workflow**. The goal is to turn a vague idea—*a tool for managing shared household chores*—into a concrete Django application, using AI to help shape the specification and implement features.

## Repository layout
```
course_homework/
└─ homework _1_ai_enabled_household_chore_app/
   ├─ .gitignore          # Git ignore rules for Python/Django
   ├─ README.md           # You are reading this file
   ├─ backlog.md          # Planned tasks (generated)
   ├─ _docs/plan.md      # Original MVP specification (provided)
   └─ (Django project will be created here)
```

## How to get started
1. **Set up the environment** (recommended tool: `uv`)
   ```bash
   uv venv               # create a virtual environment
   source .venv/bin/activate   # on Windows: .venv\Scripts\activate
   uv pip install django djangorestframework openai
   ```
2. **Create the Django project & app** (see *Task 1* in `backlog.md`).
3. Follow the tasks in `backlog.md` to implement models, views, templates, optional AI endpoint, tests, and finally run the development server.

## Answers to the homework questionnaire
| # | Question | Answer |
|---|----------|--------|
| 1 | Coding agent chosen | **Claude Code** (a chat‑based coding assistant that can edit files and run commands directly) |
| 2 | 2‑4 features of the spec | 1. Create, edit, delete, and complete one‑time or recurring chores. 2. Assign chores to household members and track who completed them. 3. Soft‑delete chores and handle recurrence (next occurrence created on completion). 4. Simple member management (list members, invite via email) |
| 3 | File to edit to include the app | **`chore_app/settings.py`** – add the new app to `INSTALLED_APPS` |
| 4 | Task 1 in the backlog | **Initialise Django project & create the `chores` app** (run `django-admin startproject` and `python manage.py startapp chores`, then register the app) |
| 5 | Command to start the Django dev server | `uv run python manage.py runserver` |
| 6 | Command to run the test suite | `uv run python manage.py test` |

Feel free to let me know which step you’d like to tackle next!
