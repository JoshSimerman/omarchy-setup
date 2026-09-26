# Start menu cannot reopen WhatsApp — fixed 2026-09-22

Josh reported that WhatsApp opened directly but not from the Start menu. The
currently active menu is `tyrsolution.app-launcher` 0.4.0, whose AppGrid.qml
already contains local customizations from Claude.

## Cause and change

The application launch handler called `root.dismiss()` before
`root.appLibrary.launch(row.id, row.name)`. Dismiss hides/unloads the overlay,
which destroys its local AppLibrary instance. The following launch then fails:

```
QQmlVMEMetaObject: Internal error - attempted to evaluate a function in an invalid context
TypeError: Property 'launch' of object AppLibrary_QMLTYPE_19(...) is not a function
```

Moved the launch call before dismissal, with a comment explaining the lifetime
requirement. This fixes the common desktop-application launch path, including
WhatsApp. No WhatsApp profile, session, or launcher was reset. Existing plugin
modifications were preserved; only this small patch is tracked here.

Live file: `~/.config/omarchy/plugins/tyrsolution.app-launcher/AppGrid.qml`.
Exact change: `launch-before-dismiss.patch`; hashes: `sha256.txt`.
Backup: `~/.local/state/omarchy-setup/app-grid-before-launch-order.qml`.

## Verification

Reproduced the error through the same selected-app handler used by the menu:

```bash
omarchy-shell shell summon tyrsolution.app-launcher '{}'
omarchy-shell shell call tyrsolution.app-launcher setFilter WhatsApp
omarchy-shell shell call tyrsolution.app-launcher launchSelected ''
```

Before the fix, the final call returned `error` and the shell logged the invalid
AppLibrary-context error. Plugin validation passed after editing. A plugin rescan
alone retained the old behavior; `omarchy restart shell` loaded the fix. Repeating
the test returned `ok` for all calls and produced a mapped WhatsApp window on
workspace 1, with no corresponding launch error in the fresh log.

The handler was exercised through IPC, not a synthesized mouse click. This
verification covers desktop-app launching; agent, system-command, and removal
handlers were not changed or independently tested.

Josh subsequently tested the Start menu and confirmed: “yep, worked.” This adds
user confirmation to the automated menu-handler check above.

## Reproduce or undo

Review the current file before applying the patch on another machine; this
baseline includes other local modifications. Use `git apply --check` followed
by `git apply` from the plugin directory, validate, then restart the shell.
Updates to the plugin may overwrite the local fix.

To undo only this fix, use `git apply --reverse --check` and then
`git apply --reverse` with the patch, and restart the shell. This restores the
broken ordering, so normally retain the fix. Do not restore the entire backup
over other agents' later work.
