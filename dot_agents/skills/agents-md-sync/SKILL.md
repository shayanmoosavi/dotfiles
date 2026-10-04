---
name: agents-md-sync
description: "Audit and repair AGENTS.md (and sibling agent-instruction files) when they drift from the codebase. Triggers on: AGENTS.md stale, AGENTS.md out of sync, AGENTS.md disagrees with the codebase, update agent instructions, sync agent docs, refresh AGENTS.md, file list wrong, file table missing a file, documented commands wrong, structure tree outdated, agent doc drift, verify AGENTS.md claims."
---

# agents-md-sync — Repair Agent-Instruction Drift

AGENTS.md files rot silently: files get added, commands move, and the document keeps teaching
agents a stale codebase. This skill audits every falsifiable claim in AGENTS.md against the live
tree, repairs only confirmed drift, and reports the result. It is **generic** — nothing
repo-specific is baked in; project truth lives in the repo itself.

## When to Invoke

- The user says AGENTS.md is stale, wrong, or needs syncing.
- The repo's AGENTS.md carries the covenant line (see bottom) — invoke before finishing any task
  where you noticed drift.
- You noticed drift mid-task (missing file rows, wrong commands, renamed symbols) — finish the
  primary task, then invoke this skill.

## Scope

- **Master file:** the AGENTS.md nearest the project root.
- **Siblings:** also check, when present — `CLAUDE.md`, `.cursorrules`, `.cursor/rules/`,
  `.github/copilot-instructions.md`, `.windsurfrules`, `GEMINI.md`.
- Verify each claim once; repair the same drift everywhere it appears. Siblings that merely
  reference ("see AGENTS.md") are not expanded.
- Nothing else in the repo is edited (no README prose, no other docs) unless the user asks.

## Core Principles

1. **Verify before edit.** A claim is corrected only after ground truth contradicts it.
   Suspicion is not drift.
2. **Preserve format.** Markdown tables, tree glyphs, section order, tone, and terseness stay
   exactly as the file has them.
3. **Minimal diff.** Corrections only. No rewrites, no reorganization, no "improvements."
4. **Flag, don't delete.** Claims that can't be verified (and can't be disproven) stay, but are
   listed as unverifiable in the report.
5. **Execution freedom.** Any non-destructive command may run for verification, including the
   test suite and doc builds. Never install dependencies, mutate project config, or commit.

## Workflow

### 1. Locate

Find the master AGENTS.md and enumerate sibling agent-instruction files present in the repo.

### 2. Inventory

Extract every falsifiable claim into a ledger: `claim → file:line → type → status`. Use the
claim taxonomy below. A claim is falsifiable if a concrete check could confirm or refute it.
Abstract rules ("layer X must never import Y") are only checked if cheaply checkable
(e.g. grep imports); otherwise mark them unverifiable rather than trusting them.

### 3. Verify

Work through the ledger with the taxonomy matrix, preferring the cheapest sufficient check.
If a codebase-memory graph is indexed for the project (`list_projects`/`index_status`), use it
for symbol lookups — Scout tier only: positive lookups with targeted source checks, no
exhaustive or absence claims; fall back to grep/read for anything the graph doesn't cover.
Beware truncated `find`/`grep` output: re-run targeted queries before declaring a claim missing.

### 4. Apply

- Master file first, then propagate identical corrections to siblings.
- Surgical edits: one table row, one line, one tree entry. Never rewrite a section wholesale.
- Match existing table column widths loosely; exact pipe alignment is cosmetic.

### 5. Re-verify

- Re-read each edited row against its source evidence.
- Run documented commands where cheap and meaningful: `--help` for CLI examples, format/lint
  checks, doc-site builds (e.g. `mkdocs build --strict` when the docs section changed),
  targeted test subsets — the full suite when edits are extensive or the invocation warrants it.
- A claim you just wrote is a claim too: it deserves the same verification.

### 6. Report

Produce the report format below. If sibling files were checked and clean, say so in one line.

## Claim Taxonomy

| Claim type | Ground truth | Notes |
|---|---|---|
| File table rows (name + purpose) | `ls` the dir **and** read the file's header/docstring | Existence alone proves nothing; purposes drift independently |
| Structure trees | `find`/`tree` on the real dirs | Include subdirectories, conftest/dunder files, nested extras |
| Class/function/model names | grep for `^class `/`^def ` definitions; graph search when indexed | Check the name AND the file where it's claimed to live |
| Dev commands | `pyproject.toml` (scripts, dependency groups), CI workflows, `Makefile`, `scripts/` | Commands often live in CI, not manifests |
| Dependency lists | package manifests | Include extras/groups the doc names |
| Version / language claims | `requires-python`, `engines`, CI matrix pins | Quote the exact range |
| Env vars | grep source for the literal | Confirm both name and purpose |
| Config file locations | loader/source code that constructs paths | |
| Doc-site structure | site config nav (e.g. `mkdocs.yml`) + `find docs` | |
| Behavioral claims (exit codes, scheduling rules) | source of the implementing function | Read the actual code path |

## Gotchas

- Existence ≠ correctness: the real drift is often *omission* (a whole subtree missing from a
  structure tree), not a wrong row.
- Truncated `find`/`grep` output manufactures false negatives — re-run with a targeted path
  before concluding a claim fails.
- Row insertion breaks table column alignment — cosmetic; don't churn the whole table
  re-padding it.
- Symbols named in multiple places (ports table + file table) must be verified at each location.
- Superlative claims ("the ONLY OS boundary", "must never import") — verify cheaply via import
  grep when trivial; otherwise mark unverifiable rather than assuming.

## Report Format

```
## agents-md-sync report

Fixed:
- <file>: <one line per correction>

Verified correct (no change):
- <summarize groups, not every single claim>

Unverifiable:
- <claim> — <why>

Siblings:
- <file>: clean | repaired N claims
```

## Covenant Line Snippet

Repos add this under a "Keep this file in sync" note so future agents self-trigger:

```markdown
- **Keep this file in sync**: If you discover this file disagrees with the codebase, invoke the
  agents-md-sync skill before finishing.
```

