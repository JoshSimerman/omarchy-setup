# Decision: stay on Omarchy rather than plain Arch (2026-09-25)

## Question

Josh, at about 80–90% of the setup he wants: since the look and feel has
been changed so much, could the same result be built on plain Arch Linux,
without Omarchy as a middleman whose updates might break things?

## Decision

**Keep this laptop on Omarchy.** Manage the update risk (below) rather than
remove Omarchy. On a future machine where independence from Omarchy matters
more, use **Arch + KDE Plasma**, not Arch + a home-built Hyprland desktop.

## Why

This repo records changes made on top of Omarchy. It isn't a recipe that
works without it. Measured on 2026-09-25:

- **The Windows-style desktop runs inside Omarchy's shell.** The taskbar
  (OmaPanel), Start menu, desktop icons, Grabbar title bars, notification
  center, Quick Settings, and the OLED-shifting bar copy (`josh.bar`) are all
  plugins for the Omarchy shell (Quickshell, about 40,000 lines of QML/JS
  in `/usr/share/omarchy/shell`). 11 plugins are installed. The lock screen,
  idle handling, notifications, menus, and OSD are the shell too.
- **Omarchy supplies much more:** 441 `omarchy-*` commands, the
  `linux-omarchy` kernel, fingerprint setup, `limine-snapper-sync` boot-menu
  snapshots, and 38 installed packages from its own repo. That repo is how
  the Sunshine security fix arrived before Arch had it.
- **Hyprland config** uses Omarchy's Lua helpers (`o.bind`, `o.window`, …);
  `windows_style.lua` alone has 29 of them.

On plain Arch, these would have to be rebuilt and then maintained by us.
That's rebuilding Omarchy.

### What would carry over to any Arch install

The app list and services, which are ordinary packages plus config: the
browsers, VS Code, Telegram, OnlyOffice, Loupe, Kate/Gwenview/Ark, Dolphin
and its settings, Ghostty config, Flameshot, voxtype dictation, Sunshine plus
its firewall rules and memory guard, Tailscale, Proton VPN, fonts. See
[apps](apps/README.md), [sunshine](sunshine/README.md), and
[network-apps](network-apps/README.md).

### What wouldn't

Everything under [windows-style](windows-style/README.md) that patches or
configures Omarchy shell plugins, the OLED shifting ([OLED.md](OLED.md)),
and Omarchy themes and hooks.

## Options considered

| Option | For | Against |
| --- | --- | --- |
| **Stay on Omarchy** (chosen) | Everything works now; Hyprland is fast and customizable; Omarchy tests its pieces together and ships fixes | Omarchy updates can break our local patches to its plugins |
| **Arch + KDE Plasma** (future machines) | Most Windows features built in: taskbar previews, desktop icons, title bars with buttons, double-click, snapping, Start menu, notification center, quick settings. Large, stable project. | Less of Hyprland's speed and deep customization. Codex installed Plasma briefly on 2026-09-22 before Josh chose Omarchy; see [plasma](plasma/README.md). |
| Arch + Hyprland + own shell | Full control, no middleman | We'd be writing and maintaining our own Omarchy |

Plain Arch doesn't remove update breakage: Arch updates break things too.
It removes the project that tests the combination before we get it.

## How the update risk is managed

- Shell plugins are pinned to reviewed commits: eight in
  [plugins.txt](windows-style/plugins.txt), OmaPanel (`550e7bb`) in
  [omapanel](omapanel/README.md), and the disabled pixel-shift plugin
  (`fe24e08`) in its [trial notes](OLED-PIXEL-SHIFT-TRIAL.md). `josh.bar` is
  a local clone, rebuilt from a patch. Every local change is a
  patch in this repo, re-applied by
  [`windows-style/install.sh`](windows-style/install.sh). On 2026-09-25
  every patched plugin (OmaPanel, desktop icons, Start menu launcher, Quick
  Settings, Grabbar, `josh.bar`) was checked to rebuild its live files
  exactly from the pinned commit plus these patches.
- [`oled-check.hook`](oled-check.hook) runs after every `omarchy update` and
  shows a notification if either OLED shift is gone, or if Omarchy's bar
  changed under `josh.bar`.
- `omarchy update` takes a snapper snapshot of `/` before updating, and
  `limine-snapper-sync` lists snapshots in the boot menu, so a bad update can
  be booted around and rolled back. This only covers updates through
  `omarchy update`; plain `pacman`/`yay` installs take no snapshot.
- Update through `omarchy update`, not ad hoc, and check the desktop after
  each one (taskbar, desktop icons, title bars, Start menu).

## Revisit if

- An Omarchy update breaks the desktop and the patches can't be rebased
  cheaply.
- Omarchy changes direction (e.g. drops the plugin API these add-ons use).
- Setting up a second machine that doesn't need to match this one exactly.
