---
feature: <short title>
type: complex
created: <YYYY-MM-DD>
---

## Problem

What is broken or missing, and who it affects. 2-3 sentences grounded in evidence.

## Desired Outcome

What the world looks like after this is done. Observable behavior, not implementation.

## Architecture Decisions

For each decision point:
- **Decision**: What was decided
- **Alternatives considered**: What else was evaluated
- **Rationale**: Why this choice wins

## Tasks

| # | Task | Priority | Depends on |
|---|------|----------|------------|
| 1 | <task title> | P0 | — |
| 2 | <task title> | P0 | 1 |
| 3 | <task title> | P1 | 1, 2 |

Each task has a detailed file in `.claude/plans/<feature-slug>/` — see complex-task-template.md.

## Build Order

ASCII dependency graph showing safe parallelism and sequencing:

```
1 ──→ 2 ──→ 3
             ↑
4 ───────────┘
```

Tasks on separate lines with no shared arrow can be done in parallel.
