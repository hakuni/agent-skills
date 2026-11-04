# Changelog

All notable changes to the skills in this repository are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com), and
versions follow [SemVer](https://semver.org) per skill.

## [1.0.0] - 2026-11-04

### Added — `execution-orchestration`
- Initial release of the Execution Orchestration & Approval Gate skill.
- Fail-closed intercept: no state-changing action before an approved plan.
- Two plan classes: light plan (small tasks) and full plan (multi-file,
  destructive, or external-runtime work).
- Runtime-tiered execution strategy: external orchestrator → internal
  subagents → sequential with checkpoints.
- Partial approval semantics ("execute steps 1–3 only").
- Hard-gate double confirmation for destructive actions.
- Plan persistence (`.plan.md`) with resume-after-interruption semantics.
- Scope-creep guard with discovered-work collection.
- Mandatory closing report mapping acceptance criteria to evidence.
- Agent-agnostic: no runtime-specific references (compatible with any
  [Agent Skills](https://agentskills.io)-compliant harness).

### Added — repository tooling
- `install.sh`: one-command installer that copies every skill in `skills/`
  into a flat, spec-compliant Agent Skills directory (default
  `~/.agents/skills`, override with `--target` or `$SKILLS_DIR`).
  Idempotent by default (`--force` replaces skills in place, dropping
  stale files); supports `--list`, `--help`; unknown options fail with a
  non-zero exit. Runs on Linux, macOS, and Windows (Git Bash/WSL).
- `test.sh`: smoke tests for `install.sh` (fresh install, skip on re-run,
  in-place overwrite with `--force`, stale-file cleanup, `--list`, `--help`,
  unknown-option handling, and `$SKILLS_DIR`). Run with `bash test.sh`.
- `.gitattributes`: forces LF line endings for shell scripts so the repo
  works correctly on Windows checkouts.
- README: documented the one-command install flow, script options, and
  development tests.

[1.0.0]: https://github.com/hakuni/agent-skills/releases/tag/v1.0.0
