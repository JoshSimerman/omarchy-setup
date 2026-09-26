# File manager: Dolphin only

Josh: "why 2 file managers, I want to standardize on 1 and make it perfect".
Chose **Dolphin** (closest to File Explorer: tabs, split view, details view,
editable address bar, previews, thumbnails, Ark's Extract here) and asked to
**uninstall** Nautilus, which Omarchy ships as its default.

## What points at Dolphin now

| Entry point | Before | Now |
| --- | --- | --- |
| Opening a folder (`inode/directory`) | Dolphin | Dolphin |
| Win+E | Dolphin | Dolphin, new window |
| Super+Shift+F (Omarchy "File manager") | Nautilus | Dolphin, new window |
| Super+Alt+Shift+F (terminal's folder) | Nautilus | Dolphin in `omarchy-cmd-terminal-cwd` |
| Taskbar pin (OmaPanel) | Dolphin | Dolphin |
| Desktop icons: Show in Files, Open Trash | Nautilus | Dolphin ([patch](desktop-icons-dolphin.patch)) |
| Zip, 7z, tar, rar, … archives | Nautilus | Ark |

Shortcut changes are in [`windows_style.lua`](windows_style.lua); see also
[WINDOWS-AND-SHORTCUTS.md](WINDOWS-AND-SHORTCUTS.md).

## Right-click actions carried over

Omarchy adds two Nautilus actions through `nautilus-python`
(`~/.local/share/nautilus-python/extensions/`, now inert). They are recreated
as Dolphin service menus in `~/.local/share/kio/servicemenus/` (copies in
[`dolphin/`](dolphin/)); KIO requires them to be executable:

- **Send via LocalSend** (any file or folder): `localsend --headless send %F`,
  the same command the Nautilus extension runs.
- **Transcode** (images and videos): runs
  [`dolphin-transcode`](dolphin/dolphin-transcode), installed to
  `~/.local/bin/`, which reproduces the extension: one file runs
  `omarchy-transcode` in Omarchy's floating presentation terminal; several
  run one after another. Dry-run tested with names containing spaces, quotes,
  and `$(...)`.

The `.desktop` files use KDE's service-menu format (`Type=Service`,
`MimeType=all/all`), which `desktop-file-validate` flags; that is expected.
The actions have not yet been clicked in Dolphin.

## Dolphin settings

- **Separate windows, not tabs.** Codex's earlier Plasma setup turned on
  `OpenExternallyCalledFolderInNewTab`; now `false` in `~/.config/dolphinrc`
  (backup `dolphinrc.bak.<epoch>`), and the shortcuts pass `--new-window`.
  Verified: `xdg-open ~/Documents` opened a second Dolphin window.
- **No tab restore.** `RememberOpenedTabs=false`, so Dolphin starts with a
  single fresh window instead of reopening last session's tabs.
- **Icon sizes.** Icons view 48px, Details view 22px (was 16px until the
  2026-09-22 "roomier rows" change), Compact view 16px (see
  [APPEARANCE.md](APPEARANCE.md#consistent-sizes-2026-09-22)).
- **No transparency.** First a Dolphin-only rule; since replaced by a rule
  that makes every window opaque (see
  [WINDOWS-AND-SHORTCUTS.md](WINDOWS-AND-SHORTCUTS.md)).

## Colours: darker, subtle alternating rows

Josh (after sharing Windows Explorer screenshots from the NAS): keep Dolphin's alternating rows but with
less contrast, and make Dolphin darker.

- **Measured before:** rows alternated #141618 / #2F2F2F (27 levels apart).
- **Why a colour scheme alone didn't work:** Dolphin paints the list
  background from the KDE colour scheme, but the alternate rows from the Qt
  application palette's `AlternateBase`, which here comes from Qt's GTK3
  platform theme (`QT_QPA_PLATFORMTHEME=gtk3`, set by Omarchy) as "GTK base at
  93% brightness". Dolphin never applies a colour scheme to the application
  palette (tested: a red `BackgroundAlternate` changed nothing).
- **Fix, two parts:**
  1. Qt 6.11's GTK3 theme reads a palette mapping from `QT_GUI_GTK_JSON`.
     The default mapping was dumped with `QT_GUI_GTK_JSON_SAVE`, and the
     system palette's roles were replaced with fixed colours:
     [`colors/qt-gtk-palette.json`](colors/qt-gtk-palette.json) →
     `~/.config/omarchy/qt-gtk-palette.json`. Base #101010, AlternateBase
     #181818, Window #141414, Button #242424, Highlight #005FB8 (title-bar
     blue), text #E6E6E6. Applies to every Qt app (Dolphin, Kate, Gwenview,
     Ark). `windows_style.lua` sets
     `hl.env("QT_GUI_GTK_JSON", …)`; Omarchy exports Hyprland's environment to
     the session at login.
  2. A KDE colour scheme, [`colors/OmarchyDark.colors`](colors/OmarchyDark.colors)
     → `~/.local/share/color-schemes/`, selected in `dolphinrc`
     `[UiSettings] ColorScheme=OmarchyDark`, so the list background matches
     (#101010) and selections use the same blue.
- **Verified:** Dolphin launched the way Win+E launches it (Hyprland →
  `uwsm-app`) alternates #101010 / #181818 (8 levels); screenshot shows a
  near-black window with a blue selected place. Apps launched from the
  taskbar or Start menu get the variable after the next login (the shell's
  supervisor keeps the login environment).
- **Undo:** remove the `QT_GUI_GTK_JSON` line from `windows_style.lua` and
  `[UiSettings]` from `dolphinrc`; delete the two colour files.

## Nautilus removed

- Marked `xdg-user-dirs` as explicitly installed first. Removing Nautilus
  would otherwise have taken it as an orphan, and the Start menu and
  screenshots use it to find Desktop, Pictures, and so on.
- `pacman -Rs nautilus nautilus-python` removed 19 packages, listed in
  [`removed-nautilus-2026-09-22.txt`](removed-nautilus-2026-09-22.txt).
- Omarchy lists Nautilus only in its install-time package list
  (`omarchy-base.packages`); no update step reinstalls it, but
  `omarchy reinstall` may. `omarchy launch nautilus` no longer works.
- Open/Save dialogs are unaffected; they come from `xdg-desktop-portal-gtk`.
  They still look GTK, unlike Dolphin. KDE-style dialogs were considered and
  **skipped** (2026-09-22): `xdg-desktop-portal-kde` 6.7.4 depends on
  `plasma-workspace` and `kwin` and would pull in 57 packages, most of the
  Plasma that was removed. Qt apps (Dolphin, Kate, Gwenview) already use KDE
  dialogs; only Chrome and GTK apps would have changed.

## Undo

```bash
sudo pacman -S nautilus nautilus-python
rm ~/.local/share/kio/servicemenus/{localsend,transcode}.desktop ~/.local/bin/dolphin-transcode
# Reverse only this patch. `git checkout` would also drop the OLED, sizes,
# keyboard, and double-click patches.
git -C ~/.config/omarchy/plugins/henri.desktop-icons apply -R ~/omarchy-setup/setup/windows-style/desktop-icons-dolphin.patch
kwriteconfig6 --file dolphinrc --group General --key OpenExternallyCalledFolderInNewTab --type bool true
```

Then remove the Dolphin bindings and opacity rule from `windows_style.lua`, and
restore `~/.config/mimeapps.list` from its latest `.bak.<epoch>` for archives.
