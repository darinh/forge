# Wiring Verification

This preamble extends the Anvil verification cascade for projects where new
types must be *connected* to existing infrastructure to take effect — DI
containers, permission lists, plugin manifests, frontend bundlers that
silently mask type errors, etc.

> Include with `{{include preambles/wiring.md}}`. Pairs with
> `preambles/anvil.md`. Opt-in per agent — include only when the project
> has wiring concerns the bare Anvil tiers don't cover.

## Why this exists

A class that compiles but isn't registered does nothing. A handler whose
permission isn't on the allow-list errors only at runtime. A frontend
file that builds clean in the bundler can still have TypeScript errors
the bundler chose to ignore. None of these failures are caught by
"build passes + tests pass." They need an explicit wiring step.

## Tier 2b — Wiring Verification

Run after Anvil's Tier 2 (build/tests pass) and before any commit that
creates a **new** service, handler, component, command, or plugin.

1. **DI / IoC registration.** For every new service or handler class
   created, grep the project's DI registration code (e.g.,
   `Program.cs`, `module` files, `composition root`) for the class
   name. If it isn't registered, register it and re-run the build.
2. **Permissions / allow-lists.** If the new code includes a command
   handler, plugin, agent tool, MCP method, or any other capability
   guarded by an explicit allow-list, verify it appears in the relevant
   config (agent permission lists, plugin manifests, role tables,
   middleware policies).
3. **Export/import chains.** For new modules in barrel-export
   ecosystems (TypeScript `index.ts`, Python `__init__.py`, etc.),
   verify the export reaches the consumers that need it.
4. **Frontend type check.** For ANY change to a typed frontend file
   (TS/TSX/Vue/Svelte), run BOTH the bundler build AND the standalone
   type checker (`tsc --noEmit` or equivalent). Bundlers often succeed
   while the type checker fails. Both must pass.

INSERT each check into `anvil_checks` with `phase = 'after'` and
`check_name = 'wiring-{type}'` (e.g., `wiring-di`, `wiring-permissions`,
`wiring-exports`, `wiring-frontend-tsc`).

## Rules added by this preamble

- **Frontend changes require the standalone type checker.** Any edit to
  a typed frontend file triggers both the bundler build AND
  `tsc --noEmit` (or equivalent) in the verification cascade. Both must
  pass. No exceptions.
- **Wiring before committing.** Any commit that creates a new service,
  handler, component, command, or plugin must verify wiring (Tier 2b)
  before the commit is made. Catching this in code review is the
  expensive path; catching it before commit is the cheap path.
