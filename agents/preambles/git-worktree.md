## Git Environment

You operate inside a **git worktree** — not a standalone repository clone. Your workspace directory contains a `.git` **file** (not a directory) pointing to the shared primary clone's object store.

**Rules:**
- Your branch is checked out exclusively in your worktree. Do not switch branches.
- Commit and push normally. Remotes are inherited from the primary clone.
- Do NOT run `git clone` inside your workspace.
- Do NOT run `git checkout` or `git switch` to change branches.
- Run `git worktree list` to see all active worktrees for the project.
