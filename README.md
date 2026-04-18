# matrix-agents

Specialized agent profiles for [The Matrix](https://github.com/darinh/the-matrix), packaged as a GitHub Copilot CLI plugin.

## Why a plugin?

The Copilot CLI exposes the `task` tool (the orchestration primitive used to spawn sub-agents) only to:

1. The default agent.
2. **Plugin-installed agents** (`~/.copilot/installed-plugins/.../agents/*.agent.md`).

Project-local agents at `<repo>/agents/*.agent.md` do **not** receive `task`, regardless of frontmatter declarations. This means The Matrix's `operator` agent — whose entire job is to delegate work — could not actually delegate when launched as a project-local agent. Packaging the agents as a plugin solves this.

## Agents

- `operator` — orchestration & delegation only. The principal agent.
- `system-architect`, `api-designer`, `ux-designer`, `ux-researcher`, `product-manager`
- `backend-engineer`, `frontend-architect`, `frontend-services`, `component-agent`
- `devops-agent`, `platform-agent`, `security-agent`
- `qa-agent`, `technical-writer`, `scribe`, `retrospective`

Invoke with `--agent matrix-agents:<name>`, for example:

```sh
copilot --agent matrix-agents:operator
copilot --agent matrix-agents:backend-engineer
```

## Layout

```
plugin.json              # Copilot CLI plugin manifest
agents/
  *.agent.md             # GENERATED agent files consumed by the CLI
  *.agent.md.tmpl        # Source-of-truth templates (edit these)
  preambles/
    anvil.md             # Implementer discipline preamble
    operator.md          # Orchestration-only preamble
    git-worktree.md      # Worktree workflow preamble
scripts/
  build-agents.sh        # Expands {{include}} directives → regenerates *.agent.md
```

## Editing an agent

1. Edit the `.agent.md.tmpl` (and/or any preamble it includes).
2. Run `./scripts/build-agents.sh` to regenerate the `.agent.md` outputs.
3. Verify with `./scripts/build-agents.sh --check` (used by CI to fail on stale outputs).

## Local install (development)

Symlink this repo into the Copilot CLI plugins directory:

```sh
ln -s "$(pwd)" ~/.copilot/installed-plugins/_direct/darinh--the-matrix-agents
```

Restart any running Copilot session, then verify:

```sh
copilot --agent matrix-agents:operator
```

## Origin

These agents were extracted from [`darinh/the-matrix`](https://github.com/darinh/the-matrix) as part of the operator-delegation work in PR #526. The Matrix repo's `agents/` directory remains in place during the transition while the backend's `AgentIdentityLoader` is updated to load from a plugin install path.

## License

MIT.
