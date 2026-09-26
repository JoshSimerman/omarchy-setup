# Windows-style desktop with KDE Plasma

**Uninstalled on 2026-09-22 at the user's request.** Removed 88 newly added
packages (about 430 MiB), including Plasma, KWin, its portal backend, and the
additional Konsole/Gwenview/Ark applications. No pre-existing packages were
removed. Dolphin and its thumbnail support remain installed. Removed `kwinrc`
and the KDE-only first-login autostart/scripts; their backup is under
`~/.local/state/omarchy-setup/plasma-uninstall-20260922-084712`.
The SDDM override had already been removed. The instructions below are historical
and must not be reapplied without discussing the plan and obtaining approval.

**Current direction:** the user requested checking Omarchy plugins instead.
The Plasma login override was removed and verified absent. The machine continues
to start Omarchy. The procedure below records the earlier approach, not the
selected next step.

**Status check (Claude, 2026-09-25):** of the packages installed for Plasma,
these remain, mostly as libraries for the KDE apps that were kept (Dolphin,
Kate, Gwenview, Ark): `ark baloo baloo-widgets dolphin editorconfig-core-c
ffmpegthumbs gwenview kauth kcolorpicker kdegraphics-mobipocket
kdegraphics-thumbnailers kdnssd kdsoap kdsoap-ws-discovery-client kidletime
kimageannotator kimageformats kio-extras kparts kpty ktexteditor kuserfeedback
libkdcraw libkexiv2 plasma-activities polkit-qt6 ripgrep-all
syntax-highlighting`. `~/.config/kdeglobals` keeps `SingleClick=false` and
`BrowserApplication=chromium.desktop`, which Dolphin uses. The "still require
verification" items under Verification no longer apply; Plasma is gone. See
[Omarchy plugin findings](../OMARCHY-PLUGINS.md).

## What this setup provides

- KDE Plasma and KWin: floating windows with title bars, minimize/maximize/close,
  snapping, Alt+Tab, a launcher, notifications, clipboard history, and settings.
- A bottom panel with pinned browser, Dolphin, Konsole, and System Settings,
  plus running app icons, hover tooltips/previews, tray, and clock.
- Folder View desktop with Home and Machine Setup Notes shortcuts.
- Dolphin as the default directory opener, icon view with image thumbnails,
  96-pixel previews, file hover information, and folder/image/PDF/video preview
  providers. Gwenview opens images; Ark handles archives.
- Double-click to open files, click-to-focus windows, and centered new windows.
- Plasma Wayland for the next automatic login. Breeze login theme exposes a
  desktop-session chooser so Omarchy/Hyprland remains available.

Plasma supplies the window and desktop features; it does not reproduce every
Windows or macOS feature. This is an additional desktop on the existing Arch /
Omarchy installation. No Omarchy package files or Hyprland settings were edited.

## Repeat on another Omarchy machine

Review existing KDE configuration before applying: these scripts set specific
preferences and the first-login script moves existing panels to the bottom.
Run from a visible terminal as the desktop user:

```bash
cd ~/omarchy-setup
mapfile -t plasma_packages < setup/plasma/packages.txt
omarchy pkg add "${plasma_packages[@]}"
bash setup/plasma/configure-user.sh
sudo install -m 644 setup/plasma/zz-omarchy-setup-plasma.conf \
  /etc/sddm.conf.d/zz-omarchy-setup-plasma.conf
```

The install uses current configured Arch repositories without refreshing only
the package databases. On an old installation, perform the normal supported
system update first. The recorded versions are an audit of this machine, not
pinned versions for future installations.

The agent used `pkexec /usr/bin/omarchy pkg add ...` for installation, and
`pkexec /usr/bin/install ...` for the login configuration, because authentication
needed to happen in a graphical dialog. A terminal user can use the commands above.

`configure-user.sh` writes these user settings and backs up affected files:

| Path | Change |
| --- | --- |
| `~/.config/dolphinrc` | Preview providers, sizing, tooltips, folder tabs |
| `~/.local/share/dolphin/view_properties/global/.directory` | Shared icon view with previews |
| `~/.config/kdeglobals` | Double-click opening and Chromium browser |
| `~/.config/kwinrc` | Click focus and centered window placement |
| `~/.config/mimeapps.list` | Dolphin for directories; existing associations retained |
| `~/.config/user-dirs.dirs` | Use `~/Desktop` if Desktop previously pointed at home |
| Desktop directory | Home and Setup Notes link files |
| `~/.local/share/omarchy-setup/plasma/` | First-login script and panel settings |
| `~/.config/autostart/omarchy-setup-plasma.desktop` | KDE-only first-login task |

The panel script waits for Plasma, applies its settings once, and records success
in `~/.local/state/omarchy-setup/plasma-panel-ready`. Its log is
`~/.local/state/omarchy-setup/plasma-first-login.log`. Later logins leave your
panel customizations alone. Existing Plasma panel configuration is backed up
by `configure-user.sh` before the first-login script can change it.

## Enter the new desktop

Save your work first. A restart uses Plasma for automatic login with the current
machine's existing autologin user. Alternatively, log out, select **Plasma
(Wayland)** on the login screen, and sign in. No restart or logout is performed
by these setup scripts. If no autologin was configured on a future machine, the
override does not enable it; select Plasma at login.

## Verification on 2026-09-22

The SDDM override installation initially waited for graphical authentication,
then completed. It was subsequently removed when the user redirected the work
to Omarchy plugins; automatic login and the theme use the original settings.

- Installed Plasma `6.7.4-1`, KWin `6.7.4-7`, and Dolphin `26.08.0-5`.
- Installed 107 new packages, about 163 MiB downloaded and 489 MiB installed;
  see `installed-2026-09-22.txt` for the complete added-package inventory.
- Shell and JavaScript syntax checks passed; generated desktop files validated.
- `xdg-mime query default inode/directory` returns `org.kde.dolphin.desktop`.
- Launched Dolphin in the existing session and visually verified image previews
  on the three KDE wallpaper PNGs.
- Plasma session file and Breeze login theme are installed.
- Full Plasma session, panel hover previews, and first-login task still require
  verification after switching desktops. Current session remains Hyprland.

After first login: open two apps, move/resize/minimize them, hover over their
taskbar icons, open Home and the Desktop shortcuts, and confirm Dolphin shows
image thumbnails. Check network/audio controls and the first-login success file.

## Undo

To restore the previous automatic login and login theme:

```bash
sudo rm /etc/sddm.conf.d/zz-omarchy-setup-plasma.conf
```

Save work and restart, or select Omarchy/Hyprland at the login screen. Removing
this one override exposes the original SDDM configuration again.

User backups are local at `~/.local/state/omarchy-setup/plasma-backup-*`; they
are deliberately not committed because they may contain unrelated personal
settings. Each `manifest.txt` lists `EXISTED` files copied under the backup's
absolute-path structure, and `NEW` files that did not previously exist.
Restore while logged out of Plasma: copy the saved files to their original
paths and remove only the `NEW` files created by this setup. If setup was run
multiple times, undo backups from newest to oldest. Remove the panel success
marker if you intend to reapply the first-login setup later.

Two setup backups were made on this machine at `20260922-081618` and
`20260922-081700`: the second corrected the Desktop path's trailing slash.
Temporary Home/Setup Notes links in the home directory were removed; the real
shortcuts are in `~/Desktop`.

Installed packages can remain while using Hyprland. If removing them later,
review `installed-2026-09-22.txt` against current dependencies before removing
anything; do not blindly remove shared dependencies.

## References

- [Plasma task manager](https://userbase.kde.org/Plasma/Tasks)
- [Dolphin configuration](https://docs.kde.org/stable_kf6/en/dolphin/dolphin/configuring-dolphin.html)
- [Plasma scripting](https://develop.kde.org/docs/plasma/scripting/)
- Installed `/usr/share/config.kcfg/dolphin_*.kcfg` and Plasma/Breeze defaults
  were used to check settings against the installed packages.
