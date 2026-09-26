# Windows-style desktop — change log

Newest first. One short entry per change; details belong in the topic docs
linked from [README.md](README.md).

## 2026-09-25

- **`install.sh` was missing Codex's Start menu fix**
  (`start-menu-launch-fix/launch-before-dismiss.patch`), so a repeat install
  would bring back the WhatsApp-from-Start bug. Added. Every patched plugin
  now rebuilds its live files exactly from its pinned commit plus the repo's
  patches.
- **Desktop icons open on double-click.** Josh: a movie on the desktop opened
  on one click, and a double-click opened it twice. Now a single click
  selects and a double-click opens, like Windows. Verified with a virtual
  mouse on the Home icon: one click opened nothing, a double-click opened
  exactly one Dolphin window. [Details](PLUGINS.md) ·
  [patch](desktop-icons-doubleclick.patch).
- **OLED patch added to `install.sh`.** The desktop-icon OLED patch (Codex's)
  was missing between the Dolphin and sizes patches, and the bar shift step
  wasn't there either. Both added. [OLED](../OLED.md).

## 2026-09-24

- **Taskbar tooltips.** Hovering a pinned app that is not open shows its name,
  like Windows. OmaPanel already had the tooltip, but Omarchy 4's bar never
  displayed it. [Details](TASKBAR.md#app-name-tooltips).

## 2026-09-22

- **Two more NAS shares** mapped (automount + Dolphin places); **Dolphin details rows** a little roomier (22px icons); **Chrome** default page zoom 90%. [NAS](NAS.md) · [Appearance](APPEARANCE.md#consistent-sizes-2026-09-22).
- **Taskbar running dash**: open-but-inactive (incl. minimized) apps show a grey dash; closed pins show none. [Details](TASKBAR.md#running-app-dash).
- **Claude Desktop sign-in not saved**: added `--password-store=gnome-libsecret` via `~/.config/claude-desktop-flags.conf`; verified it writes to the unlocked GNOME keyring. [Details](TROUBLESHOOTING.md#claude-desktop-your-sign-in-wont-be-saved-on-this-device).
- Josh confirmed the hollow-cursor fix (clicking the desktop no longer steals the keyboard).
- **Clicking the desktop stole the keyboard** (hollow cursor): desktop-icons layer now takes keyboard focus only when renaming/menus need it; pop-up re-focus delayed 150 ms. [Details](TROUBLESHOOTING.md).
- **Hollow cursor, tested fixes**: keyboard returns after pop-ups (verified with a test window) and after the screensaver (launcher restores the previously focused window). [Details](TROUBLESHOOTING.md).
- **Lost keyboard after pop-ups** (hollow cursor): re-focus the active window when a layer closes. [Details](TROUBLESHOOTING.md).
- **Screensaver covers the taskbar** again (explicit fullscreen + focus in the launcher; maximize handler skips it). [Details](DESKTOP.md#screensaver-drifting-nebula).
- **Dictation cap** 60 s → 10 min. [Details](DICTATION.md#recording-length).
- **Start menu with colour**: tyrsolution.app-launcher replaces Simple Start Menu (disabled); local fallback AppLibrary fixes its empty grid on 4.0.4. [Details](PLUGINS.md#start-menu-with-coloured-icons).
- **Flameshot** installed: pinned tray icon, autostart, slate colours; screenshot permission pending Josh's click. [Details](TASKBAR.md#flameshot-lightshot-style-screenshots).
- **Tray arrow for hidden items**: not possible on Omarchy 4.0.4 (restricted widget API); Quick Settings covers Wi-Fi/Bluetooth/display. [Details](TASKBAR.md#hidden-tray-items-behind-an-arrow-not-possible-on-404).
- **Taskbar** a little shorter and darker: 42px, #161616. [Details](TASKBAR.md).
- **Taskbar** 48px #1C1C1C (transparency turned off), slate active-app highlight, Bluetooth/network/display removed from the tray. [Details](TASKBAR.md).
- **Minimize fixed**: Grabbar never got a restore host under Omarchy 4's restricted widget API; its service now registers itself. [Details](PLUGINS.md#grabbar-minimize-was-disabled-fixed).
- **Chrome behind everything fixed**: Omarchy tiles Chromium browsers; now floated. Maximize is now a floating fill that stacks normally. [Details](WINDOWS-AND-SHORTCUTS.md#window-behaviour).
- **Rounded corners** (8px); borders now exactly the title-bar colours so the title bar flows into a thin frame. [Details](APPEARANCE.md#title-bar-colours).
- **Focused title bar slate** #253040 (border #3A4A60); unfocused stays #1C1C1C. [Details](APPEARANCE.md#title-bar-colours).
- **Title bars still blue** for Josh: Grabbar held a stale pushed colour in memory; reloading its compositor plugin cleared it (now #333333), and the title font is set to JetBrains Mono. [Details](APPEARANCE.md#title-bar-colours).
- **Title bars and borders grey** like Windows (focused #333333 / border #4A4A4A, unfocused #1C1C1C / #262626), replacing the blue. [Details](APPEARANCE.md#title-bar-colours).
- **Dolphin/Qt colours**: near-black with subtle alternating rows (#101010/#181818, was #141618/#2F2F2F) via a Qt GTK-palette JSON override plus a KDE colour scheme; selection in title-bar blue. [Details](FILE-MANAGER.md#colours-darker-subtle-alternating-rows).
- **NAS mapped drive**: a home-NAS SMB share as a kernel SMB automount with a Dolphin place; fixed a 5 s `.local` lookup delay (IPv6 mDNS timeout) and the Desktop place pointing at home. [Details](NAS.md).
- **Wallpaper** Dark Waters (theme re-applies had cycled to the Omarchy logo);
  **screensaver** is a seamless 60 s drifting-nebula video via mpv, replacing
  the ASCII one (slideshow/swayimg tried and removed); **clock** shows the date
  below the time. The screensaver files live in a hidden folder.
  [Details](DESKTOP.md).
- Josh confirmed the JetBrains Mono result and set the guiding principle: Windows usability, not Windows looks.
- **Selawik removed**: colour fringing on the OLED; JetBrains Mono 9pt is now the interface font everywhere. [Details](APPEARANCE.md#interface-font-selawik--removed).
- **Desktop icon labels in Selawik** (`sans-serif`), rename box 13px; verified by screenshot.
- Verified after reopening Dolphin: single window, no tabs, 16px Details icons; desktop icons 48px on the 104px grid.
- **Size follow-up**: desktop icons re-gridded (stale saved positions, shell reload), Dolphin details view 16px icons, Dolphin no longer restores old tabs.
- **Quick Settings** (aryal.control-center, reviewed) on Win+A and a taskbar button; hover corners disabled, tiles repointed to Dolphin/Omarchy menu. [Details](PLUGINS.md#quick-settings-win-a).
- **Dolphin icons 48px** (Windows medium icons).
- **KDE Open/Save dialogs skipped**: would reinstall 57 Plasma packages (KWin, plasma-workspace). [Details](FILE-MANAGER.md#nautilus-removed).
- **Sizes made consistent**: interface font 11→10, taskbar 26→34px, desktop
  icons 72→48px, Dolphin icons 96→48px; Chrome page zoom 90% left to Josh.
  **Borders** 2px→1px in title-bar blue/navy. [Details](APPEARANCE.md#consistent-sizes-2026-09-22).
- **Drag-to-edge snapping declined**; the postponed list is done.
- **Action Center.** Reviewed and installed `jankeesvw.notification-center`: bell at the far right, 30-day notification panel, Win+N. [Details](PLUGINS.md#action-center-notification-center).
- **Grabbar loads at login** via its guarded autoload. [Details](PLUGINS.md#grabbar-operations).
- **Tray overflow skipped.** The built-in tray already has pin/hide and an
  arrow drawer, the tray is empty, and Den relies on unsupported internals.
  [Details](PLUGINS.md#considered-and-skipped-tray-overflow).
- **Selawik kept** after a side-by-side comparison.
- Josh confirmed live dictation works well (fast, accurate); keeping it.
- **Live dictation.** voxtype switched to its ONNX build and the streaming
  Parakeet model (2.4 GB); streaming context values set after a crash loop.
  Win+H now types while you speak. [Details](DICTATION.md).
- **Lost typing explained.** Invisible Omarchy shell panels opened by Codex's
  popup tests held the keyboard; press Esc. [Details](TROUBLESHOOTING.md).
- **Feedback.** Dictation on Win+H works and is accurate (punctuation,
  sentences); Josh would like live text but can live without it (options in
  README). Selawik was only noticed in Kate: the Omarchy shell (taskbar,
  menus, notifications) and terminals always use the monospace font, and apps
  already open need a restart. Awaiting Josh's decision to keep or revert.
- **Selawik interface font.** Installed AUR `ttf-selawik` (reviewed); GTK/Qt
  font and fontconfig's sans-serif and Segoe UI now resolve to Selawik.
  [Details](APPEARANCE.md#interface-font-selawik).
- **Win+H dictation** (voxtype toggle) and **no transparency on any window**.
  [Details](WINDOWS-AND-SHORTCUTS.md).
- **Keybindings menu hang fixed.** The Grabbar colour check looped forever
  inside Omarchy's keybindings menu (Win+K); now a counted loop.
  [Details](WINDOWS-AND-SHORTCUTS.md#keep-this-file-safe-for-omarchys-keybindings-menu).
- **Dolphin only.** Omarchy's file-manager shortcuts, desktop icons, and
  archives point at Dolphin/Ark; LocalSend and Transcode right-click actions
  recreated; folders open in separate windows; Dolphin opaque; Nautilus and
  18 orphaned dependencies uninstalled. [Details](FILE-MANAGER.md).
- **Fluent GTK theme removed**: not noticeable. [Details](APPEARANCE.md#gtk-theme-fluent--removed).
- **Fluent GTK theme.** Installed AUR `fluent-gtk-theme` (reviewed) and
  `sassc`; Fluent-round-Dark kept in place by a theme-set hook, including
  libadwaita apps. [Details](APPEARANCE.md#gtk-theme-fluent).
- **Docs split.** At Josh's request the single README became an index plus
  topic docs (window behaviour and shortcuts, plugins and apps, appearance)
  and this log.
- **Taskbar clicks raise windows.** Clicking Chrome on the taskbar focused it
  but left it behind other windows. Focused floating windows are now raised.
  [Details](WINDOWS-AND-SHORTCUTS.md#window-behaviour).
- **Blue title bars.** Focused `#005FB8`, unfocused `#1B2838`, via Grabbar's
  Hyprland options. The earlier grey patch never took effect.
  [Details](APPEARANCE.md#title-bar-colours).
- **Fluent icons.** Installed AUR `fluent-icon-theme` after reviewing its
  PKGBUILD; selected Fluent-dark. [Details](APPEARANCE.md#icons).
- Josh confirmed scaling, theme, title bars, and icons are "better now".
- **Icons fixed.** Vantablack's `Yaru-gray` icon theme is not installed, so
  icons showed as letters; a theme overlay selects an installed theme.
- **Display and theme.** Scaling 200% → 160%; Tokyo Night → Vantablack for
  the OLED. [Details](APPEARANCE.md).
- **Kate, Gwenview, Ark** installed and set as default text and image apps.
- **Initial Windows-style setup.** Floating windows, click-to-focus, Windows
  shortcuts, snapping, and five reviewed plugins (Start menu, Alt+Tab, Task
  View, desktop icons, Grabbar title bars).
