<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-brakeman/v2.20.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-brakeman/v2.20.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remotely fetched install script directly to `sh` without first downloading and verifying it: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}"`. Although the URL is pinned to a specific commit SHA in the path, the content is still executed immediately without any integrity check (e.g. checksum verification), making this an unsafe-shell pattern.

Locations:

- `script.sh:16`

### script-injection (severity: high)

Rule (b) violation: `${INPUT_BRAKEMAN_FLAGS}` is expanded **unquoted** in the brakeman invocation on the same line as `${BUNDLE_EXEC}brakeman`. `INPUT_BRAKEMAN_FLAGS` is set from `${{ inputs.brakeman_flags }}` (a workflow-controllable, untrusted input). An unquoted shell expansion allows an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) into the command. The `# shellcheck disable=SC2086` comment on the preceding line explicitly suppresses the word-splitting warning, confirming the variable is intentionally unquoted. Offending line: `${BUNDLE_EXEC}brakeman --quiet --format tabs --no-exit-on-warn --no-exit-on-error ${INPUT_BRAKEMAN_FLAGS} --output "$BRAKEMAN_REPORT_FILE"`

Locations:

- `script.sh:51`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed two findings in script.sh:

1. unsafe-shell (line 16): Replaced `curl ... | sh -s -- -b ...` with download-then-execute pattern. The install script is downloaded to a mktemp file, executed with `sh "$INSTALL_SCRIPT" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}"` (dropping the `--` separator per instructions), then cleaned up.

2. script-injection (line 51): Replaced unquoted `${INPUT_BRAKEMAN_FLAGS}` with safe xargs-based tokenization. Flags are tokenized using `printf '%s' "$INPUT_BRAKEMAN_FLAGS" | xargs printf '%s\0'` into a temp file, then read into positional parameters via `while IFS= read -r -d '' ... done < "$_flags_file"`, and expanded as `"$@"` in the brakeman command.

Since `read -d ''` requires bash, the shebang was changed from `#!/bin/sh -e` to `#!/bin/bash -e` and `shell: sh` in action.yml was updated to `shell: bash`. GitHub-hosted runners always have bash available.

