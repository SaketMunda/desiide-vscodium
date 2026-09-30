#!/usr/bin/env bash
# shellcheck disable=SC2154
# Desiide branding + patches. Sourced by prepare_vscode.sh (cwd: vscode/) after VSCodium's own
# patches, so utils.sh's apply_patch is in scope. See README.md in this folder.

DESIIDE_PATCHES="../patches/desiide"

# 1. product.json overlay: Desiide names, data folders, bundle IDs, links. Wins over VSCodium's values.
jsonTmp=$( jq -s '.[0] * .[1]' product.json "${DESIIDE_PATCHES}/product.json" )
echo "${jsonTmp}" > product.json && unset jsonTmp

# 2. App icons and editor watermark (generated from icons/ by icons/generate.sh).
cp -R "${DESIIDE_PATCHES}/resources/." resources/
cp -R "${DESIIDE_PATCHES}/src/." src/

# 3. Built-in extensions.
# desiide-ai: scripts/build-editor.sh packages it to vscode/.build/desiide/desiide-ai.vsix. Upstream's
# build installs a local VSIX listed in product.json builtInExtensions, verified by its SHA-256. No
# gallery metadata: the app must never look it up on Open VSX.
DESIIDE_AI_VSIX=".build/desiide/desiide-ai.vsix"
if [[ ! -f "${DESIIDE_AI_VSIX}" ]]; then
  echo "missing ${DESIIDE_AI_VSIX}: build with scripts/build-editor.sh from the desiide repo" >&2
  exit 1
fi
DESIIDE_AI_VERSION=$( unzip -p "${DESIIDE_AI_VSIX}" extension/package.json | jq -r '.version' )
if command -v sha256sum > /dev/null; then
  DESIIDE_AI_SHA256=$( sha256sum "${DESIIDE_AI_VSIX}" | cut -d' ' -f1 )
else
  DESIIDE_AI_SHA256=$( shasum -a 256 "${DESIIDE_AI_VSIX}" | cut -d' ' -f1 )
fi
rm -rf .build/builtInExtensions/desiide-ai # stale copies are reused when the version is unchanged
jsonTmp=$( jq --arg vsix "${DESIIDE_AI_VSIX}" --arg version "${DESIIDE_AI_VERSION}" --arg sha256 "${DESIIDE_AI_SHA256}" \
  '.builtInExtensions += [{ name: "desiide-ai", version: $version, sha256: $sha256, vsix: $vsix, repo: "https://github.com/SaketMunda/desiide", metadata: {} }]' \
  product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp
# desiide-app: app-only defaults (settings, Cmd/Ctrl+L). Plain local extension, no code.
cp -R "${DESIIDE_PATCHES}/extensions/." extensions/

# 4. Source patches, in name order.
for file in "${DESIIDE_PATCHES}"/*.patch; do
  if [[ -f "${file}" ]]; then
    apply_patch "${file}"
  fi
done
