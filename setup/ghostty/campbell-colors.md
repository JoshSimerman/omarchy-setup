# Restore terminal colors — 2026-09-22

Josh approved Windows Terminal colors while retaining the dark background and
tab styling. Omarchy's current theme mapped all 16 ANSI colors to grayscale.
Added explicit ANSI palette entries to the existing Ghostty-only
`~/.config/ghostty/windows-reference.conf`, which is loaded after that theme.
The adjacent tracked `windows-reference.conf` is the complete deployed file.

Palette: Microsoft Campbell, converted from Windows color-name order to ANSI
index order. Source:
https://github.com/microsoft/terminal/blob/main/src/tools/ColorTool/schemes/campbell.ini

No global theme, shell aliases, or tab CSS changed. Reloaded the running Ghostty
application through its exported GTK reload-config action. Config validation
passed, and effective config showed all 16 expected colors. A temporary Ghostty
window printed normal and bright ANSI test text; a screenshot confirmed red,
green, yellow, blue, magenta, and cyan. The test window closed automatically
without closing existing terminal sessions.

To reproduce, copy the tracked color file to the same config path and retain
its include after the Omarchy theme include. Validate and reload Ghostty.
Applications must emit color escape sequences to use these colors; plain text
remains gray. This does not force syntax highlighting in every application.

Undo: remove the 16 `palette` lines from this file and reload Ghostty. Keep the
background and foreground lines. Pre-change backup:
`~/.local/state/omarchy-setup/ghostty-before-campbell.conf`.
