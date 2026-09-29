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

# Marketplace / Open VSX icon for the mutt-ai extension.
png 128 ../../../../extensions/mutt-ai/media/icon.png

echo "icons written to $( cd "${OUT}" && pwd )"
