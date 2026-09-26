# Omarchy desktop plugin options — 2026-09-22

**Latest:** OmaPanel has now been explicitly approved, installed, and configured.
See [the applied taskbar setup](omapanel/README.md). The research below describes
the earlier evaluation; other candidate plugins remain uninstalled.

**Update:** Plasma has since been uninstalled at the user's request. Candidate
plugins remain research only. Discuss a concrete proposal and obtain explicit
approval before installation or further machine customization.

The user redirected the desktop work toward Omarchy plugins before adopting
Plasma. Keep the current Hyprland / Omarchy desktop and investigate native
extensions first. No community plugin has been installed or tested yet.

## Findings

| Need | Candidate / approach | Evidence and limits |
| --- | --- | --- |
| Windows-like taskbar | [OmaPanel](https://github.com/atagulalan/omapanel) | Pinned apps, running windows, context menus, and optional live hover previews. Manifest version inspected: 1.11.0. `showWindowPreviews` defaults to false and must be enabled. |
| macOS-style dock | [rosakodu Dock](https://github.com/rosakodu/omarchy-dock) | Pinned apps, running-window management, minimize/restore actions, app folders, and system widgets. Alternative to a taskbar. |
| Bottom bar | Built-in `omarchy bar position bottom` | Confirmed in the installed command's help. No plugin needed just to move the bar. Not applied yet. |
| Floating windows | Hyprland user window rules | Configure independently of the taskbar plugin; current official window-rule documentation was consulted. No new rules applied yet. |
| File manager with thumbnails | Dolphin | Already installed, set as directory default, and visually tested under Hyprland. Does not require switching to Plasma. |
| Icon themes | [Omarchy Icons](https://github.com/rosakodu/omarchy-icons) | Changes icon themes across apps. It does not add files/icons to the desktop itself. |
| Files/icons on the desktop | Still investigating | No verified candidate selected. Existing `~/Desktop` shortcuts will be available to a suitable desktop surface. |

The installed Omarchy version is 4.0.4-1 and uses the Quattro shell, matching
OmaPanel's documented requirements. Compatibility is based on requirements
and manifest inspection; live plugin behavior has not been verified.

Recommended starting point: OmaPanel in the bottom Omarchy bar, floating-window
defaults, and the existing Dolphin configuration. Evaluate desktop icons and
window controls separately rather than assuming a dock supplies all of them.

## Plasma correction

The earlier package installation remains on disk. The pending authentication
eventually installed `/etc/sddm.conf.d/zz-omarchy-setup-plasma.conf` after the prior
status report. Removed that override with:

```bash
pkexec /usr/bin/rm /etc/sddm.conf.d/zz-omarchy-setup-plasma.conf
```

Verified the file is absent. The original Omarchy login theme and autologin
session are in effect again. No logout or reboot occurred. Plasma-specific
user preferences and its KDE-only first-login helper remain inactive while in
Hyprland. Package removal has not been attempted.

## Sources

- [Omarchy plugin marketplace](https://plugins.omarchy.org/)
- [Omarchy shell plugins manual](https://omarchy.org/manual/shell-plugins/)
- [Hyprland window rules](https://wiki.hypr.land/Configuring/Basics/Window-Rules/)
- Candidate source repositories linked above; installed `omarchy plugin` and
  `omarchy bar` help and plugin inventory.
