# Repository instructions for Codex

## Repository purpose

This repository stores product deliverables for the OffshoreWind Platform. A deliverable is either a static HTML prototype or an independently runnable full-stack demo.

## Non-negotiable rules

- Store every business deliverable directly under `deliverables/<artifact-id>/`.
- Set exactly one `deliverable_type` in `artifact.yaml`: `html` or `demo`.
- Do not create an HTML prototype as a prerequisite for a demo.
- Do not put separate top-level `prototypes/` and `demos/` collections in the repository.
- Keep each deliverable self-contained. It must not import files or packages from sibling deliverables.
- An HTML deliverable must have `implementation/index.html` and relative asset paths.
- A demo must include its own frontend, backend, database migrations, seed data, environment example, Docker Compose configuration, health check, and reset procedure.
- Never commit real credentials, `.env` files, production data, or identifiable business data.
- Do not enable public deployment without explicit user approval.

## Lifecycle

Allowed product states are `draft`, `review`, `approved`, and `archived`. The state lives in `artifact.yaml`; never represent state by moving a deliverable between directories.

All deliverables on `main`, including drafts, must remain openable or independently runnable. Product maturity and runtime health are separate concerns.

## Change workflow

- Use a short-lived `codex/<artifact-id>-<change>` branch for Codex changes unless the user requests another name.
- Update the relevant product document when behavior or scope changes.
- Use Git history and scoped tags such as `artifact/<artifact-id>/v1.0.0` for versions. Do not create copied `v1`, `v2`, or `final` folders.
- Run `ruby governance/scripts/validate_artifacts.rb` before handing off repository-structure or deliverable changes.
- For demo changes, also run the demo's own smoke-test procedure when Docker is available.
