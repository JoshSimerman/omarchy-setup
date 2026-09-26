# Desktop-icon OLED shifting

Part of the OLED setup: see [setup/OLED.md](../OLED.md) for what's active, the
post-update check, and the change log.

Applied with Josh's approval on 2026-09-22 to the installed
`henri.desktop-icons` 1.8.0 plugin, alongside the existing taskbar shifting.

## Behavior

Icons, labels, and their input regions shift together by up to two logical
pixels horizontally and vertically every three minutes. Each screen cycles
through eight positions around the original position. Shifting pauses while an
icon is hovered, pressed, or dragged, a desktop menu is open, a rename or trust
prompt is active, or a desktop drop is in progress.

A QML Translate transform keeps this visual movement separate from saved
coordinates. Drag snapping and saved positions retain their original coordinate
system. Drop hit-testing accounts for the current offset. No new packages were
installed and no packaged Omarchy files were modified.

This small movement does not prevent all OLED wear: solid areas within an icon
still illuminate many of the same pixels. The wallpaper and other windows are
not shifted.

## Files and reproduction

Live file: `~/.config/omarchy/plugins/henri.desktop-icons/Service.qml`.
The exact change is [desktop-icons-oled.patch](desktop-icons-oled.patch).
[sha256.txt](sha256.txt) records the before/after source hashes.

The source already contained local changes from Claude. They were preserved,
including changes to `bin/desktop-index`. This patch includes only the OLED
adaptation; it does not represent a complete upstream-to-machine configuration.
Review the patch against another machine's installed plugin before applying it:

```bash
# Run from this setup repository. Check before applying.
git -C "$HOME/.config/omarchy/plugins/henri.desktop-icons" apply --check \
  "$PWD/setup/oled-desktop-icons/desktop-icons-oled.patch"
git -C "$HOME/.config/omarchy/plugins/henri.desktop-icons" apply \
  "$PWD/setup/oled-desktop-icons/desktop-icons-oled.patch"
omarchy plugin validate "$HOME/.config/omarchy/plugins/henri.desktop-icons"
omarchy restart shell
```

Plugin rescan did not load the change during this deployment; restarting the
shell did. Plugin updates may overwrite local changes, so recheck/rebase the
patch after updating the desktop-icons plugin.

## Verification

- Plugin validation passed; the restarted shell loaded the adaptation.
- At a temporary 10-second interval, the live status advanced from phase 2
  `(2, 0)` through phase 3 `(2, 2)` to phase 4 `(0, 2)`; see
  [verification.json](verification.json).
- The saved desktop-position file retained SHA-256
  `958ae521fa4e116516a2d33770ee5329d2b8014cd4b0a9741ed8a576fb0e3a67`
  across these test steps.
- After restoring the final 180-second interval and restarting, the first
  icon reported base position `(24, 24)` and rendered position `(24, 22)`.
  This confirms the transform is applied while base coordinates remain intact.
- Reverse patch applicability was checked successfully for rollback.
- Physical mouse hover/click/drag behavior, pause behavior during actual user
  interaction, and multiple monitors were not independently exercised.

Read-only live diagnostics (substitute your monitor name):

```bash
omarchy-shell josh.desktop-oled.eDP-1 status
```

The diagnostic includes enabled state, interval, phase, pause state, offsets,
icon count, and the first icon's base versus rendered coordinates.

## Disable or undo

To disable, change `property bool oledShiftEnabled: true` to `false` near the
start of the live Service.qml and restart the shell. Offsets return to zero.
The adjacent `oledShiftIntervalSeconds` property controls the interval, with a
minimum of ten seconds.

To remove this adaptation, first check and then reverse only its patch:

```bash
git -C "$HOME/.config/omarchy/plugins/henri.desktop-icons" apply --reverse --check \
  "$PWD/setup/oled-desktop-icons/desktop-icons-oled.patch"
git -C "$HOME/.config/omarchy/plugins/henri.desktop-icons" apply --reverse \
  "$PWD/setup/oled-desktop-icons/desktop-icons-oled.patch"
omarchy restart shell
```

If later edits conflict, remove the OLED additions manually rather than forcing
an old version over them. A local pre-change backup exists at
`~/.local/state/omarchy-setup/desktop-icons-before-oled.qml`; it is for reference,
not wholesale restoration over subsequent work.
