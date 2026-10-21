#!/usr/bin/env bash
# Types the current clipboard contents as synthetic keystrokes (via wtype)
# instead of sending a paste event. Bypasses onpaste-blocking form fields
# since the target sees real key events, same as manual typing.
#
# Locks keyboard focus to the window that was active when the hotkey fired:
# disables focus-follows-mouse and re-asserts focus on that window every
# 100ms for the whole typing duration, so cursor drift, alt-tabbing, or a
# notification stealing focus mid-type can't redirect the keystrokes.
#
# Note: this pins the WINDOW, not an in-app browser tab. Switching tabs
# inside the same window (Ctrl+Tab, clicking a tab) is invisible to the
# compositor and can't be intercepted here.

target=$(hyprctl activewindow -j | jq -r '.address // empty')
orig_follow_mouse=$(hyprctl getoption input:follow_mouse -j | jq -r '.int')

pin_pid=""

restore() {
    [ -n "$pin_pid" ] && kill "$pin_pid" 2>/dev/null
    hyprctl eval "hl.config({ input = { follow_mouse = $orig_follow_mouse } })" >/dev/null
}
trap restore EXIT

hyprctl eval 'hl.config({ input = { follow_mouse = 0 } })' >/dev/null

if [ -n "$target" ]; then
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$target\" })" >/dev/null
    (
        while true; do
            hyprctl dispatch "hl.dsp.focus({ window = \"address:$target\" })" >/dev/null 2>&1
            sleep 0.1
        done
    ) &
    pin_pid=$!
fi

wl-paste -n | wtype -d 8 -
