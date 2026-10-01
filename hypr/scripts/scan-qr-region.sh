#!/usr/bin/env bash
# Drag-select a screen region, decode a QR code in it, and copy its payload.
set -o pipefail

selection="$(slurp 2>/dev/null)" || exit 0
payload="$(grim -g "$selection" - 2>/dev/null | zbarimg --nodbus --quiet --raw --set '*.enable=0' --set 'qrcode.enable=1' - 2>/dev/null)"

if [[ -z "$payload" ]]; then
    notify-send -a "QR scanner" "No QR code found" "Try selecting a tighter, clearer area."
    exit 1
fi

printf '%s' "$payload" | wl-copy
notify-send -a "QR scanner" "QR code copied" "$payload"
