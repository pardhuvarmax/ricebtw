#!/usr/bin/env bash
# caelestia theme postHook: rebuild the themed logo, then redraw the focused kitty window (if it is at a bare shell).
# Runs in the background (see ~/.config/caelestia/cli.json), so it never blocks a wallpaper change.
dir="$(dirname "$(readlink -f "$0")")"
"$dir/make-ultron-logo.sh" && "$dir/redraw-focused-kitty.py"
