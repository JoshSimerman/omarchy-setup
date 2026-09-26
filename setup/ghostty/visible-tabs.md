# Always-visible Ghostty tabs — 2026-09-22

Josh approved keeping the tab strip visible so tabs are discoverable without
remembering keyboard shortcuts. Added to `~/.config/ghostty/config`:

```ini
# Keep tabs discoverable without keyboard shortcuts.
window-show-tab-bar = always
gtk-titlebar = true
gtk-titlebar-style = tabs
gtk-tabs-location = top
```

The first attempt set only `window-show-tab-bar = always`. Although validation
and reload succeeded, a screenshot showed no visible new-tab button. Josh
requested a fix. Explicitly selecting the integrated GTK tab titlebar exposed
the plus button and the other tab controls. Tabs remain at the top and visible
even with only one tab. Foot's default status is unchanged.

Validation: `ghostty +validate-config` passed and `ghostty +show-config` reported
`window-show-tab-bar = always`. Reloaded the running Ghostty application through
its exported GTK `reload-config` action, without closing terminal sessions:

```bash
gdbus call --session --dest com.mitchellh.ghostty \
  --object-path /com/mitchellh/ghostty --method org.gtk.Actions.Activate \
  reload-config '[]' '{}'
```

For another machine, merge the setting into its existing Ghostty config and
reload configuration. To undo, remove the added setting or set it to `auto`,
then reload. To also undo the titlebar fix, remove the three `gtk-` settings
shown above. A local pre-change backup is at
`~/.local/state/omarchy-setup/ghostty-before-visible-tabs.conf`; do not overwrite
later changes by restoring the whole backup.

## Visual verification of the fix

After validating and reloading, brought the existing Ghostty window forward
and captured its 800×600 logical-pixel region with grim. Inspected the capture:
the top-left plus button, split dropdown, tab title/close button, overview,
menu, and window close button are visible. No terminal sessions were closed.
The screenshot is local at `/tmp/ghostty-tabs-focused2.png` (temporary).
A backup immediately before this follow-up fix is at
`~/.local/state/omarchy-setup/ghostty-before-tab-controls.conf`.
