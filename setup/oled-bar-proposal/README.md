# OLED bar shifting — applied 2026-09-22

Part of the OLED setup: see [setup/OLED.md](../OLED.md) for what's active, the
post-update check, and the change log.

Josh explicitly approved applying the adaptation and pushing it. The directory
name is retained from the original proposal so earlier links keep working.

## Installed setup

Omarchy 4.0.4-1 now uses the user-owned `josh.bar` clone at
`~/.config/omarchy/plugins/josh.bar`. The exact modification is
[`bar-pixel-shift.patch`](bar-pixel-shift.patch), against the packaged `Bar.qml`
identified in [`base-sha256.txt`](base-sha256.txt). Packaged files were not edited.
The original community Pixel Shift plugin remains installed but disabled.

Only these additional bar settings were written into the current
`~/.config/omarchy/shell.json`, preserving the existing layout and other settings:

```json
"oledShiftEnabled": true,
"oledShiftIntervalSeconds": 180
```

- Left/right sections cycle through -2, 0, +2, +2, 0, -2 logical-pixel offsets.
- Center sections cycle through -1, 0, +1, +1, 0, -1 logical-pixel offsets.
- Steps occur every three minutes, unless the bar is hovered, a bar popup is
  open, or a widget is being dragged. Repeated positions mean some timer ticks
  intentionally produce no movement.
- Widget geometry moves with the content, including its hit targets.
- Existing bottom taskbar, right clock, start menu, and widgets are retained.

This moves bar content only. Desktop icons, application windows, and the bar
background do not shift. It is a limited wear mitigation, not guaranteed burn-in
prevention. Large solid areas still illuminate mostly the same pixels.

## Application and reproduction

A fresh local backup was made at
`~/.local/state/omarchy-setup/shell-before-oled-bar-adaptation.json`.
Do not restore that whole file over subsequent configuration changes.

On another machine, first compare its packaged bar with the recorded base hash.
Review/rebase the patch if the hash differs; do not force it onto a newer bar.
From this repository, on the same base version:

```bash
omarchy plugin clone omarchy.bar
# The clone command prints its destination; substitute that path below.
git -C "$HOME/.config/omarchy/plugins/josh.bar" apply \
  "$PWD/setup/oled-bar-proposal/bar-pixel-shift.patch"
omarchy plugin validate "$HOME/.config/omarchy/plugins/josh.bar"
```

Cloning activates the copy. The clone ID is based on the username, so another
machine may use a different ID. Merge the two settings above into the existing
`bar` object. Then run `omarchy restart shell`. During this deployment a hot
rescan alone did not activate the edited code; a shell restart did.

Deployed patched `Bar.qml` SHA-256:
`dd1871074927abf1354bf14c4937751c87047fc99e65b91c57c9779293f34141`.

## Verification

- Plugin manifest validation passed.
- The packaged base hash still matches the pre-change reference.
- With a temporary 10-second interval, live `debugBarGeometry` measurements
  showed clock x positions 1679, 1681, 1683 and OmaPanel positions 143, 141, 139.
  This verifies actual movement in the running bar, not just a running timer.
- Calendar, audio, and start-menu popups were summoned through shell IPC; each
  produced a visible overlay layer. The clock and taskbar positions stayed
  unchanged across an 11-second sample while the calendar was open.
- Popups were dismissed and the final interval restored to 180 seconds.
- No QML runtime TypeErrors appeared in the inspected post-restart log. Startup
  did report a duplicate `omarchy.bar` IPC-handler warning and a portal app-ID
  registration warning. Host `shell` IPC was used for these checks.
- Earlier `qmllint` checks returned zero, with existing scope/import warnings
  and additional unqualified root-reference warnings; they are not a clean
  static-analysis bill of health.

Physical mouse clicks, hover previews, drag-pausing, other monitor orientations,
and long-term OLED wear were not independently verified during this deployment.

## Disable or undo

To stop shifting while keeping the clone, set `bar.oledShiftEnabled` to `false`
in the current shell configuration. This resets offsets to zero.

To return to the packaged bar while preserving the current widget layout:

```bash
omarchy plugin enable omarchy.bar
omarchy restart shell
```

The inactive clone can remain for reference. Keep the original external Pixel
Shift plugin disabled. A copied bar does not automatically receive packaged bar
updates; compare and rebase after relevant Omarchy updates.

## Concurrent work

The live configuration was re-read before changes. Claude's plugins, layout,
and other settings were preserved. This deployment commit changes only this
adaptation document; it does not stage Claude's files or snapshot unrelated
machine settings.
