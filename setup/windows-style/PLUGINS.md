# Plugins and apps

Each plugin is pinned to a commit whose full source was read before
installation ([`plugins.txt`](plugins.txt)). `omarchy plugin add` and
`omarchy plugin update` fetch the latest upstream code, so re-review any newer
commit before updating.

| Plugin | Role | Review verdict |
| --- | --- | --- |
| App Launcher (tyrsolution) | **Start menu** since 2026-09-22: coloured app grid, coding agents, session/window toggles, Omarchy system menu as folders, power. First in the bar's left section; Win tap. | Safe (no network; .desktop contents never reach a shell; launches via the stock AppLibrary). Agent tiles start agents with their approval prompts off, as `omarchy-agent` does; "Remove from launcher" can run `sudo pacman -Rns` in a visible terminal. Opens as a centred card over a dimmed screen, not anchored to the button. Needed a local fix, see below. |
| Simple Start Menu | Former Start button (**disabled** 2026-09-22, still installed) | Concerns: pin/unpin writes app IDs through an unquoted shell string (`Panel.qml:118-120`); exploitable only by something that can already write your home folder. No network, no sudo. |
| Alt-tab switcher (altswitch) | Windows-style Alt+Tab | Safe. Lua half loaded from `windows_style.lua` with a guard. |
| Omascape | Task View on Win+Tab | Safe. Idle hooks and file watchers run while the shell is up. |
| Desktop Icons | Icons from `~/Desktop` on the wallpaper | Concerns: a `.desktop` file with the executable bit runs when opened (don't extract archives onto the desktop); polls with python every 1.5 s; bottom row may sit under the taskbar; "Show in Files" and "Open Trash" patched to open Dolphin ([patch](desktop-icons-dolphin.patch)). Replaces Omarchy's wallpaper double-click menus. Local patch: takes the keyboard only while renaming or a menu is open ([patch](desktop-icons-keyboard.patch)). Local patch (2026-09-25): single click selects, double-click opens, like Windows; upstream opened on every click, so a double-click opened a file twice ([patch](desktop-icons-doubleclick.patch)). |
| Notification Center (jankeesvw) | Action Center: bell at the far right of the taskbar, panel of the last 30 days of notifications, Win+N | Minor concerns: notification text never reaches a shell (plain text, `jq --arg`, the sender's click command is discarded; clicks only open image files or focus an app with a safe name). Clearing/pruning also deletes Omarchy's own history files, so Super+Shift+Alt+comma shows fewer entries. Screenshot-style images pass through ImageMagick. Keeps notifications (including 2FA codes and chat text) in `~/.local/state/omarchy-notification-center/` (0700) for 30 days / 1000 entries; a `bash`+`inotifywait` watcher and a 10 s poll run all the time. Do Not Disturb is Omarchy's own (right-click the bell, or Super+Ctrl+comma). |
| Quick Settings (aryal.control-center) | Windows 11-style Quick Settings grid (Win+A, taskbar button before the clock) | Concerns, addressed locally: its hover corners (full-screen overlay, top-left/top-right 12px squares) swallowed clicks, fired over fullscreen apps, and the top-right one opened a duplicate notification panel; **disabled** by [`quick-settings-local.patch`](quick-settings-local.patch). It runs commands listed in any plugin's `control-center.json` (none ship one here). Weather via Omarchy's own `omarchy-weather-status` (wttr.in sees IP/city). No injection from SSIDs or Bluetooth names; power actions confirm. Polls every 0.4 s only while open. |
| Grabbar | Minimize / maximize / close title bars, minimized-window drawer | Safe code, but a **preview** release with a native Hyprland plugin: a crash takes Hyprland down. Loaded at login through its guarded autoload (see below). |

The Omarchy menu button was removed from the taskbar (the Start button
replaces it); Super+Space still opens the Omarchy menu. The taskbar itself is
OmaPanel, set up by Codex: see [../omapanel/README.md](../omapanel/README.md).

## Action Center (notification center)

Josh asked for the Action Center next. Omarchy's own notification history
keeps only the last 10 and replays them as toasts (no panel), so a panel
plugin was chosen: `jankeesvw.notification-center` 1.1.0 (63★, unverified in
the marketplace), commit `e4c4568`, source read in full before installing. It
sits on Omarchy's notification service instead of replacing it (unlike
`njpatel.omapager`).

- Enabled at the end of the bar's right section, after the clock (the panel
  always opens against the right edge; keeping it last also leaves Omarchy's
  Super+Ctrl+1–9 panel numbering unchanged).
- Win+N (`omarchy-shell shell toggle jankeesvw.notification-center`) in
  `windows_style.lua`.
- Verified: a `notify-send` test was archived; Win+N's command opened the
  panel at the bottom right above the bell and closed it again (no stray
  keyboard panel left open). Omarchy's recent history was imported on first
  run.
- Quick Settings (Windows' Win+A: Wi-Fi, Bluetooth, volume, brightness in one
  pop-up) is not included; the bar's separate network, Bluetooth, and audio
  panels cover it for now.

## Quick Settings (Win+A)

Josh asked for a Quick Settings pop-up. Candidates: `aryal.control-center`
(4×4 toggles and sliders, closest to Windows 11), `marco.omarchy-info`
(at-a-glance dashboard), `io.github.edgeiq-labs.omarchy-control-center`
(macOS-style, toggles only). Chose aryal, commit `bddd51b`, all code read
first.

Local changes ([`quick-settings-local.patch`](quick-settings-local.patch);
re-apply after any update):

- Hover corners disabled (`Variants { model: [] … EdgeSummon }` in
  `Panel.qml`); there is no setting for this.
- `control-center.json`: Files tile opens Dolphin (it required Nautilus,
  which is uninstalled); Settings opens the Omarchy menu (it required GNOME
  Settings / systemsettings); Monitor opens btop through
  `omarchy-launch-tui`. The JSON was re-saved, so the diff also contains
  formatting changes.

Placement: right section, just before the clock. Win+A:
`omarchy-shell shell toggle aryal.control-center`.

Verified: the corner overlay layers are gone; Win+A's command opened the
panel (Volume, Brightness, Wi-Fi, Bluetooth, Airplane, Night Light, Dark
Mode, Silence, Stay awake, Battery saver, Microphone, Screenshot, Terminal,
Files; time, weather, battery, power) and closing left no keyboard panel open.

Known quirks from the review: Night Light flips rather than setting on/off
and can drift out of step; Silence reads a flag file rather than Omarchy's
Do Not Disturb (unverified); Battery saver off switches to `performance`, not
`balanced`; Dark Mode only changes the GTK colour-scheme setting (reset with
`gsettings reset org.gnome.desktop.interface color-scheme`).

## Considered and skipped: tray overflow

Josh wanted a Windows-style "^" overflow for tray icons. Findings
(2026-09-22):

- Omarchy's built-in tray (`omarchy.tray`,
  `/usr/share/omarchy/shell/plugins/bar/widgets/Tray.qml`) already sorts each
  tray icon into pinned (always shown), drawer (behind an expand arrow; the
  default), or hidden, saved in `shell.json`. It slides open along the bar
  rather than popping up a panel.
- The tray was empty: `RegisteredStatusNotifierItems` reported 0 items.
- `so.den` (Den 1.3.0, unverified, 5★, commit `1e6691e`) is a Windows-style
  flyout that also tucks away bar widgets, but its README says it reaches the
  bar through an unsupported internal bridge that future Omarchy releases may
  break; about 2,500 lines of QML, not reviewed.
- Decision: skip; keep the built-in tray and revisit Den if the bar gets
  cluttered.

## Start menu with coloured icons

Josh liked Simple Start Menu but found it monochrome (its sections mirror the
Omarchy menu with font glyphs). From a contact sheet of five launchers with
real app icons he chose **tyrsolution.app-launcher** 0.4.0 (marked verified,
commit `26d0800`, source read in full first).

- Enabled first in the left section; `simple-start-menu` disabled (`omarchy
  plugin disable`, kept installed). Win tap now runs
  `omarchy-shell shell toggle tyrsolution.app-launcher '{}'`
  (`windows_style.lua`).
- **Empty grid fix** ([`app-launcher-local.patch`](app-launcher-local.patch)):
  Omarchy 4.0.4 hands its shared `AppLibrary` only to plugins of kind
  `menu`, and even after adding that kind the grid stayed empty (the value was
  null at runtime; rebuilding a plugin's shell API destroys the app-library
  object). The launcher now falls back to its own instance of the same stock
  component (`import qs.services` + `AppLibrary {}`). The manifest is
  unchanged.
- Verified: after `omarchy-restart-shell`, the Win-tap command opened the
  card with 48 apps and 9 agents in colour (Fluent icons); Esc closed it and
  no launcher or keyboard-panel layer remained.
- Undo: `omarchy plugin enable io.github.librael-the-culprit.simple-start-menu
  --section left --index 0`, `omarchy plugin remove tyrsolution.app-launcher`,
  and restore the old Win-tap line.

## Grabbar: minimize was disabled (fixed)

Josh couldn't minimize any window. `grabbar status` showed `minimize
disabled` with `restoreHost: false`: Grabbar only allows minimizing once
something that can bring windows back (its bar widget) registers as a
"restore host". Omarchy 4 gives this bar widget a restricted shell API from
`pluginShellForBarEntry` in `shell.qml`, which has no service lookup, so
`bar.shell.serviceFor()` always returns null and the widget never registers
(a retry loop confirmed it stays null). It had worked in the morning only
because the plugin was first added to a running shell.

Local fix in `Service.qml` ([`grabbar-local.patch`](grabbar-local.patch)):
the service registers itself as a restore host (`service-fallback`) at
start. Minimized windows remain recoverable: the drawer (`grabbar`, IPC
`openDrawer`), `grabbar restore-all`, and clicking the app on the taskbar
(OmaPanel shows hidden windows; focusing one makes Grabbar restore it).
Verified after a shell restart: `minimizeEnabled: true`; minimizing Dolphin
moved it to `special:grabbar-minimized`, and both `grabbar restore` and a
taskbar-style focus brought it back to workspace 1.

## Grabbar operations

The title bars come from a compiled Hyprland plugin. To load it by hand (for
example after `grabbar autoload retry`), then apply the blue colours:

```bash
hyprctl plugin load ~/.config/omarchy/plugins/tech.greyforge.grabbar/native/grabbar/grabbar.so && hyprctl reload
```

Rebuild after every Hyprland update (restore minimized windows first):

```bash
~/.config/omarchy/plugins/tech.greyforge.grabbar/bin/grabbar restore-all
make -C ~/.config/omarchy/plugins/tech.greyforge.grabbar/native/grabbar CXX=g++
```

**Loaded at login** since 2026-09-22 (Josh: "add grabbar to login").
`grabbar autoload enable` appended a guarded loader block to
`~/.config/hypr/hyprland.lua` (backup `hyprland.lua.bak.20260922-121343`):
`pcall(dofile, …/native/autoload.lua)`. That loader:

- only declares the plugin (`hl.plugin.load`); Hyprland loads it after the
  config pass and reloads, so the blue title-bar colours in
  `windows_style.lua` apply on the second pass even though the block comes
  after it;
- is guarded: it records each session in
  `~/.local/state/grabbar/autoload/last-attempt`, and the plugin writes
  `last-ok` once it has run for 15 s. If the previous session never reached
  `last-ok`, the next login skips loading and shows a notification; clear it
  with `grabbar autoload retry`.

Verified after `hyprctl reload`: no config errors, plugin still loaded,
`bar_color` still `0xff005fb8`, `last-attempt` = `last-ok` = current
session, and the Win+K keybindings menu still opens.

If a login ever comes up black: switch to a TTY (Ctrl+Alt+F3), log in, and
delete the `BEGIN/END tech.greyforge.grabbar autoload` block from
`~/.config/hypr/hyprland.lua` (or run `grabbar autoload disable`).

The plugin's local copy carries
[`grabbar-local.patch`](grabbar-local.patch); see
[APPEARANCE.md](APPEARANCE.md#title-bar-colours). Re-apply it after any
Grabbar update.

## Apps

Kate (Notepad), Gwenview (Photos), and Ark ("Extract here" in Dolphin's
right-click menu), 26.08.0-1 from `extra`. Kate and Gwenview are the defaults
for text and image files. Everything installed, including dependencies, is in
[`installed-2026-09-22.txt`](installed-2026-09-22.txt).

## Undo

Remove the `windows_style.lua` require first (altswitch is loaded from it),
then:

```bash
~/.config/omarchy/plugins/tech.greyforge.grabbar/bin/grabbar uninstall
omarchy plugin remove io.github.librael-the-culprit.simple-start-menu --yes
omarchy plugin remove io.github.pablo-merino.altswitch --yes
omarchy plugin remove se.mindfulstack.omascape --yes && hyprctl reload
omarchy plugin remove henri.desktop-icons --yes
omarchy plugin remove jankeesvw.notification-center --yes
omarchy plugin remove aryal.control-center --yes
rm -f ~/.config/omarchy/state/control-center-config.json
rm -rf ~/.local/state/omarchy-notification-center   # stored notifications
```

Leftovers: `~/.local/state/grabbar/`, `~/.local/state/omarchy/startmenu/`,
`~/.config/omarchy/omascape*.json`, `~/.config/omarchy/desktop-icon-positions.json`.

Restore the taskbar layout and default apps from
`~/.config/omarchy/shell.json.bak.1790103995` and
`~/.config/mimeapps.list.bak.1790103995`. Remove the apps with
`sudo pacman -Rns kate gwenview ark`.
