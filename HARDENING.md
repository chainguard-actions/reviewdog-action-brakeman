<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-brakeman/v2.21.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-brakeman/v2.21.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh (the supporting script that action.yml's composite step runs) downloads the reviewdog installer and pipes it straight into a shell: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}"`. The URL is pinned to a commit, but the script still runs without first being saved and checked. Save it to a file, verify it (for example with a checksum), and then run it as a separate step.

Locations:

- `script.sh:16`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed script.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/script.sh b/script.sh
index c5fe370..a5752c5 100755
--- a/script.sh
+++ b/script.sh
@@ -13,7 +13,14 @@ TEMP_PATH="$(mktemp -d)"
 PATH="${TEMP_PATH}:$PATH"
 
 echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
-curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
+REVIEWDOG_INSTALL_SCRIPT="${TEMP_PATH}/reviewdog-install.sh"
+curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh -o "${REVIEWDOG_INSTALL_SCRIPT}"
+if [ ! -s "${REVIEWDOG_INSTALL_SCRIPT}" ] || ! head -n 1 "${REVIEWDOG_INSTALL_SCRIPT}" | grep -q '^#!'; then
+  echo '::error::Downloaded reviewdog install script is empty or invalid'
+  exit 1
+fi
+sh "${REVIEWDOG_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
+rm -f "${REVIEWDOG_INSTALL_SCRIPT}"
 echo '::endgroup::'
 
 if [ "${INPUT_SKIP_INSTALL}" = "false" ]; then

```

Locations:

- `script.sh`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, prior-fix

**Notes:**

In script.sh, the reviewdog installer is now saved to a file instead of being piped into sh. It is still downloaded from the same commit-pinned URL. Before running it, the script stops with an error if the file is empty or its first line is not a shebang (#!). It is then run as `sh "$file" -b "$TEMP_PATH" "$REVIEWDOG_VERSION"`, with `-s --` removed so the arguments reach the installer in the same positions as before, and the file is deleted afterwards. This puts back the earlier harden's patch. The finding suggested a checksum, but none was added: the check only catches an empty or obviously broken download and cannot tell whether the content was changed. Nothing was run or tested.

