# Pixel Shift trial — 2026-09-22

## Authorization and result

Josh approved trying Pixel Shift after discussion, then asked to record the
trial while taking care not to disturb Claude's concurrent changes.

**Result: installed, tested, and disabled because it does not move the bar on
this Omarchy version. It is not providing OLED protection.** No alternative
tool or workaround was installed. A new approach needs discussion first.

## Installation

- Plugin: [evindor/omarchy-pixel-shift](https://github.com/evindor/omarchy-pixel-shift)
- ID: `io.github.evindor.pixel-shift`
- Version: 1.0.0
- Commit: `fe24e0839959bc1069713503d552ec5e1d87cdef`
- Local directory: `~/.config/omarchy/plugins/io.github.evindor.pixel-shift`
- Before-install shell backup:
  `~/.local/state/omarchy-setup/shell-before-pixel-shift.json`

Commands used:

```bash
omarchy plugin add https://github.com/evindor/omarchy-pixel-shift.git --yes
omarchy plugin enable io.github.evindor.pixel-shift
omarchy bar set io.github.evindor.pixel-shift intervalSec 10 --json
omarchy bar set io.github.evindor.pixel-shift shiftOnWorkspaceSwitch false --json
```

The first temporary settings used plain arguments, which the CLI stored as
strings. Used `--json` afterward to preserve number/boolean types. Use `--json`
for typed settings when repeating these commands.

## Verification and diagnosis

- Upstream `bin/test`: 9 schedule tests passed, manifest validation passed,
  and QML lint passed.
- Shell ping returned `ok`; the plugin loaded and could be enabled/disabled.
- Four screenshots of the bottom bar, 11 seconds apart during a short-interval
  test, showed zero horizontal movement of the left icons. Clock digits changed
  but the right section did not shift either.
- Shell geometry inspection continued to show OmaPanel at x=141 and the clock
  at x=1681 logical pixels. The display was at scale 1.6 during this trial.
- Plugin `BarWidget.qml` reads `bar.moduleSlots`; if this is unavailable it
  returns without moving anything.
- Installed `/usr/share/omarchy/shell/plugins/bar/Bar.qml` injects a
  `PluginBarApi` object into community widgets. Its
  `/usr/share/omarchy/shell/Ui/PluginBarApi.qml` does not expose `moduleSlots`.
  This explains the silent incompatibility despite passing standalone tests.
- No packaged Omarchy source or plugin code was modified to bypass that API.

## Final state and cleanup

Restored the plugin's ordinary schedule values, then disabled it:

```bash
omarchy bar set io.github.evindor.pixel-shift intervalSec 180 --json
omarchy bar set io.github.evindor.pixel-shift shiftOnWorkspaceSwitch true --json
omarchy plugin disable io.github.evindor.pixel-shift
```

Plugin inventory confirmed `enabled=false` and `active=false`. The checkout
remains installed but inactive for possible future investigation. To remove it
after approval, use `omarchy plugin remove io.github.evindor.pixel-shift --yes`.

Only this plugin's settings were changed during cleanup. The full shell backup
was **not** restored, because that could overwrite Claude's simultaneous menu,
bar, or desktop changes. Claude's untracked `setup/windows-style/` work was left
untouched and excluded from this commit.

The earlier research document's compatibility expectation was not borne out by
the live test. An adapted user-owned bar or a different mitigation would need
a separate proposal; do not enable this plugin expecting protection as-is.
