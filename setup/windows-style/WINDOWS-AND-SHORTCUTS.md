# Window behaviour and shortcuts

All of this lives in [`windows_style.lua`](windows_style.lua), copied to
`~/.config/hypr/windows_style.lua` and loaded by one line at the end of
`~/.config/hypr/hyprland.lua`. Keep the two copies identical.

## Window behaviour

- New windows open **floating and centred** instead of tiled; sizes are
  remembered per app. Windows open before the change stay tiled until reopened.
- **Click to focus** (`input.follow_mouse = 2`); scrolling still reaches the
  window under the cursor, as on Windows 10/11.
- **Resize by dragging edges** (`general.resize_on_border`) and **edge
  snapping** of floating windows (`general.snap.enabled`).
- **Focusing a window raises it.** Clicking an app on the taskbar focused it
  without bringing it to the front (OmaPanel dispatches `hl.dsp.focus`,
  which does not change stacking order for floating windows). A
  `window.active` handler now calls `alter_zorder({ mode = "top" })` on every
  focused floating window, so the taskbar, Alt+Tab, and notifications all
  raise the window. Verified by focusing Chromium through the same dispatch
  and taking a screenshot.
- **Browsers float.** Omarchy tags Chromium-based browsers and sets
  `tile = true`, which beat the float-everything rule: Chrome opened
  full-size and tiled, behind every floating window. A later rule sets
  `{ tile = false, float = true, center = true }` for that tag. Verified:
  Chrome relaunches floating and centred at its remembered size.
- **Windows-style maximize.** Hyprland's maximized state is drawn beneath
  floating windows. A `window.fullscreen` handler turns any maximize (Grabbar's
  button, Win+Up) into a floating window filling the work area, stacked
  normally, and a second request restores the earlier size (a window that
  opened maximized gets a centred 70% size). Real fullscreen (state 2, e.g.
  Super+F or video) is untouched. Verified on Chrome: maximize → 1800×1076 at
  0,0 still floating; again → back to 1190×710.
- App maximize requests stay suppressed (Omarchy's `suppress_event =
  "maximize"`); an earlier override that allowed them was removed, since
  Chrome's request to start maximized contributed to the problem.
- **No transparency.** Omarchy draws windows at 98.5% (focused) / 96%
  (unfocused) opacity; a `.*` rule sets every window to `1.0 override`, so
  Super+Backspace (Omarchy's transparency toggle) no longer has an effect.
  Verified with `hyprctl getprop … opacity` on every open window.
- Title-bar colours for Grabbar are also set here; see
  [APPEARANCE.md](APPEARANCE.md#title-bar-colours).

## Keyboard shortcuts

Defaults they replace are in brackets.

| Keys | Action |
| --- | --- |
| Win (tap alone) | Start menu (App Launcher) |
| Win+E | Dolphin, new window |
| Super+Shift+F / +Alt | Dolphin / Dolphin in the terminal's folder [Nautilus] |
| Win+D | Show desktop: jump to an empty workspace, press again to return |
| Win+Left / Right | Snap window to the left / right half |
| Win+Up / Down | Maximize / restore (Down also undoes a snap) [focus by direction] |
| Win+Tab | Task View (Omascape) [next workspace] |
| Win+Ctrl+Left / Right | Previous / next desktop [grouped-window focus] |
| Alt+Tab | Windows-style switcher, hold Alt, most recent first [cycle windows] |
| Alt+F4 | Close window (Win+W still works) |
| Win+L | Lock [workspace layout toggle, now Win+Ctrl+Alt+L] |
| Win+Shift+S | Screenshot [Google Maps web app] |
| Win+V | Clipboard history [universal paste] |
| Win+. | Emoji picker |
| Win+N | Notification center (Action Center) |
| Win+A | Quick Settings |
| Win+H | Dictation on/off (voxtype; Win+Ctrl+X and hold-F9 still work) |
| Win+I | Omarchy settings menu |
| Ctrl+Shift+Esc | Task manager (btop) |
| Ctrl+Alt+Del | System menu [**closed all windows without asking**] |

Snapping computes the work area from the monitor's size, scale, and reserved
space (the taskbar), so it follows scaling changes. Win+D never moves
windows, so nothing can be stranded if the config reloads.

## Keep this file safe for Omarchy's keybindings menu

`omarchy menu keybindings` (and the Win+K cheat sheet) runs this config in a
stand-in Lua environment where every unknown `hl` function returns a
placeholder that always yields another value. A `for … in ipairs(
hl.get_loaded_plugins())` loop therefore never ended and the menu hung. The
Grabbar check now uses a counted loop (`for i = 1, #plugins`). Avoid
`ipairs`/`pairs` over values returned by `hl.*` calls in this file.

## Undo

Remove the `require("hypr.windows_style")` line from
`~/.config/hypr/hyprland.lua` (or restore
`~/.config/hypr/hyprland.lua.bak.1790103995`), then `hyprctl reload`. This
returns tiling and Omarchy's keys, and stops loading the Alt+Tab plugin.
