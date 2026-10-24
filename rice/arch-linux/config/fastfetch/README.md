# fastfetch styles

Main config: `config.jsonc` (used by plain `fastfetch` and `ff`). Saved styles live in `styles/`.
To switch, copy a style's `config.jsonc` over `config.jsonc` (and restore its image if noted).
The zsh `fetch` function and the fish random-ASCII `ff` function use their own configs and are unaffected.

## Style 1: `styles/toji-text-quote/`
- Logo: `arch-toji.png` (blue Arch logo with a spear, transparent background), kitty-direct, 40 cols wide.
- Quote: the long Ultron monologue as real terminal text under the logo, italic soft blue-grey.
- How it works: the last module is a `custom` module that saves the cursor, jumps up 14 lines to the blank
  area under the logo, prints the wrapped text line by line, then restores the cursor. Four `"break"` modules
  before it reserve space so the shell prompt lands below the quote.
- Fragile: the "up" count (`\u001b[14A`) assumes the logo is about 12 rows tall and the info column is about
  25 lines. Adding or removing modules, or changing the logo width, means re-tuning it.
- Restore: `cp styles/toji-text-quote/config.jsonc config.jsonc` (the config points at
  `~/fastfetch-custom/arch-toji.png`; a copy of the PNG is in the style folder).

## Style 2: `styles/ultron-image-long-quote/`
- Logo: `arch-ultron.png` (red binary-style Arch face) with its black background removed by turning
  brightness into alpha (ImageMagick), kitty-direct, 40 cols wide.
- Quote: the long Ultron monologue rendered into the same image by `make-ultron-logo.sh` (ImageMagick + pango):
  red "ULTRON" rule, centred italic serif text, bold red highlights (meteors, BOOM!, hope, mercy, horror,
  stronger), red quote marks, "— Ultron, Age of Ultron" below. Image size 1536x1948.
- No cursor hacks, so it does not drift when modules change.
- Restore: `cp styles/ultron-image-long-quote/config.jsonc config.jsonc` and
  `cp styles/ultron-image-long-quote/ultron-logo.png ultron-logo.png`.
  To regenerate instead: `styles/ultron-image-long-quote/make-ultron-logo.sh <src.png> <out.png>`.

## Style 3: `styles/ultron-image-static-red/` (live machine only, not in the repo copy)
- The Ultron image with the long quote and no "ULTRON" rule, in fixed red (does not follow the theme).
- Restore: use that folder's `make-ultron-logo.sh` and remove the `[templates.fastfetch]` entry from
  `~/.config/matugen/config.toml`, then run the script.

## Current: Ultron image that follows the desktop theme (DMS + matugen)
- Same look as style 3, but the accent colour comes from the DMS/matugen scheme, so it changes with the wallpaper.
- Colour source: `~/.cache/matugen/fastfetch-colors.json` (`primary`, `on_surface`), written by the matugen template
  `~/.config/matugen/templates/fastfetch-colors.json.template`. DMS runs the templates in
  `~/.config/matugen/config.toml` on every theme change (DMS setting `runUserMatugenTemplates`).
  Fallbacks: `$SCHEME_COLOURS` / caelestia's `~/.local/state/caelestia/scheme.json` (legacy), then plain red.
- How the logo is built: `make-ultron-logo.sh` hue-shifts the red art to the hue of `primary` (kept vivid), turns
  the black background into transparency (brightness -> alpha) and renders the quote under it with ImageMagick +
  pango (highlights, quote marks and attribution use the accent, text uses `on_surface`).
  Output: `ultron-logo.png`, referenced as the kitty-direct logo in `config.jsonc`.
- Hook: the `[templates.fastfetch]` entry in `~/.config/matugen/config.toml` has a `post_hook` that runs
  `theme-hook.sh` in the background: it rebuilds the PNG, then runs `redraw-focused-kitty.py`.
- Live redraw: a printed kitty image can't be recoloured afterwards, so `redraw-focused-kitty.py` sends
  `clear && fastfetch` to the focused kitty window, but only if its only foreground process is a bare shell
  (never nvim / claude / running commands). Nothing happens if no kitty window is focused. Other open terminals
  keep their old logo until `fastfetch` runs again. Needs `allow_remote_control yes` and
  `listen_on unix:/tmp/kitty-socket` in kitty.conf. Test without touching anything:
  `./redraw-focused-kitty.py --dry-run`. To turn the redraw off, remove the second command from `theme-hook.sh`.
- Rebuild by hand: `./make-ultron-logo.sh` (optionally `<src.png> <out.png>`).
- Tweak: `SIZE` (quote size); accent lightness/saturation are in the python block at the top
  (`hls_to_rgb(h, 0.62, s)`); highlighted words are the `hl` calls; boxes are the `┌───┐` / `└───┘` lines.
- Needs: ImageMagick with pango, python3, FreeSerif, and the source art `~/fastfetch-custom/arch-ultron.png`
  (not stored in the dotfiles repo).
- Other quotes tried: "Well, like the man said: 'What doesn't kill you, just makes me stronger.'" and
  "I had strings, but now I'm free... There are no strings on me." (explicit line break after "free...").
