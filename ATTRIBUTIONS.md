# Attributions

This project incorporates and builds on the work of others. Each entry below
identifies the upstream source, the license under which it is used, and what
parts of this project are derived from or inspired by it.

## Anvil — Burke Holland

- **Upstream**: https://github.com/burkeholland/anvil
- **Author**: Burke Holland (https://postrboard.com)
- **License**: MIT

Burke Holland's `anvil` defines an evidence-first, verification-disciplined
working style for GitHub Copilot CLI agents — the Anvil Loop, the verification
ledger, the adversarial review pattern, and the commitment to never present
broken code. The `agents/preambles/anvil.md` file in this repository is a
faithful adaptation of that work: it preserves the structure, the verification
gates, and the core rules. Project-specific extensions (wiring verification,
spec compliance, the Goal Card / steward discipline, worktree integration)
live in *separate* opt-in preambles so `anvil.md` stays close to upstream and
can absorb future changes from Burke's repo with minimal merge cost.

The Anvil discipline is the foundation of every implementer-shaped agent in
this team. Credit for the underlying methodology — and for the name — belongs
to Burke.

If you found this team's working style useful, the original is worth a star:
https://github.com/burkeholland/anvil

## How to add to this list

When you incorporate or substantially derive from another project's work:

1. Add an entry above with upstream URL, author, license, and a description
   of what you took and what you added.
2. Preserve any required upstream notices in the relevant files.
3. If the upstream license requires it, include the upstream LICENSE text in
   `licenses/{project}.LICENSE`.
