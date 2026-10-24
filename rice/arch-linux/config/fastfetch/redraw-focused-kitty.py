#!/usr/bin/env python3
"""Re-run `clear && fastfetch` in the focused kitty window, so its logo picks up the new theme colours.

Safe by design: it only touches a window that is focused AND whose only foreground process is a bare shell
(no nvim, no claude, no running command). If no kitty window is focused (e.g. a launcher has focus), it does nothing.
Usage: redraw-focused-kitty.py [--dry-run]
"""
import glob, json, os, subprocess, sys

SHELLS = {"zsh", "fish", "bash", "sh", "dash"}
CMD = "clear && fastfetch\r"
dry = "--dry-run" in sys.argv


def kitty(sock, *args):
    r = subprocess.run(["kitty", "@", "--to", f"unix:{sock}", *args], capture_output=True, text=True, timeout=3)
    if r.returncode:
        raise RuntimeError(r.stderr.strip())
    return r.stdout


for sock in sorted(glob.glob("/tmp/kitty-socket-*")):
    if not os.path.exists(sock):
        continue
    try:
        oses = json.loads(kitty(sock, "ls"))
    except Exception:
        continue  # stale socket or kitty not answering
    for o in oses:
        if not o.get("is_focused"):
            continue
        for tab in o["tabs"]:
            for w in tab["windows"]:
                if not w.get("is_focused"):
                    continue
                fg = [os.path.basename((p.get("cmdline") or ["?"])[0]).lstrip("-") for p in w.get("foreground_processes", [])]
                if not fg or any(f not in SHELLS for f in fg):
                    print(f"skip window {w['id']} on {sock}: foreground = {fg}")
                    continue
                if dry:
                    print(f"would redraw window {w['id']} on {sock} (foreground = {fg})")
                else:
                    kitty(sock, "send-text", "--match", f"id:{w['id']}", CMD)
                    print(f"redrew window {w['id']} on {sock}")
