#!/usr/bin/env bash
# Builds ultron-logo.png: arch-ultron.png with its black background made transparent,
# plus a styled Ultron quote underneath. Re-run after editing the quote or colours.
set -euo pipefail

SRC="${1:-$HOME/fastfetch-custom/arch-ultron.png}"
OUT="${2:-$HOME/.config/fastfetch/ultron-logo.png}"
W=1536                                   # canvas width (px); fastfetch scales it to the logo width
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

RED="#ff3b3b"; DIMRED="#7a1d24"; TEXT="#c9ccd6"
SERIF="FreeSerif"; SANS="FreeSans"
SIZE=42                                  # quote font size (px on the canvas); smaller = smaller quote

# 1. logo: brightness -> alpha, so the black background disappears and the glow fades out
magick "$SRC" -alpha off \( +clone -colorspace Gray -level 4%,45% \) \
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
magick -background none -fill "#b0323a" -font "$SERIF-Italic" -pointsize 34 -kerning 3 label:"— Ultron, Age of Ultron" "$TMP/attr.png"

# 4. stack everything on one transparent canvas
magick -background none -gravity center \
    "$TMP/logo.png" \( -size 1x24 xc:none \) \
    "$TMP/quote.png" \( -size 1x14 xc:none \) "$TMP/attr.png" \
    -background none -extent ${W}x -append "$OUT"
echo "wrote $OUT ($(magick identify -format '%wx%h' "$OUT"))"
