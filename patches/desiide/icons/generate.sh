#!/usr/bin/env bash
# Regenerates the Desiide app icons in ../resources/ from desiide-icon.svg.
# macOS only: Chromium (the repo's playwright-core) renders the SVG, sips resizes, iconutil builds the
# .icns. The outputs are committed, so this only needs re-running when the SVG changes.
set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"
OUT=../resources
TMP=$( mktemp -d )
trap 'rm -rf "${TMP}"' EXIT

SRC="${TMP}/desiide-icon.png"
node render.mjs desiide-icon.svg "${SRC}" 1024 # transparent corners (Quick Look rendered on white)

png() { sips -z "$1" "$1" "${SRC}" --out "$2" > /dev/null; }

mkdir -p "${OUT}/darwin" "${OUT}/linux" "${OUT}/server" "${TMP}/code.iconset"
for size in 16 32 128 256 512; do
  png "${size}" "${TMP}/code.iconset/icon_${size}x${size}.png"
  png "$(( size * 2 ))" "${TMP}/code.iconset/icon_${size}x${size}@2x.png"
done
iconutil -c icns "${TMP}/code.iconset" -o "${OUT}/darwin/code.icns"

png 512 "${OUT}/linux/code.png"
cp desiide-icon.svg "${OUT}/linux/code.svg"
png 192 "${OUT}/server/code-192.png"
png 512 "${OUT}/server/code-512.png"
png 32 "${TMP}/favicon.png"
sips -s format ico "${TMP}/favicon.png" --out "${OUT}/server/favicon.ico" > /dev/null

# Editor watermark ("letterpress"): the shirorekha "D" mark in the flat grey VSCodium uses for each theme kind.
LETTERPRESS=../src/vs/workbench/browser/parts/editor/media
mkdir -p "${LETTERPRESS}"
letterpress() { # <file> <color> <opacity>
  cat > "${LETTERPRESS}/$1" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none">
  <rect x="4.2" y="4.2" width="15.6" height="2.3" rx=".5" fill="$2" fill-opacity="$3"/>
  <rect x="4.2" y="4.2" width="2.6" height="15.6" rx=".6" fill="$2" fill-opacity="$3"/>
  <path d="M8.2 6.5h2.4a6 6 0 0 1 0 12H8.2" stroke="$2" stroke-opacity="$3" stroke-width="2.6"/>
  <circle cx="11.4" cy="12.5" r="1.5" fill="$2" fill-opacity="$3"/>
</svg>
SVG
}
letterpress letterpress-dark.svg '#B2B2B2' 0.3
letterpress letterpress-light.svg '#B2B2B2' 0.1
letterpress letterpress-hcDark.svg '#3C3C3C' 1
letterpress letterpress-hcLight.svg '#B2B2B2' 1

# Product icon used in the workbench (Welcome tab, About): the app icon cropped to its squircle.
mkdir -p ../src/vs/workbench/browser/media
sed -e 's|viewBox="0 0 1024 1024"|viewBox="100 100 824 824"|' -e 's|width="1024" height="1024"|width="16" height="16"|' \
  desiide-icon.svg > ../src/vs/workbench/browser/media/code-icon.svg

# Marketplace / Open VSX icon for the desiide-ai extension.
png 128 ../../../../extensions/desiide-ai/media/icon.png

echo "icons written to $( cd "${OUT}" && pwd )"
