# Forge

A small, opinionated team of GitHub Copilot CLI agents. Packaged as a plugin so each
agent receives the orchestration toolset (including the `task` tool) that project-local
agents cannot.

Built on [Burke Holland's Anvil discipline](https://github.com/burkeholland/anvil) and
extended with a Goal Card / steward layer so the team catches bad ideas — not just bad
code — before they ship.

## The team

Seven roles. No more, no less. Add custom prompts when you need finer focus.

| Role | What they own | Tools |
|------|---------------|-------|
| **operator** | Coordination, delegation, council, retrospectives. Reads Goal Cards to detect drift. Does no work directly. | `task`, `view`, `grep`, `glob` |
| **architect** | System / API / frontend architecture. ADRs. Contracts. Does no implementation. | `task`, `view`, `grep`, `glob`, `edit` |
| **implementer** | Builds it. Backend, frontend, platform, code-adjacent docs. | `bash`, `edit`, `view`, `grep`, `glob` |
| **qa** | Adversarial testing, bug filing, acceptance evaluation. | `bash`, `edit`, `view`, `grep`, `glob` |
| **devops** | CI/CD, Docker, release, infrastructure. | `bash`, `edit`, `view`, `grep`, `glob` |
| **product** | Requirements, user research, interaction design, IA. | `task`, `view`, `grep`, `glob`, `edit` |
| **scribe** | Reads Goal Cards, retros, failures. Proposes changes to the agent files themselves. The team's self-improvement engine. | `edit`, `view`, `grep`, `glob` |

Invoke with `--agent forge:<name>`:

```sh
copilot --agent forge:operator
copilot --agent forge:implementer
```

## Why a plugin?

The Copilot CLI exposes the `task` tool only to:

1. The default agent.
2. **Plugin-installed agents** under
   `~/.copilot/installed-plugins/.../agents/*.agent.md`.

Project-local agents at `<repo>/agents/*.agent.md` do **not** receive `task`,
regardless of frontmatter declarations. The operator agent — whose entire job is
delegation — could not delegate from a project-local install. Packaging as a
plugin solves it.

## Discipline

Two preambles cut through every agent in the team:

- **`anvil.md`** — verification-first working style. You don't present code until
  evidence proves it works. You attack your own output with adversarial review for
  Medium/Large work. You never show broken code. *Source: Burke Holland.*
- **`steward.md`** — the Goal Card. Before any non-trivial action, the agent records
  *stated task vs inferred goal*, surfaces divergence, runs three fresh-eyes questions,
  and emits a verdict (PROCEED / PROCEED-WITH-CAVEAT / **CHALLENGE**). CHALLENGE is
  stop-work authority. It's how the team catches bad ideas, not just bad code.
- **`selective-approval.md`** — under operator wrappers that grant blanket "yolo"
  approval, this carves out the JUDGMENT moments where blanket approval **must not**
  apply (scope changes, irreversible actions, declaring "done").
- **`coordination.md`** — operator-only. Each turn, query the Goal Cards table for new
  CHALLENGE verdicts and team-wide drift. The cards are the team's nervous system.

## Layout

```
plugin.json              # Copilot CLI plugin manifest
LICENSE                  # MIT
ATTRIBUTIONS.md          # Upstream credits — read this
agents/
  *.agent.md             # GENERATED agent files consumed by the CLI
  *.agent.md.tmpl        # Source-of-truth templates (edit these)
  preambles/
    anvil.md             # Implementer discipline (Burke Holland's Anvil)
    wiring.md            # DI/registration/frontend-tsc verification (opt-in)
    spec-compliance.md   # Spec-driven feat: gating (opt-in)
    steward.md           # Goal Card discipline
    selective-approval.md # JUDGMENT vs EXECUTION carve-outs
    coordination.md      # Operator drift monitoring
    operator.md          # Operator identity & refusal protocol
    git-worktree.md      # Worktree workflow
scripts/
  build-agents.sh        # Expands {{include}} markers → regenerates *.agent.md
```

## Editing an agent

1. Edit the `.agent.md.tmpl` (and/or any preamble it includes).
2. Run `./scripts/build-agents.sh` to regenerate the `.agent.md` outputs.
3. Verify with `./scripts/build-agents.sh --check` (used by CI to fail on stale outputs).

Both the `.tmpl` and the regenerated `.agent.md` must be committed — the runtime
loader reads the generated file.

## Local install (development)

Symlink this repo into the Copilot CLI plugins directory:

```sh
ln -s "$(pwd)" ~/.copilot/installed-plugins/_direct/darinh--forge
```

Restart any running Copilot session, then verify:

```sh
copilot plugin list | grep -q forge && echo "ok"
copilot --agent forge:operator
```

## Origin

Extracted from [`darinh/the-matrix`](https://github.com/darinh/the-matrix). Originally
shipped as `the-matrix-agents`; renamed to `forge` to reflect that the team is
project-agnostic — it's the team itself, not a piece of any particular system.

The Matrix is the most opinionated consumer, but `forge` works as a standalone team
for any project.

## Credits

The Anvil discipline (verification ledger, adversarial review, evidence bundle, the
rule against presenting broken code) is from
[`burkeholland/anvil`](https://github.com/burkeholland/anvil) by Burke Holland, used
under MIT. See [`ATTRIBUTIONS.md`](ATTRIBUTIONS.md).

## License

MIT — see [`LICENSE`](LICENSE).
