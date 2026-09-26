# Taskbar

Josh shared Windows 11 taskbar screenshots (via the NAS; not in this repo).
Measured there: background
#1C1C1C with a faint lighter top edge; 48px tall at 100% scaling; 24px icons;
a grey dash under running apps; the active app gets a rounded highlight box
and an accent-coloured dash.

## Applied (2026-09-22)

- **Size and colour:** [`shell.toml`](shell.toml) → `~/.config/omarchy/shell.toml`
  `[bar]`: first 48px / #1C1C1C (Windows' values), then at Josh's request
  "a little shorter and slightly darker": **`size-horizontal = 42`**,
  **`background = "#161616"`** (was 34, Omarchy 26). The bar had also been set to transparent at some
  point between 09:06 and 12:16 (not by Claude; not in the repo); turned off
  with `omarchy bar transparent false` so the grey shows. Measured #161616, reserved height 42px.
- **Active-app highlight** (OmaPanel settings in `shell.json`):
  `activeBackgroundColor #253040` (the focused title-bar slate),
  `activeIndicator Underline`, `indicatorColor #6f95c8`, `indicatorLength 16`,
  `indicatorThickness 3`, `indicatorMargin 3`, `itemCornerRadius 6`,
  `hoverBackgroundColor #2a2a2a`, `itemHorizontalPadding 10`, `itemSpacing 4`.
  Open-but-inactive apps (including minimized ones) now get a short grey
  dash (#8a8a8a, 6px), like Windows, so they differ from pinned apps that are
  closed; see "Running-app dash" below.
- **Tray:** at Josh's request removed `omarchy.bluetooth`, `omarchy.network`,
  and `omarchy.monitor` from the bar (Quick Settings covers them). Right
  section now: tray, Grabbar drawer, agents, audio, power, Quick Settings,
  clock, notification bell.
- Workspace numbers kept (Task View button declined).

## Running-app dash

Josh: a minimized Chromium looked exactly like a closed pinned app. OmaPanel
only drew its indicator for the active window, although it already tracks
`isClosedPinned`. Local patch
[`omapanel-running-dash.patch`](omapanel-running-dash.patch): the indicator is
also shown, as a 6px grey dash, when the app is open but not active. OmaPanel
loads a generated bundle (`BarWidget.qml`, built by `scripts/bundle-qml.py`
from `src/` and `taskbar/*.inc`), so the edit is in both the bundle and
`taskbar/AppChipVisuals.inc`. Verified by screenshot after a shell restart:
grey dashes under Chromium (minimized), Dolphin, and both terminals; none
under closed pins (Firefox, Brave, Helium, Chrome Beta); the active app keeps
the slate box and blue line. Re-apply after `omarchy plugin update`.

## App-name tooltips

Josh (2026-09-24): hovering a pinned app that isn't open should show its name,
like Windows. Open apps already show a window preview instead.

OmaPanel already asked the bar for a tooltip ("Firefox / Click to open"),
but it never appeared. Omarchy 4's bar only shows a tooltip while the target
reports `tooltipHovered`. `WidgetButton` ties that to its own mouse area,
and OmaPanel turns that area off (`interactive: false`) in favour of its own
area, so the answer was always false. Local patch
[`omapanel-tooltips.patch`](omapanel-tooltips.patch), applied after the
running-dash patch:

- The chip reports its own hover as `tooltipHovered`.
- The tooltip is just the app name, with no "Click to open" line.
- Moving from an open app's preview onto a closed pin closes the preview and
  shows the name at once. Before, the lingering preview blocked the tooltip.

The edits are in both the bundle (`BarWidget.qml`) and the sources
(`src/preview.inc`, `taskbar/AppChipProperties.inc`). The bundler can't be
re-run here because this machine's `qmlformat` gives different output from
upstream's. Verified after a shell restart: hovering Firefox shows "Firefox";
moving the pointer from Chromium's preview onto Firefox swaps the preview for
the tooltip. `hyprctl` cursor warps don't send motion within the bar, so that
test used a temporary uinput mouse. Re-apply after `omarchy plugin update`.
Undo: `git -C ~/.config/omarchy/plugins/atagulalan.omapanel apply -R
omapanel-tooltips.patch`, then `omarchy restart shell`.

## Hidden tray items behind an arrow: not possible on 4.0.4

Josh asked for the removed Bluetooth, network, and display items behind an
arrow, like Windows' "^". Reviewed `io.github.tyrichards.tray` 1.9.3
(`c1590d8`, safe): it can host other bar widgets in its drawer only with the
full internal bar, but Omarchy 4.0.4 gives third-party widgets a restricted
`PluginBarApi` facade (`Bar.qml` 1999–2004) without `barWidgetRegistry`, drag
state, or config mutation, so hosted widgets would render as nothing. The
same restriction broke Grabbar's widget (see PLUGINS.md). `so.den` works
around it through an unsupported internal bridge. Josh chose **Quick
Settings** instead: Win+A or its taskbar button already has Wi-Fi, Bluetooth,
and display tiles that open the same Omarchy panels. Nothing installed.

Undo: restore `~/.config/omarchy/shell.json` from its latest `.bak.<epoch>`
and set `size-horizontal = 34` (or delete `shell.toml`).

## Flameshot (Lightshot-style screenshots)

Josh asked for something like Lightshot: a tray icon, drag a region, annotate
in place. Installed **Flameshot 14.0.0** (`extra`, no extra dependencies)
with `pkexec pacman -S flameshot`.

- Config [`flameshot/flameshot.ini`](flameshot/flameshot.ini) →
  `~/.config/flameshot/flameshot.ini`: slate UI colours (#6f95c8 / #253040),
  no startup message, tray icon on. Flameshot 14 has no `useGrimAdapter`
  key; it handles Wayland itself.
- Tray: its item id is `flameshot`; pinned in the stock tray
  (`"pinned": ["flameshot"]` on the `omarchy.tray` entry in `shell.json`) so
  it shows next to the clock instead of behind the tray arrow.
- Autostart: `o.launch_on_start("flameshot")` appended to
  `~/.config/hypr/autostart.lua` (backup `.bak.<epoch>`).
- First capture shows the desktop portal's "Allow Apps to Take
  Screenshots?" prompt; Josh answers it (one-time permission).
- Omarchy's own screenshot keys (Print Screen, Win+Shift+S) are unchanged.
- Still to verify: capture alignment at 160% scaling (known Flameshot issue
  area on Wayland).
- Undo: `sudo pacman -Rns flameshot`, remove the autostart line and the
  `pinned` entry, `rm -r ~/.config/flameshot`.
