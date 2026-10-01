#!/usr/bin/env bash
# Toggle a selected screen-region recording. Videos are saved in ~/Videos.
set -euo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
pid_file="$runtime_dir/narexil-region-recorder.pid"

if [[ -f "$pid_file" ]]; then
    recorder_pid="$(<"$pid_file")"
    if kill -0 "$recorder_pid" 2>/dev/null; then
        kill -INT "$recorder_pid"
        notify-send -a "Screen recorder" "Stopping recording"
        exit 0
    fi
    rm -f "$pid_file"
fi

selection="$(slurp 2>/dev/null)" || exit 0
video_dir="$(xdg-user-dir VIDEOS 2>/dev/null || printf '%s/Videos' "$HOME")"
mkdir -p "$video_dir"
output="$video_dir/screen-recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"

wf-recorder -g "$selection" -f "$output" &
recorder_pid=$!
printf '%s' "$recorder_pid" > "$pid_file"
notify-send -a "Screen recorder" "Recording started" "Press Super+R again to stop."

if wait "$recorder_pid"; then
    notify-send -a "Screen recorder" "Recording saved" "$output"
else
    notify-send -a "Screen recorder" "Recording failed" "No video was saved."
fi
rm -f "$pid_file"
