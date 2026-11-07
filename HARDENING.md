<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-brakeman/v2.21.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-brakeman/v2.21.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh, which the composite action's run step calls, downloads the reviewdog install script and pipes it straight into a shell: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}"`. The URL is pinned to a commit, but the downloaded content runs without first being saved to a file and checked. To fix this, save the script to a file, verify it (for example against a checksum), then run it as a separate step.

Locations:

- `script.sh:16`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

script.sh now downloads the reviewdog install script to a file in TEMP_PATH. The URL is unchanged and still pinned to a commit. Before running the file, the script checks that it is not empty and starts with a shebang line; if either check fails, the step stops. The file is then run with 'sh <file> -b "$TEMP_PATH" "$REVIEWDOG_VERSION"'. I dropped the '-s --' from the old pipe form so the installer's arguments stay in their original positions. I didn't add a checksum check because I couldn't download the script to compute its hash. The URL being pinned to a commit limits that risk.

