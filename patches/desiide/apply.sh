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

# 3. Source patches, in name order.
for file in "${DESIIDE_PATCHES}"/*.patch; do
  if [[ -f "${file}" ]]; then
    apply_patch "${file}"
  fi
done
