# swi-shared-workflows

Shared security CI, configuration and templates for the Svalbard Watch (SWI) repositories.
Change a check here once instead of in every repository.

## What is here

| Path | Purpose |
|---|---|
| `.github/workflows/security.yml` | Reusable workflow: secret scan (gitleaks, full history), dependency audit (`pnpm audit`, `pip-audit` on `uv.lock`/`requirements.txt`), image build + Trivy scan, workflow lint (actionlint, zizmor). Each part skips itself when the repo has nothing to check. |
| `.github/workflows/ci.yml` | This repository runs the same workflow on itself. |
| `config/gitleaks.toml` | Shared gitleaks rules and the short list of reviewed allowances. |
| `templates/stubs/security.yml` | The ~15 line caller every repository copies unchanged. |
| `templates/dependabot/` | `dependabot.yml` templates per stack (Dependabot has no org-level config). |
| `templates/rulesets/default-branch.json` | Default-branch ruleset for repositories without one. |
| `scripts/apply-ruleset.sh` | Applies that ruleset to public repositories (dry run by default). |

## Using it in a repository

1. Copy `templates/stubs/security.yml` to `.github/workflows/security.yml`.
2. Copy the matching `templates/dependabot/*.yml` to `.github/dependabot.yml`.
3. Delete `renovate.json` if present.

Inputs of the reusable workflow are optional: `dockerfile`, `docker-context`, `pnpm-audit-level`, `shared-ref`, `report-only`, `runner` (JSON `runs-on`, default `["ubuntu-latest"]`).

**Rollout:** stubs start with `report-only: true` (findings are logged, builds stay green). Once a repository's findings are fixed, delete that line so the checks enforce.

## Principles

- No third-party services: GitHub Actions, Dependabot, and open-source CLIs run inside the job.
- Third-party actions are pinned to a commit SHA (comment holds the version); tool images are pinned by version tag.
- The workflow only has `contents: read`.
- Callers reference this repository by `@main` for now; switch the stubs to a moving `@v1` tag once the workflow is stable.

## Private repositories

Secret scanning, push protection and CodeQL are not available on private repositories on the free plan.
This workflow is their substitute (gitleaks, Trivy, audits); rulesets are not available there either.
