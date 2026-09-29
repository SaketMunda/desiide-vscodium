#!/usr/bin/env bash
# Regenerates the Mutt app icons in ../resources/ from mutt-icon.svg.
# macOS only (qlmanage renders the SVG, sips resizes, iconutil builds the .icns). The outputs are
# committed, so this only needs re-running when the SVG changes.
set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"
OUT=../resources
TMP=$( mktemp -d )
trap 'rm -rf "${TMP}"' EXIT

qlmanage -t -s 1024 -o "${TMP}" mutt-icon.svg > /dev/null
SRC="${TMP}/mutt-icon.svg.png"

png() { sips -z "$1" "$1" "${SRC}" --out "$2" > /dev/null; }

mkdir -p "${OUT}/darwin" "${OUT}/linux" "${OUT}/server" "${TMP}/code.iconset"
for size in 16 32 128 256 512; do
  png "${size}" "${TMP}/code.iconset/icon_${size}x${size}.png"
  png "$(( size * 2 ))" "${TMP}/code.iconset/icon_${size}x${size}@2x.png"
done
iconutil -c icns "${TMP}/code.iconset" -o "${OUT}/darwin/code.icns"

png 512 "${OUT}/linux/code.png"
cp mutt-icon.svg "${OUT}/linux/code.svg"
png 192 "${OUT}/server/code-192.png"
png 512 "${OUT}/server/code-512.png"
png 32 "${TMP}/favicon.png"
sips -s format ico "${TMP}/favicon.png" --out "${OUT}/server/favicon.ico" > /dev/null

# Editor watermark ("letterpress"): the dog mark in the flat grey VSCodium uses for each theme kind.
LETTERPRESS=../src/vs/workbench/browser/parts/editor/media
mkdir -p "${LETTERPRESS}"
letterpress() { # <file> <color> <opacity>
  cat > "${LETTERPRESS}/$1" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="$2" stroke-opacity="$3" stroke-linecap="round" stroke-linejoin="round">
  <path d="M5.2 9.2 3.5 4.5 8.2 6.4Z" fill="$2" fill-opacity="$3" stroke-width="1"/>
  <path d="M15.6 6.5C18.4 6 20.9 6.9 21.2 9.3c.2 1.9-.5 3.9-1.7 4.3-.9-1.2-1-2.9-.8-4.3Z" fill="$2" fill-opacity="$3" stroke-width="1"/>
  <path d="M5 9c0 6 3 10 7 10s7-4 7-10c-1.5-2-4-3-7-3S6.5 7 5 9Z" stroke-width="1.35"/>
  <circle cx="9.5" cy="11.6" r=".85" fill="$2" fill-opacity="$3" stroke="none"/>
  <circle cx="14.5" cy="11.6" r=".85" fill="$2" fill-opacity="$3" stroke="none"/>
  <path d="M10.9 14.9h2.2l-1.1 1.3Z" fill="$2" fill-opacity="$3" stroke-width=".5"/>
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
  mutt-icon.svg > ../src/vs/workbench/browser/media/code-icon.svg

# Marketplace / Open VSX icon for the mutt-ai extension.
png 128 ../../../../extensions/mutt-ai/media/icon.png

echo "icons written to $( cd "${OUT}" && pwd )"
