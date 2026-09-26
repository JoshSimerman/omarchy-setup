# Windows Terminal reference styling — 2026-09-22

Josh requested that Ghostty resemble `~/Desktop/powershell.jpg`. Inspected that
image: charcoal strip, nearly black selected tab, rounded upper corners, gray
terminal text, and a larger terminal font than the previous Ghostty setup.

Applied Ghostty-only changes:

- Updated `tab-contrast.css`: charcoal #323232 strip/inactive tabs, #0c0c0c
  selected tab, subtle inactive separators, no bright underline.
- Font size changed from 9 to 11; existing JetBrainsMono Nerd Font retained.
- Added `windows-reference.conf`, loaded after the Omarchy theme include, to
  override background to #0c0c0c and foreground to #cccccc. Inline colors in the
  main config alone were overridden by the theme include.
- Titlebar colors set to #323232 / #eeeeee. Existing integrated titlebar,
  always-visible tabs, and New Tab controls retained.

The adjacent `windows-reference-config.patch` records main config changes.
For reproduction, copy both CSS and color config to `~/.config/ghostty/`, review
and apply the main-config patch against the previous documented setup, validate,
and reload. No packages or fonts were installed. This changes appearance only;
it does not install PowerShell or recreate the screenshot's shell sessions.
Ghostty's controls remain in its own layout, including the left-side plus button.
The reference photo itself was not added to the repository.

## Verification

`ghostty +validate-config` passed. Effective config reports font size 11,
background #0c0c0c, and foreground #cccccc. Started Ghostty because no Ghostty
window was running, then opened a second tab to compare active/inactive styling.
Inspected screenshots of the live window. The charcoal strip, darker selected
tab, separators, and plus button are visible. Local temporary final screenshot:
`/tmp/ghostty-windows-reference-final.png`.

## Undo

Backups from immediately before this change:

- `~/.local/state/omarchy-setup/ghostty-before-windows-reference-config`
- `~/.local/state/omarchy-setup/ghostty-before-windows-reference-tab-contrast.css`

Remove the windows-reference include and titlebar color overrides, return font
size to 9, and restore the prior CSS if desired. Review any subsequent edits
before using backups. Reload Ghostty afterward. The fixed Claude shortcut and
Foot's default selection are unaffected.

This styling supersedes the earlier light-selected-tab treatment in
`tab-contrast-and-claude.md`.
