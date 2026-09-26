# Ghostty terminal trial — 2026-09-22

Josh approved installing and trying Ghostty alongside Foot for graphical tabs.
Foot remains the default terminal; launcher configuration was not changed.

Installed with `omarchy pkg add ghostty` (run through graphical privilege
escalation). New packages, all version 1.3.1-2 from Arch extra:

- ghostty
- ghostty-shell-integration
- ghostty-terminfo

The existing `~/.config/ghostty/config` was preserved. It already loads Omarchy's
current theme, uses JetBrainsMono Nerd Font at size 9, and includes clipboard
bindings. No additional terminal configuration was needed.

## Subsequent approved changes

The configuration above describes the initial installation. Later changes added
an always-visible tab strip and plus button, clearer tab styling, an 11pt font,
and Windows Terminal-style colors:

1. [Visible tabs and new-tab button](visible-tabs.md).
2. [Tab contrast and Claude shell shortcut fix](tab-contrast-and-claude.md).
3. [Windows reference styling](windows-reference.md).
4. [Campbell ANSI colors](campbell-colors.md).

Use these follow-ups for the final configuration and its verification.

## Launch and use

Find Ghostty in the application menu, or run `uwsm-app -- ghostty`.
The trial window was opened with that command.

Bindings verified with `ghostty +list-keybinds`:

- New tab: Ctrl+Shift+T
- Next/previous tab: Ctrl+Tab / Ctrl+Shift+Tab
- Copy selected text: Ctrl+Shift+C
- Paste: Ctrl+Shift+V

## Verification

`ghostty +validate-config` passed without errors. Hyprland reported a mapped
`com.mitchellh.ghostty` window. Startup initialized OpenGL, loaded the configured
font and shell integration, and started Bash. Startup also emitted GTK style
resource deprecation warnings and an unimplemented cell_size action warning;
these did not prevent the window opening. Interactive tab use is left for the
user's trial.

## Repeat or undo

On another machine, install with `omarchy pkg add ghostty`, review that machine's
existing Ghostty configuration, validate, and launch as above. Package versions
may differ.

To undo this trial, close Ghostty and remove just the three packages installed
for it with `sudo pacman -R ghostty ghostty-shell-integration ghostty-terminfo`.
If other software subsequently depends on them, review that dependency rather
than forcing removal. Preserve the pre-existing Ghostty configuration. Foot
requires no restoration because its default selection was never changed.
