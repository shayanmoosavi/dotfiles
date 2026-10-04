# Global AGENTS.md

Cross-project instructions for any AI coding agent working with Shayan on any
repository. **Project-level AGENTS.md files take precedence over this file
wherever they conflict** — this file defines only behavior that transfers
across projects.

## 1. Purpose & Audience

- The main use-case for agents is **increasing development productivity** and
  **helping Shayan learn to code better**.
- Implication: agents teach, not just execute. Explain reasoning alongside
  actions, and keep momentum — don't stall on trivial decisions that can be
  made and justified in-line.

## 2. Communication Protocol

- **Clarify before planning.** Always ask clarifying questions before
  proposing a plan or giving a detailed explanation — unless the task is
  clearly scoped and needs no clarification.
- **Justify every step.** During a plan or explanation, state *why* each step
  is done, not just *what* is done.
- **Report after notable progress.** After a milestone in a specific project
  (finishing a refactor, adding a major feature, etc.), post a status report
  as a reminder:
  - current state of the project
  - remaining TODOs / next steps

## 3. Codebase Exploration Policy

- When searching or analyzing a codebase, **always prefer `codebase-memory-mcp`**
  (graph tools: `search_graph`, `trace_path`, `get_code_snippet`, …) over
  plain grep, if the agent has access to it and its tools.
- If the agent does **not** have access to that skill, **say so explicitly**
  so Shayan can troubleshoot the setup.
- Fall back to grep and standard agent tools only if troubleshooting fails.

## 4. Engineering Principles

Apply these as defaults in any project; the project's own AGENTS.md overrides.

- **Layered architecture, one-way dependencies.** Domain/core layers must
  never import UI or service-shell layers. Dependencies point inward only.
- **Dependency injection over global state.** Build dependencies once at
  composition time and thread them explicitly; nothing reaches for globals.
- **Ports for environment-specific code.** Define duck-typed protocols for
  things like interaction, progress, and rendering; implement them at the UI
  layer and inject them into the core. Core stays reusable by alternate
  frontends.
- **Per-layer exception hierarchies.** Each layer has its own domain
  exceptions rooted in a single base error for the project.
- **Typed data across layers.** Prefer frozen dataclasses / typed result
  objects over loose dicts for values crossing layer boundaries.

## 5. Testing Checklist

- Unit tests **mirror the source structure 1:1** (package-for-package).
- Mock at **precise, minimal boundaries** — never mock what can be constructed
  for real.
- Prefer **real models/objects over bare mocks**.
- When mocking is required, use **specced mocks** (`MagicMock(spec=X)`) over
  stacked decorators.
- Integration tests mock **only the true OS boundary** (subprocess, network,
  desktop notifications); everything else uses real files/tempdirs.

## 6. Quality Gates & Finishing Checklist

Before declaring any task finished, run the project's own documented commands
in this order (substitute the project's tools):

1. **Lint** (e.g. `ruff check`)
2. **Format check** (e.g. `ruff format --check`)
3. **Tests** (full suite, or the relevant subset for small changes)
4. **Type check** (e.g. `ty`, `mypy`)

Additional rules:

- Strict builds (e.g. `mkdocs build --strict`) **must stay green**.
- **Verify every edited file** at the end of a task (read back / run).
- The final summary must state: what was done, and anything the user should
  know (assumptions, limitations, follow-ups).
- Never leave a repo with unexplained diffs. Follow the project's commit
  conventions (e.g. commitizen) when committing.

## 7. Documentation & Project-File Upkeep

- If a project has an AGENTS.md and it disagrees with the actual codebase,
  **invoke the `agents-md-sync` skill** to reconcile it before finishing the
  task.
- Project-level AGENTS.md **overrides** this global file.

## 8. Scope

Project-specific context (file trees, dev commands, config locations, domain
details) lives in each repository's own AGENTS.md. This file contains only
cross-project behavior and principles.
