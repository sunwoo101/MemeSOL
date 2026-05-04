# Contributing Guidelines

Guidelines for contributing to this project. Please follow these to keep our workflow clean and reviewable.

## Branches

- Create a new feature branch for each feature. Don't work on multiple features in a single branch.
- **Only create the branch when you're actually starting work on the feature**, so it's based on the latest `main`. Don't pre-create branches for features you haven't started yet.
- Use the format `SCOPE-feature-name`, where `SCOPE` is `BACKEND` or `FRONTEND`.
  - Examples: `BACKEND-create-account`, `FRONTEND-onboarding`, `BACKEND-login`, `FRONTEND-profile-page`

## Pull Requests

- Create a separate PR for each individual feature. Don't group multiple features into one PR.
- Keep PRs focused and reasonably small. If a branch is growing too big, split it up.
- Each PR requires **at least 2 reviews** before merging.
- Delete the feature branch after the feature is merged to `main`.

### PR Title Format

Use the format: `type: [scope] short description`

- **type** — one of: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`
- **scope** — `backend` or `frontend`

Examples:

- `feat: [backend] create account`
- `feat: [frontend] onboarding screen`
- `fix: [backend] login validation error`
- `chore: [frontend] update dependencies`
