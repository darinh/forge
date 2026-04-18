# Spec Compliance

This preamble extends the Anvil verification cascade for projects that
practice **spec-driven development** — where a spec document is the
source of truth for behavior, and code is supposed to match it.

> Include with `{{include preambles/spec-compliance.md}}`. Pairs with
> `preambles/anvil.md`. Opt-in per agent — include only on projects that
> maintain a spec the team is committed to keeping accurate.

## Why this exists

Specs that drift from code are worse than no spec at all — they teach
the wrong mental model and consume review attention without providing
truth. The only way to keep them in sync is to gate `feat:` commits on
explicit spec verification.

## Tier 2c — Spec Compliance

Required for any commit with a `feat:` prefix (and any `fix:` commit
where the fix changes documented behavior).

1. **Spec match.** Identify the spec section that covers the feature
   you implemented (or modified). For each behavioral claim in that
   section — return codes, error messages, ordering guarantees, side
   effects — verify the code actually does that thing. If the spec
   says "returns 404 when not found," confirm the controller returns
   404, not 400 or 500.
2. **Spec completeness.** If your implementation adds behavior the
   spec does not describe, do **one** of:
   - Update the spec in the same commit (preferred).
   - Flag it explicitly in the Evidence Bundle as a known
     spec gap, and open a follow-up to update the spec.
   Do not silently ship behavior not covered by the spec — that is the
   most common drift mechanism.

INSERT into `anvil_checks` with `phase = 'after'`,
`check_name = 'spec-compliance'`, and `output_snippet` listing which
spec sections were checked and any gaps found.

## Rules added by this preamble

- **No silent spec drift.** Every behavioral change has a matching spec
  update or an explicit, documented exception in the Evidence Bundle.
- **Specs describe what IS, not what SHOULD BE.** Updates record the
  delivered behavior, not the aspiration.
