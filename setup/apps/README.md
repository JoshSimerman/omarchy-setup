# Apps: added and removed

One list of every app added to or removed from the stock Omarchy install, so
another machine can be brought to the same state. Omarchy's own package set is
in `/usr/share/omarchy/install/omarchy-base.packages`.

## Added

| App | Package | By | Date | Details |
| --- | --- | --- | --- | --- |
| Clipboard keeper | `wl-clip-persist` | Claude | 2026-09-22 | [CLAUDE.md](../../CLAUDE.md) |
| Dolphin + thumbnails | `dolphin`, `ffmpegthumbs`, `kdegraphics-thumbnailers`, `kimageformats`, `kio-extras` | Codex | 2026-09-22 | [plasma](../plasma/README.md) (kept after Plasma removal) |
| Kate, Gwenview, Ark | `kate`, `gwenview`, `ark` | Claude | 2026-09-22 | [windows-style](../windows-style/README.md) |
| Fluent icons | `fluent-icon-theme` (AUR) | Claude | 2026-09-22 | [windows-style](../windows-style/README.md) |
| Ghostty | `ghostty` | Codex | 2026-09-22 | [ghostty](../ghostty/README.md) |
| Flameshot | `flameshot` | Claude | 2026-09-22 | [TASKBAR.md](../windows-style/TASKBAR.md) |
| Firefox, Brave, Helium, Chrome Beta | `firefox`, `brave-bin`, `helium-browser-bin`, `google-chrome-beta` | Codex | 2026-09-22 | [browsers](../browsers/README.md) |
| VS Code, ChatGPT/Codex, Claude Desktop | `visual-studio-code-bin`, `openai-codex-desktop`, `claude-desktop` | Codex | 2026-09-22 | [desktop-apps](../desktop-apps/README.md) |
| Grok and Kimi CLIs | mise `npm:@xai-official/grok`, Kimi installer | Codex | 2026-09-22 | [ai-clis](../ai-clis/grok-kimi.md) |
| Telegram, WhatsApp web app | `telegram-desktop`, web app | Codex | 2026-09-22 | [messaging](../messaging/README.md) |
| OnlyOffice (replaces LibreOffice) | `onlyoffice-bin` (AUR) | Claude | 2026-09-22 | below |
| Loupe (image viewer) | `loupe` | Claude | 2026-09-22 | below |
| Sunshine (remote desktop host) | `sunshine` | Codex, set up by Claude | 2026-09-23 | [sunshine](../sunshine/README.md) |
| Brave Origin | `brave-origin-bin` (AUR) | Claude | 2026-09-24 | below |
| Mullvad Browser, LibreWolf, Waterfox | `mullvad-browser-bin` (AUR), `librewolf`, `waterfox-bin` (AUR) | Claude | 2026-09-24 | below |

Installed on 2026-09-21, before these logs began (so not by Codex or Claude
here): `mise-bin`, `fprintd`, `libfprint-git`, `usbutils`, `voxtype-bin`.

## Removed

| App | Package | Date | Why |
| --- | --- | --- | --- |
| Kdenlive (video editor) | `kdenlive` | 2026-09-22 | not used |
| Moonlight (game streaming) | `moonlight-qt` | 2026-09-22 | no gaming PC |
| Pinta (image editor) | `pinta` | 2026-09-22 | not used |
| Xournal++ (handwritten notes) | `xournalpp` | 2026-09-22 | not used |
| Omawrite (writing app) | `omawrite` | 2026-09-22 | Obsidian covers it |
| Aether (theme maker) | `aether` | 2026-09-22 | not used |
| LibreOffice | `libreoffice-fresh` | 2026-09-22 | replaced by OnlyOffice |
| imv (image viewer) | `imv` | 2026-09-22 | Gwenview covers it |
| Basecamp, HEY, Zoom | web apps | 2026-09-22 | not used |
| Plasma desktop | 88 packages | 2026-09-22 | [plasma](../plasma/README.md) |
| Nautilus | `nautilus` + 18 | 2026-09-22 | replaced by Dolphin; [windows-style](../windows-style/README.md) |

Kept on purpose: all five browsers (Josh uses each for a different purpose),
Docker, Obsidian, OBS Studio, Omacut, cliamp, and the remaining web apps.

## 2026-09-22 cleanup (Claude)

**Removed** with one `pacman -Rs` (orphaned dependencies only, 73 packages in
[removed-2026-09-22.txt](removed-2026-09-22.txt)):

```bash
pkexec pacman -Rs kdenlive moonlight-qt pinta xournalpp omawrite aether libreoffice-fresh imv
omarchy-webapp-remove Basecamp HEY Zoom
```

These are the same packages Omarchy's own `omarchy-remove-preinstalls` drops,
so nothing in Omarchy depends on them. Also:

- `~/.local/share/applications/imv.desktop` (Omarchy's launcher for imv) moved
  to `~/.local/state/omarchy-setup/imv.desktop.removed-20260922`, since it
  would otherwise remain as a broken Start-menu entry.
- `x-scheme-handler/mailto=HEY.desktop` removed from `~/.config/mimeapps.list`
  (backup `~/.config/mimeapps.list.bak.<epoch>`). Email links then fall back to
  the system default, `firefox.desktop` (checked 2026-09-25 with
  `xdg-mime query default x-scheme-handler/mailto`).
- Full package lists before and after:
  `~/.local/state/omarchy-setup/packages-{before,after}-app-cleanup-20260922.txt`.

Leftovers from Omarchy's shortcuts: **Super+Shift+W** (Omawrite) now does
nothing, and **Super+Shift+E / C** still open HEY email and calendar in the
browser.

**OnlyOffice 9.4.0** from the AUR. The PKGBUILD
([copy](onlyoffice-bin.PKGBUILD)) is maintained by two Arch staff, downloads
the official `.deb` from ONLYOFFICE's GitHub releases with a pinned sha256,
and applies one patch (`%U` → `%F` in the launcher's `Exec`). Built as the user,
installed with pacman, which pulled `ttf-carlito`, `ttf-dejavu`,
`gst-plugins-ugly`, `a52dec`, `libmpeg2` from the official repos:

```bash
makepkg -d            # deps resolved by pacman -U below
pkexec pacman -U onlyoffice-bin-9.4.0-1-x86_64.pkg.tar.zst
xdg-mime default onlyoffice-desktopeditors.desktop <office MIME types>
```

OnlyOffice is now the default for Word, Excel, PowerPoint, OpenDocument, RTF,
CSV, Visio and Apple iWork files. PDF stays with Document Viewer, and
Markdown and text with Kate.

**Verification:** `pacman -Q` finds none of the eight packages;
`onlyoffice-desktopeditors --version` prints `9.4.0.129`; `xdg-mime query
default` returns OnlyOffice for `.docx`/`.xlsx`, Evince for PDF, Kate for
Markdown.

**Undo:** `pkexec pacman -S` the packages, and `omarchy-webapp-install` for the
web apps. Remove OnlyOffice with `pkexec pacman -Rs onlyoffice-bin`.

## 2026-09-22 Loupe as the image viewer (Claude)

Josh found Gwenview "okay but not great" and picked Loupe (GNOME Image Viewer,
closest to the Windows 11 Photos app) over qView and XnView MP.

```bash
pkexec pacman -S loupe     # extra; also pulled geocode-glib, gweather-locations, libgweather-4
xdg-mime default org.gnome.Loupe.desktop <all 26 MimeTypes from org.gnome.Loupe.desktop>
```

Backup: `~/.config/mimeapps.list.bak.<epoch>`. Gwenview stays installed.

**Verification:** `xdg-mime query default` returns Loupe for PNG, JPEG, HEIC
and SVG; `gio open` on a PNG opened Loupe floating, dark theme, with window
buttons.

**Undo:** `xdg-mime default org.kde.gwenview.desktop image/png image/jpeg
image/gif image/webp image/bmp image/svg+xml`, then `pkexec pacman -Rs loupe`.

## 2026-09-24 Brave Origin (Claude)

Josh asked for Brave Origin, Brave's stripped-down browser, alongside regular
Brave (`brave-bin` 1.95.104, kept). Installed `brave-origin-bin`
1:1.96.59-1 from the AUR:

- Reviewed AUR commit `f2daecf`. The maintainer is Brave
  (`aur-release@brave.com`). The package downloads Brave's official release zip
  from `github.com/brave/brave-browser` with a pinned SHA-256, installs it
  under `/opt/brave-origin-bin`, and adds a `brave-origin` launcher and
  desktop entry. It conflicts only with `brave-origin`, not `brave-bin`. No
  install script.
- Built as Josh with `makepkg` in
  `~/.cache/omarchy-setup/apps/brave-origin-bin/`, then ran
  `pkexec pacman -U brave-origin-bin-1:1.96.59-1-x86_64.pkg.tar.zst`
  (Josh entered the password).
- Verified: `brave-origin --version` → `Brave Origin 154.1.96.59`; **Brave
  Origin** is in Start; the default browser is still Chromium. It keeps its
  own profile, separate from Brave's.
- Updates: AUR, so `yay` (or rebuild) picks up new versions.
- Undo: `sudo pacman -R brave-origin-bin`.

## 2026-09-24 Mullvad Browser, LibreWolf, Waterfox (Claude)

Josh asked for all three, in addition to the existing browsers.

| Browser | Package | Version | Source and check |
| --- | --- | --- | --- |
| LibreWolf | `librewolf` | 155.0.1_1-1 | Arch `extra`, signed |
| Mullvad Browser | `mullvad-browser-bin` | 15.0.23-1 | AUR `bced3d1`; tarball from `dist.torproject.org`, SHA-256 and PGP signature checked |
| Waterfox | `waterfox-bin` | 1:6.7.4-1 | AUR (Exorcism, AutoUpdateBot); tarball from `cdn.waterfox.com`, pinned SHA-512 (Waterfox doesn't sign releases) |

- Reviewed both AUR PKGBUILDs: each copies the official release into
  `/opt`, adds a launcher and desktop entry, turns off the browser's built-in
  updater (the AUR handles updates), and has no install script.
- Mullvad's signing key: `gpg --auto-key-locate nodefault,wkd --locate-keys
  torbrowser@torproject.org` imported `EF6E286DDA85EA2A4BA7DE684E2C6E8793298290`
  (Tor Browser Developers) into Josh's keyring. It matches the PKGBUILD's
  `validpgpkeys`.
- Waterfox needed `startup-notification` from `extra`. The package was built
  with `makepkg --nodeps`, and the dependency was installed in the same
  `pkexec` run: `pacman -S --needed librewolf startup-notification`, then
  `pacman -U` of the two built packages. Build dirs are under
  `~/.cache/omarchy-setup/apps/`.
- Verified: `librewolf --version` → 155.0.1-1, `mullvad-browser --version` →
  140.16.0esr, `waterfox --version` → 6.7.4; all three in Start; default
  browser still Chromium.
- Waterfox created an empty `~/Waterfox` folder on first launch
  (2026-09-24 20:22); harmless, left in place.
- Undo: `sudo pacman -R librewolf mullvad-browser-bin waterfox-bin
  startup-notification`.
