#!/bin/bash
FILEFILE=/tmp/wf-recorder.file
DIR=~/Videos/Recordings
mkdir -p "$DIR"

if pgrep -x wf-recorder > /dev/null; then
    FILE=$(cat "$FILEFILE" 2>/dev/null)
    pkill -SIGINT wf-recorder
    rm -f "$FILEFILE"
    notify-send --action="open-file:$FILE=Open Video" -i video-x-generic "Recording" "Saved to ~/Videos/Recordings"
else
    GEOM=$(slurp) || exit 1
    FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    echo "$FILE" > "$FILEFILE"
    wf-recorder -g "$GEOM" -f "$FILE" &
    notify-send -i media-record "Recording" "Started — Ctrl+Print to stop"
fi
