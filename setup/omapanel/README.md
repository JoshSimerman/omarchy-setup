# Bottom taskbar — OmaPanel

Explicitly approved by Josh on 2026-09-22 after discussing the proposed changes.
Installed [OmaPanel](https://github.com/atagulalan/omapanel), version 1.11.0,
commit `550e7bba31512478dddbc6644accd971f6514820`.

## Applied

- Moved the existing Omarchy bar to the bottom.
- At Josh's subsequent request, moved the clock to the far-right end with
  `omarchy bar move omarchy.clock --section right --index 99`. Saved the previous
  layout to `~/.local/state/omarchy-setup/shell-before-clock-right.json`.
- Enabled `atagulalan.omapanel` in the left section, preserving other widgets.
- Pinned Chromium, Dolphin, and Foot (the installed terminal).
- Enabled live hover previews, 24-pixel app icons, and icon-only buttons.
- Disabled grouping by workspace; open windows appear in the taskbar.
- Window floating/tiling behavior was not changed; that needs a separate discussion.

Click an icon to launch/focus an app. Hover over a running window to request a
preview. Right-click for app actions, pinning, and OmaPanel settings.

## Repeat (after approval on the target machine)

```bash
omarchy plugin add https://github.com/atagulalan/omapanel.git --yes
omarchy plugin enable atagulalan.omapanel --section left
python ~/omarchy-setup/setup/omapanel/configure.py
```

The plugin installer validates its manifest. User configuration hot-reloads;
no logout is required. `settings.json` records the exact configured widget.
The replay script changes only taskbar placement/settings and saves a timestamped
backup first. Future plugin versions may need compatibility checks.

## Verification

- Manifest validation passed and plugin inventory reports enabled.
- Shell IPC ping returns `ok`; recent shell logs show the plugin loaded without
  reported OmaPanel errors.
- Visually confirmed the bottom bar and Chromium, Dolphin, and two running Foot
  window icons. `showWindowPreviews=true` is saved; hover rendering still needs
  user confirmation. A legacy `hyprctl dispatch movecursor` test was rejected
  by the Lua-based compositor and made no change.

## Undo

Original settings on this machine are backed up at
`~/.local/state/omarchy-setup/shell-before-omapanel.json`.

```bash
omarchy plugin remove atagulalan.omapanel --yes
cp ~/.local/state/omarchy-setup/shell-before-omapanel.json ~/.config/omarchy/shell.json
```

Restoring the full backup also undoes any later bar changes; review it first.
For later machines, use the timestamped backup printed by `configure.py`.
