# Windows-style desktop

Goal: bring Windows' **usability** to Omarchy, not a copy of its look. Josh
started with "the closest thing to Windows" and later refined it: "Not
everything has to look exactly like Windows, just the stuff that makes
Windows actually look better and more usable." A consistent Linux look
(JetBrains Mono everywhere) is preferred over Windows fonts and themes.

Approved by Josh on
2026-09-22 ("let's test it out, can always revert"), on the condition that
every plugin's code be reviewed before installation. Applied by Claude on top
of Codex's [OmaPanel taskbar](../omapanel/README.md). Changes are now tried
one at a time.

## Documents

| Doc | Covers |
| --- | --- |
| [LOG.md](LOG.md) | Dated list of every change, newest first |
| [WINDOWS-AND-SHORTCUTS.md](WINDOWS-AND-SHORTCUTS.md) | Floating windows, focus, snapping, keyboard shortcuts |
| [PLUGINS.md](PLUGINS.md) | Plugin review verdicts, Grabbar operations, Kate/Gwenview/Ark |
| [FILE-MANAGER.md](FILE-MANAGER.md) | Dolphin as the only file manager, right-click actions, Nautilus removal |
| [DICTATION.md](DICTATION.md) | Win+H dictation, live (streaming) Parakeet setup |
| [DESKTOP.md](DESKTOP.md) | Wallpaper, drifting-nebula screensaver, clock with date |
| [TASKBAR.md](TASKBAR.md) | Taskbar size, colour, active-app highlight, tray |
| [NAS.md](NAS.md) | NAS share as a fast mapped drive (kernel SMB automount) |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Lost keyboard focus (hollow cursor); Claude Desktop keyring sign-in |
| [APPEARANCE.md](APPEARANCE.md) | Scaling, theme, icons, title-bar colours, GTK theme (removed), Selawik font (removed), sizes, borders |

Files: [`windows_style.lua`](windows_style.lua) (Hyprland side),
[`plugins.txt`](plugins.txt) (reviewed commits),
[`grabbar-local.patch`](grabbar-local.patch),
[`theme-overlay/`](theme-overlay/), [`dolphin/`](dolphin/), [`dictation/`](dictation/),
[`desktop-icons-dolphin.patch`](desktop-icons-dolphin.patch),
[`desktop-icons-sizes.patch`](desktop-icons-sizes.patch),
[`quick-settings-local.patch`](quick-settings-local.patch), [`app-launcher-local.patch`](app-launcher-local.patch), [`screensaver/`](screensaver/), [`shell.toml`](shell.toml), [`install.sh`](install.sh),
[`installed-2026-09-22.txt`](installed-2026-09-22.txt),
[`removed-nautilus-2026-09-22.txt`](removed-nautilus-2026-09-22.txt).

## Current state

- **Windows:** floating and centred; click to focus; focused windows come to
  the front; Grabbar title bars with minimize/maximize/close (slate #253040
  focused, #1C1C1C unfocused; loaded at login); 1px borders in the title-bar colours; 8px rounded corners; no
  transparency.
- **Keyboard:** Windows shortcuts (Win+E/D/L/V/./I/H/N/A, Win+Arrows snap,
  Win+Tab Task View, Alt+Tab, Alt+F4, Ctrl+Shift+Esc); Ctrl+Alt+Del no longer
  closes every window. Full table in
  [WINDOWS-AND-SHORTCUTS.md](WINDOWS-AND-SHORTCUTS.md).
- **Taskbar (42px, #161616):** Start button (App Launcher, coloured app grid), workspace numbers, OmaPanel
  app icons with previews and a slate highlight on the active app, tray,
  Grabbar drawer, agents, volume, battery, Quick Settings, clock with date,
  notification bell.
- **Look:** 160% scaling, Vantablack (true black for the OLED), Fluent-dark
  icons, JetBrains Mono 9pt everywhere; desktop icons 48px; Dolphin icons
  48px (22px in Details since 2026-09-22, 16px in Compact).
- **Apps:** Dolphin is the only file manager (new windows, no tab restore,
  LocalSend/Transcode right-click actions); Kate and Ark as defaults; Loupe for images since 2026-09-22 (Gwenview kept).
- **Dictation:** Win+H, live text (Parakeet streaming).
- **NAS:** three SMB shares from a home NAS mounted on demand under
  `/mnt/nas/`, each with a Dolphin sidebar place.
- **Desktop:** Dark Waters wallpaper; drifting nebula screensaver; clock
  shows time over date (12-hour).

## Decided against

Fluent GTK theme (not noticeable), Selawik font (colour fringing on the
OLED), tray overflow plugin (built-in tray already pins/hides), drag-to-edge
snapping (not used), KDE Open/Save dialogs (57 Plasma packages). Details in
the topic docs and [LOG.md](LOG.md).

## Repeat on another machine

```bash
~/omarchy-setup/setup/windows-style/install.sh
```

The script checks plugins out at the reviewed commits rather than the latest
upstream, backs up each home-directory file (including `~/.bash_profile`)
before changing it, and is safe to run again: each step checks whether it is
already done. All its patches were checked to apply cleanly to the pinned
upstream commits and to be skipped on a second run. It has not yet been run
end to end on a second Omarchy machine.

## Undo everything

1. Remove the `require("hypr.windows_style")` line from
   `~/.config/hypr/hyprland.lua` and run `hyprctl reload`.
2. Remove plugins and apps as in [PLUGINS.md](PLUGINS.md#undo).
3. Revert appearance as in [APPEARANCE.md](APPEARANCE.md).
