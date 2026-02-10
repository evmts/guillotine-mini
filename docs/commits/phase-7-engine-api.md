# Phase 7 — Engine API Commit Discipline

This phase follows the "one unit per commit" policy:

- One function or one struct per commit.
- Tests added in the same commit as the public API they validate.
- Docstring-only adjustments get their own commits.

Note: Earlier commit `9c7703a` bundled multiple units. Subsequent work restores
atomicity and will maintain strict granularity going forward.

