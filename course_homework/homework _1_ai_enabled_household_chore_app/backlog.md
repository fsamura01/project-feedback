# Backlog for AI‑Enabled Household Chore App

## Task 1: Initialise Django project & create app
- Run `uv run django-admin startproject chore_app .`
- Run `uv run python manage.py startapp chores`
- Add `chores` to `INSTALLED_APPS` in `chore_app/settings.py`

## Task 2: Define data models
- Implement `Household`, `Member`, `Chore`, `User` models per the spec in `_docs/plan.md`.
- Add soft‑delete (`deleted_at`) and recurrence fields.
- Create initial migrations.

## Task 3: Create basic CRUD views & templates
- List chores, create/edit chore, member list, settings page.
- Use Django generic class‑based views.

## Task 4: Implement AI endpoint (optional for now)
- Add a DRF view at `/api/ai/suggest‑chore` that calls OpenAI.
- Stub implementation returning a static suggestion.

## Task 5: Write unit tests
- Test model methods (e.g., recurrence handling, soft delete).
- Test view responses and form validation.
- Run tests with `uv run python manage.py test`.

## Task 6: Run development server
- Start server with `uv run python manage.py runserver`.
