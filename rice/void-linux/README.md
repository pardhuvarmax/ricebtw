# Void Linux rice (MangoWC + DankMaterialShell)

Saved 2026-10-21 from the Void install.

- `wm/`            the wm repo (mango config, fontconfig, rofi, etc.). Mango config: wm/config/mango/config.conf
- `home/`          ~/.bashrc, ~/.aliases (xbps/runit versions), ~/.face
- `config/`        ~/.config copies: dms, fastfetch, kitty, nvim, fuzzel, swayosd, flameshot, spotify, variety, codium-insiders (settings + extensions.txt)
- `bin/`           ~/.local/bin wrappers for the Flatpaks (zen-browser, spotify, code-insiders)
- `etc-xbps.d/`    DMS repository files for /etc/xbps.d
- `packages/`      xbps-manual.txt (manually installed packages), flatpak.txt

Notes
- Shell: DMS (`dms run` in mango autostart). mangobar, mako, variety, wm theme engine and wallpaper-manager are disabled.
- wm/config/themes/theme-engine.py no longer calls update_fastfetch().
- Wallpapers live in ../../../Pictures/wallpapers (not duplicated here).
- Mango keys: caelestia binds were mapped to `dms ipc call ...`.
