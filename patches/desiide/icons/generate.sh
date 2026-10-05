#!/usr/bin/env bash
# Regenerates the Desiide app icons in ../resources/ from desiide-icon.svg.
# macOS only (qlmanage renders the SVG, sips resizes, iconutil builds the .icns). The outputs are
# committed, so this only needs re-running when the SVG changes.
set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"
OUT=../resources
TMP=$( mktemp -d )
trap 'rm -rf "${TMP}"' EXIT

qlmanage -t -s 1024 -o "${TMP}" desiide-icon.svg > /dev/null
SRC="${TMP}/desiide-icon.svg.png"

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

# Editor watermark ("letterpress"): the "D" mark in the flat grey VSCodium uses for each theme kind.
LETTERPRESS=../src/vs/workbench/browser/parts/editor/media
mkdir -p "${LETTERPRESS}"
letterpress() { # <file> <color> <opacity>
  cat > "${LETTERPRESS}/$1" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none">
  <rect x="4.5" y="4" width="2.6" height="16" rx=".7" fill="$2" fill-opacity="$3"/>
  <path d="M9.2 5.6h2.6a6.4 6.4 0 0 1 0 12.8H9.2" stroke="$2" stroke-opacity="$3" stroke-width="2.6"/>
  <circle cx="12.4" cy="12" r="1.5" fill="$2" fill-opacity="$3"/>
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
