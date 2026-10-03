<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-brakeman/v2.19.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-brakeman/v2.19.2** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

In script.sh, the reviewdog installer is fetched and piped directly to `sh` without first saving it to a file: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1`. Even though the URL is pinned to a specific commit SHA in the path, the content is still executed immediately from the network without any integrity verification, violating the safe pattern of downloading first then executing separately.

Locations:

- `script.sh:16`

### script-injection (severity: high)

Sub-rule (b): In script.sh, the variable `${INPUT_BRAKEMAN_FLAGS}` — which holds the value of `inputs.brakeman_flags` set via the `env:` block in action.yml — is expanded **unquoted** in the brakeman command invocation: `${BUNDLE_EXEC}brakeman --quiet --format tabs --no-exit-on-warn --no-exit-on-error ${INPUT_BRAKEMAN_FLAGS} --output ...`. An unquoted shell expansion allows an attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to be interpreted by the shell, enabling command injection. The `# shellcheck disable=SC2086` comment confirms the intentional word-splitting but does not mitigate the injection risk.

Locations:

- `script.sh:57`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed two high-severity findings in script.sh:

1. unsafe-shell (line 16): Replaced `curl ... | sh -s -- -b ...` with a download-then-execute pattern. The reviewdog installer is now saved to `${TEMP_PATH}/install-reviewdog.sh` via `curl -sfL ... -o`, then executed with `sh "${REVIEWDOG_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1`. The `--` was correctly dropped as it was the shell's option terminator in the pipe form, not an argument to the installer script.

2. script-injection (line 57): Replaced the unquoted `${INPUT_BRAKEMAN_FLAGS}` expansion with a bash array populated via xargs NUL-delimited tokenization (`while IFS= read -r -d '' t; do brakeman_flags+=("$t"); done < <(printf '%s' "${INPUT_BRAKEMAN_FLAGS}" | xargs printf '%s\0')`), then passed as `"${brakeman_flags[@]}"`. This provides quote-aware argument splitting without allowing shell metacharacter injection. The shebang was updated from `#!/bin/sh -e` to `#!/bin/bash -e` and `shell: bash` was set in action.yml to support bash arrays and process substitution (GitHub-hosted runners always have bash).

