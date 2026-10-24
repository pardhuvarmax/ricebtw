#!/usr/bin/env bash
# Builds ultron-logo.png: arch-ultron.png with its black background made transparent, recoloured to the
# desktop theme (caelestia scheme), plus a styled Ultron quote underneath.
# Colours come from ~/.cache/matugen/fastfetch-colors.json (written by a matugen template on every DMS theme change),
# else the legacy caelestia scheme; with neither it falls back to the original red. Re-run after editing the quote or colours.
set -euo pipefail

SRC="${1:-$HOME/fastfetch-custom/arch-ultron.png}"
OUT="${2:-$HOME/.config/fastfetch/ultron-logo.png}"
W=1536                                   # canvas width (px); fastfetch scales it to the logo width
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
SERIF="FreeSerif"
SIZE=42                                  # quote font size (px on the canvas); smaller = smaller quote

# 0. theme colours: accent = hue of scheme "primary" (vivid), text = "onSurface", dim = darker accent
read -r RED DIMRED TEXT HUEARG < <(python3 - <<'PY'
import colorsys, json, os
def load():
    # 1. DMS/matugen template output (~/.config/matugen/templates/fastfetch-colors.json.template)
    try:
        d = json.load(open(os.path.expanduser("~/.cache/matugen/fastfetch-colors.json")))
        return {"primary": d["primary"], "onSurface": d["on_surface"]}
    except Exception:
        pass
    # 2. legacy caelestia hook / scheme file
    try:
        return json.loads(os.environ["SCHEME_COLOURS"])
    except Exception:
        pass
    try:
        return json.load(open(os.path.expanduser("~/.local/state/caelestia/scheme.json")))["colours"]
    except Exception:
        return {}
cols = load()
def rgb(h): h = h.lstrip("#"); return tuple(int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
def hexc(r, g, b): return "#%02x%02x%02x" % tuple(round(c * 255) for c in (r, g, b))
if "primary" in cols:
    h, l, s = colorsys.rgb_to_hls(*rgb(cols["primary"]))
    s = max(s, 0.7)
    accent = hexc(*colorsys.hls_to_rgb(h, 0.62, s))
    dim = hexc(*colorsys.hls_to_rgb(h, 0.42, max(s, 0.55)))
    deg = h * 360
else:
    accent, dim, deg = "#ff3b3b", "#b0323a", 0
text = "#" + cols["onSurface"].lstrip("#") if "onSurface" in cols else "#c9ccd6"
deg = deg - 360 if deg > 180 else deg
print(accent, dim, text, "%.2f" % (100 + deg * 100 / 180))   # IM -modulate hue: 100 = unchanged
PY
)

# 1. logo: hue-shift the red to the accent hue; brightness -> alpha so the black background disappears
magick "$SRC" -alpha off -modulate 100,100,"$HUEARG" \
    \( "$SRC" -alpha off -colorspace Gray -level 4%,45% \) \
    -compose CopyOpacity -composite "$TMP/logo.png"

# 2. quote (pango markup so single words can be coloured)
hl() { printf '<span foreground="%s" weight="bold">%s</span>' "$RED" "$1"; }
Q="I wasn't sure you'd wake up. I hoped you would. I wanted to show you...I don't have anyone else. "
Q+="I think a lot about $(hl meteors)...the purity of them. $(hl 'BOOM!') The end. Start again. "
Q+="The world made clean for the new man to rebuild. I was meant to be new. I was meant to be beautiful. "
Q+="The world would have looked to the sky and seen $(hl hope)...seen $(hl mercy). "
Q+="Instead, they will look up in $(hl horror) because of you. You've wounded me. "
Q+="I give you full marks for that. Well, like the man said: 'What doesn't kill you, just makes me $(hl stronger).'"
MARK() { printf '<span foreground="%s" size="%s" font_family="%s" weight="bold">%s</span>' "$RED" "$1" "$SERIF" "$2"; }
MARKUP="$(MARK 180% '“')<span foreground=\"$TEXT\" font_family=\"$SERIF\" style=\"italic\" line_height=\"1.32\">$Q</span>$(MARK 180% '”')"
magick -background none -size $((W-200))x -gravity center -define pango:align=center \
    -pointsize "$SIZE" pango:"<span size=\"${SIZE}pt\">$MARKUP</span>" "$TMP/quote.png"

# 3. attribution
magick -background none -fill "$DIMRED" -font "$SERIF-Italic" -pointsize 34 -kerning 3 label:"— Ultron, Age of Ultron" "$TMP/attr.png"

# 4. stack everything on one transparent canvas (written atomically so fastfetch never reads a half-written file)
magick -background none -gravity center \
    "$TMP/logo.png" \( -size 1x24 xc:none \) \
    "$TMP/quote.png" \( -size 1x14 xc:none \) "$TMP/attr.png" \
    -background none -extent ${W}x -append "$TMP/out.png"
mv -f "$TMP/out.png" "$OUT"
echo "wrote $OUT ($(magick identify -format '%wx%h' "$OUT")) accent=$RED text=$TEXT hue-arg=$HUEARG"
