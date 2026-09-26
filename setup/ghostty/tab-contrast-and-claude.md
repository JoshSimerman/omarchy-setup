# Distinct tabs and Claude shortcut repair — 2026-09-22

Josh approved clearer tab borders, an active-tab highlight, and repair of the
Claude launch shortcut. Existing settings and other agents' work were preserved.

## Ghostty appearance

Installed the adjacent `tab-contrast.css` at
`~/.config/ghostty/tab-contrast.css` and appended to Ghostty's existing config:

```ini
gtk-custom-css = ~/.config/ghostty/tab-contrast.css
```

Tabs now have rounded gray borders and spacing. The selected tab has a lighter
background, brighter border/text, and bottom highlight. Styling is scoped to
Ghostty tabs. Config validation passed; reloaded through its GTK reload-config
action. A screenshot of the existing two tabs confirmed both the border and
selected/unselected contrast. No sessions were closed.

To reproduce, copy the CSS to that path, add the config line, validate with
`ghostty +validate-config`, then reload. To undo, remove the config line and
reload; the unused CSS may then be deleted. Pre-change config backup:
`~/.local/state/omarchy-setup/ghostty-before-tab-contrast.conf`.

## Claude shortcut

The existing Bash function attempted `exec command claude` when invoked from
home. `exec` tried to run an executable named `command`, but `command` is a Bash
builtin, so startup failed with `exec: command: not found`.

Changed only its home-directory branch:

```bash
(builtin cd "$HOME/code" && command claude "$@")
```

`command claude` bypasses the wrapper function and invokes the installed CLI.
`builtin cd` avoids expansion of the existing cd alias. The subshell preserves
the calling shell's working directory. Existing arguments and permission-mode
settings were not changed. See `claude-shortcut.patch` for the exact edit.

Validation: Bash syntax check passed; fresh interactive shells returned
`2.1.280 (Claude Code)` for `claude --version` from home and the repo, and for
`cx --version` from home. These verify command resolution, not authentication
or a full Claude session. A fresh Ghostty tab was opened to load the new Bash
function. Older tabs retain the previous function until `source ~/.bashrc` or
until replaced by a new tab.

Backup: `~/.local/state/omarchy-setup/bashrc-before-claude-shortcut-fix`.
Reversing the patch restores the old broken behavior, so normally retain this
fix. For future edits, preserve unrelated `.bashrc` changes rather than copying
the entire backup over the current file.
