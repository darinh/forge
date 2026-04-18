#!/usr/bin/env bash
# build-agents.sh — expand {{include}} markers in agent .tmpl files.
#
# Usage:
#   scripts/build-agents.sh              # build all agents/*.agent.md.tmpl
#   scripts/build-agents.sh --check      # verify generated files are up to date (CI mode)
#   scripts/build-agents.sh path/to.tmpl # build a single template
#
# Convention:
#   Templates live at agents/{name}.agent.md.tmpl.
#   They may contain lines of the exact form:
#       {{include path/to/file.md}}
#   Paths are relative to the agents/ directory. The marker line is
#   replaced verbatim with the contents of the included file.
#
#   The output is written to agents/{name}.agent.md with a header noting
#   it is generated. Plain agents/{name}.agent.md files (no .tmpl twin)
#   are left alone — opt-in only.
#
#   Templates that have no {{include}} markers still produce a generated
#   file (useful for visibility) but emit a warning.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$ROOT_DIR/agents"
CHECK_MODE=0
TARGETS=()

for arg in "$@"; do
    case "$arg" in
        --check) CHECK_MODE=1 ;;
        -h|--help)
            sed -n '2,20p' "$0"
            exit 0
            ;;
        *) TARGETS+=("$arg") ;;
    esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    while IFS= read -r -d '' f; do TARGETS+=("$f"); done \
        < <(find "$AGENTS_DIR" -maxdepth 1 -name '*.agent.md.tmpl' -print0)
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo "build-agents: no .tmpl files found under $AGENTS_DIR" >&2
    exit 0
fi

GENERATED_NOTICE='<!-- GENERATED FILE — DO NOT EDIT.
     Source: {SRC}
     Regenerate with: scripts/build-agents.sh -->'

expand_template() {
    local src="$1"
    local rel_src
    rel_src="${src#"$ROOT_DIR/"}"
    local notice="${GENERATED_NOTICE//\{SRC\}/$rel_src}"

    # Templates MUST start with YAML frontmatter (line 1 == `---`) so the
    # generated file's line 1 is also `---` for the agent loader's parser.
    if ! head -1 "$src" | grep -qx '\-\-\-'; then
        echo "build-agents: ERROR — template must start with YAML frontmatter (line 1 must be '---'): $rel_src" >&2
        exit 2
    fi

    # Stream the template, replacing {{include X}} lines. Emit the
    # GENERATED notice right after the closing frontmatter delimiter.
    local line include_path include_file include_real fm_count=0 notice_emitted=0
    local preambles_root
    preambles_root="$(cd "$AGENTS_DIR/preambles" && pwd -P)"
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == '---' ]]; then
            fm_count=$((fm_count + 1))
            printf '%s\n' "$line"
            if [[ "$fm_count" -eq 2 && "$notice_emitted" -eq 0 ]]; then
                printf '\n%s\n' "$notice"
                notice_emitted=1
            fi
            continue
        fi
        if [[ "$line" =~ ^[[:space:]]*\{\{include[[:space:]]+([^}]+)\}\}[[:space:]]*$ ]]; then
            include_path="${BASH_REMATCH[1]}"
            include_path="${include_path%"${include_path##*[![:space:]]}"}" # rtrim
            # Reject absolute paths and any path containing '..' segments.
            if [[ "$include_path" == /* || "$include_path" == *..* ]]; then
                echo "build-agents: ERROR — include path must be relative and stay under agents/preambles/: '$include_path' (in $rel_src)" >&2
                exit 2
            fi
            include_file="$AGENTS_DIR/$include_path"
            if [[ ! -f "$include_file" ]]; then
                echo "build-agents: ERROR — included file not found: $include_path (referenced in $rel_src)" >&2
                exit 2
            fi
            # Canonicalize and confirm the resolved path is inside preambles/
            # (defends against symlink escapes — including file-level symlinks).
            include_real="$(readlink -f -- "$include_file")"
            if [[ -z "$include_real" || "$include_real" != "$preambles_root"/* ]]; then
                echo "build-agents: ERROR — include resolved outside agents/preambles/: $include_real (in $rel_src)" >&2
                exit 2
            fi
            # Reject nested {{include}} markers in included content — keeps
            # the model simple and prevents accidental recursion / cycles.
            if grep -qE '^[[:space:]]*\{\{include[[:space:]]+[^}]+\}\}[[:space:]]*$' "$include_real"; then
                echo "build-agents: ERROR — nested {{include}} markers are not supported (found in $include_path, referenced from $rel_src)" >&2
                exit 2
            fi
            cat "$include_real"
            printf '\n'
        else
            printf '%s\n' "$line"
        fi
    done < "$src"
}

EXIT_CODE=0
BUILT=0
DRIFTED=()

for tmpl in "${TARGETS[@]}"; do
    if [[ ! -f "$tmpl" ]]; then
        echo "build-agents: skipping (not a file): $tmpl" >&2
        continue
    fi
    out="${tmpl%.tmpl}"
    new_content="$(expand_template "$tmpl")"

    if [[ "$CHECK_MODE" -eq 1 ]]; then
        if [[ ! -f "$out" ]] || ! diff -q <(printf '%s\n' "$new_content") "$out" >/dev/null 2>&1; then
            DRIFTED+=("$out")
            EXIT_CODE=1
        fi
    else
        # Atomic replace: write to temp file in the same dir, then mv.
        tmp_out="${out}.tmp.$$"
        printf '%s\n' "$new_content" > "$tmp_out"
        mv -f "$tmp_out" "$out"
        BUILT=$((BUILT + 1))
    fi
done

if [[ "$CHECK_MODE" -eq 1 ]]; then
    if [[ ${#DRIFTED[@]} -gt 0 ]]; then
        echo "build-agents: ${#DRIFTED[@]} generated file(s) out of date:" >&2
        printf '  %s\n' "${DRIFTED[@]}" >&2
        echo "Run scripts/build-agents.sh to regenerate." >&2
    else
        echo "build-agents: all generated agent files are up to date."
    fi
else
    echo "build-agents: regenerated $BUILT agent file(s)."
fi

exit "$EXIT_CODE"
