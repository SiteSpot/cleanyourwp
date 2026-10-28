# CleanYourWP

Read `AGENTS.md` first. It holds the rules for running the refresh on a site and for contributing here.

When the person pastes `PROMPT.md`, follow it phase by phase. Phases 0 to 6 are read-only. Phase 7 needs a literal `GO n` per item and a successful `tools/backup.sh` run first. Phase 8 checks the site every 30 minutes for 24 hours; use `/loop 30m` for it.

Scripts: `tools/backup.sh` (verified backup) and `tools/log.sh` (change log). Everything else is done with read-only WP-CLI, `curl` and a browser. Full restores follow `docs/restore.md`. Replacement code for common plugins is in `snippets/`. An example run is in `examples/brochure-site/`.
