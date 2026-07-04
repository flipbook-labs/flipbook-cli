---
bump: minor
category: Changes
---

Releases are now handled by the [changewrite](https://github.com/flipbook-labs/changewrite) action, which bundles the whole release lifecycle (gate, draft, attach, publish, and the version-bump PR) into a single workflow step, replacing the bespoke `release` command and its multi-job workflow.
