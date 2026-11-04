# agent-skills

A collection of agent skills following the [Agent Skills](https://agentskills.io)
specification (`SKILL.md`). Agent-neutral — usable with pi, Orca, Hermes, or any
spec-compliant agent.

## Skills

| Skill | Version | Description |
|---|---|---|
| [`execution-orchestration`](skills/execution-orchestration/SKILL.md) | 1.0.0 | Plan-before-execute protocol with an explicit approval gate before any state-changing action. |

## Installation

### One-command install (recommended)

```bash
git clone https://github.com/hakuni/agent-skills
cd agent-skills
./install.sh
```

Copies every skill in `skills/` to the flat, spec-compliant layout
(`~/.agents/skills/<skill>/SKILL.md`), so the skills work with any
Agent Skills-compatible agent — including ones that only scan one level deep.
Works on Linux, macOS, and Windows (Git Bash/WSL).

| Option | Description |
|---|---|
| `-t, --target <dir>` | Install to a custom directory (default: `~/.agents/skills`, or `$SKILLS_DIR`) |
| `-f, --force` | Replace skills that already exist in place (also the update command) |
| `-l, --list` | List available skills |
| `-h, --help` | Show help |

### Install from a git URL

```bash
pi install git:github.com/hakuni/agent-skills@main        # pi (package)
npx skills@latest add hakuni/agent-skills                 # any Agent Skills-compatible agent
```

### Manual

Copy or symlink the skill folder you want to the location your agent
discovers — `~/.agents/skills/` for the standard location, or the agent's
own skills directory.

## Updating

Pull the latest changes and re-run the installer:

```bash
cd agent-skills
git pull
./install.sh --force
```

Then restart your agent session (or run `/reload` in pi) to pick up changes.

## Conventions

- One skill = one directory containing `SKILL.md`
- The `version` field in the frontmatter bumps on every behavioral change;
  git tags (`v<version>`) mark releases, changes are tracked in
  [`CHANGELOG.md`](CHANGELOG.md)
- Skills are written in English
- State-changing work follows the `execution-orchestration` protocol
  (plan → approval → execute)

## Development

After changing `install.sh` (or adding skills), run the smoke tests:

```bash
bash test.sh
```

## License

[MIT](LICENSE)
