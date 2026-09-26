# Setup requests

Use unchecked items for pending work and checked items for completed work.

- [x] Claude: taskbar tooltip with the app name on pinned apps that aren't open. See [TASKBAR.md](setup/windows-style/TASKBAR.md#app-name-tooltips).
- [x] Claude: finish the Sunshine setup Codex started (service, firewall, pairing), apply the 2026.914 security update. See [Sunshine](setup/sunshine/README.md).
- [x] Claude: install Brave Origin, Mullvad Browser, LibreWolf, and Waterfox. See [apps](setup/apps/README.md).
- [x] Claude: explain and prevent the crashes when an unattended Sunshine stream ran out of memory; memory guard installed. See [Sunshine incident](setup/sunshine/README.md#incident-memory-exhausted-during-an-unattended-stream-2026-09-24).
- [x] Claude: make sure every installed app and step is logged; keep a proper log of OLED shifting. See [OLED](setup/OLED.md).
- [x] Claude: decision note on Omarchy vs plain Arch. See [decision](setup/DECISION-OMARCHY-VS-ARCH.md).
- [x] Claude: audit every Claude and Codex session against the repo (setup at ~80–90% of the goal).
- [ ] Josh: `~/.config/user-dirs.dirs` points at XDG folders that no longer exist; recreate them or repoint the entries.
- [ ] Josh: first Flameshot capture: answer the portal's one-time "Allow screenshots" prompt; check capture alignment at 160%.
- [ ] Josh: try Dolphin's LocalSend and Transcode right-click actions once.
- [ ] Optional: map the remaining NAS shares.
- [ ] Josh: account sign-ins for the VPN and remote-access apps; try the Grok/Kimi CLIs and the ChatGPT/Codex and Claude desktop apps.
- [ ] Josh + Claude: run the Sunshine leak test (unlocked vs locked) from the Windows PC; `setup/sunshine/leak-test.sh`.
- [ ] Josh: tune Moonlight on the PC (resolution, ~40 Mbps, windowed, HEVC); optional Tailscale login.

- [x] Install Proton VPN, Tailscale, and Parsec. See [setup notes](setup/network-apps/README.md); account sign-ins and connection tests remain pending.

- [x] Research Linux/Hyprland OLED protection options; see `setup/OLED-RESEARCH.md`.
- [x] Discuss and apply the approved OLED bar and desktop-icon shifting adaptations.
  See [bar](setup/oled-bar-proposal/README.md) and
  [icons](setup/oled-desktop-icons/README.md); this does not imply approval for
  additional idle/display changes.
- [x] Install Ghostty with a visible new-tab button, distinct tabs, Windows-style
  appearance, and colored terminal output. See [Ghostty](setup/ghostty/README.md).
- [x] Repair the Claude shell shortcut. See [details](setup/ghostty/tab-contrast-and-claude.md).
- [x] Install Firefox, Brave, Helium, and approved Google Chrome Beta substitute;
  pin all four to the taskbar. See [browsers](setup/browsers/README.md).
- [x] Install VS Code, Codex desktop, and Claude Desktop. See [apps](setup/desktop-apps/README.md).
- [x] Make Grok and Kimi CLIs available. See [CLI notes](setup/ai-clis/grok-kimi.md).
- [x] Install Telegram and provide WhatsApp. See [messaging](setup/messaging/README.md).
- [x] Review the Start menu apps, remove unused ones, replace LibreOffice with
  OnlyOffice, and track added/removed apps. See [apps](setup/apps/README.md).
- [x] Replace Gwenview as the default image viewer: Loupe. See [apps](setup/apps/README.md).
- [x] Fix WhatsApp reopening from Start; Josh confirmed success. See
  [Start menu fix](setup/start-menu-launch-fix/README.md).

- [x] Move the taskbar clock from the middle to the far right.
- [x] Approved: Windows-style desktop — floating windows, click-to-focus, Windows shortcuts, snapping, start menu, Alt+Tab, Task View, desktop icons, title-bar buttons, Kate/Gwenview/Ark. Plugins reviewed before install. See `setup/windows-style/`.
- [x] Fluent icons (Fluent-dark).
- [x] Fluent GTK theme — tried and removed (not noticeable).
- [x] Standardize on one file manager: Dolphin; Nautilus uninstalled.
- [x] Selawik interface font (later removed for JetBrains Mono everywhere); no window transparency; Win+H dictation.
- [x] Live dictation (Parakeet streaming) on Win+H.
- [x] Tray overflow — skipped; built-in tray already pins/hides, tray empty.
- [x] Action Center (notification center plugin, Win+N); Grabbar loads at login.
- [x] Drag-to-edge snapping — declined, not needed.
- [x] Quick Settings (Win+A); consistent sizes; thin title-bar-coloured borders.
- [x] KDE Open/Save dialogs — skipped (would reinstall most of Plasma).
- [x] Wallpaper (Dark Waters), drifting-nebula screensaver, clock with date. See `setup/windows-style/DESKTOP.md`.
- [x] NAS shares mapped (three SMB shares, automount + Dolphin places). See `setup/windows-style/NAS.md`.
- [x] Dolphin colours matched to the dark theme; Details rows 22px. See `FILE-MANAGER.md`.
- [x] Title bars: grey, then slate/blue; rounded corners; thin matching borders. See `APPEARANCE.md`.
- [x] Taskbar 48px then 42px, darker; Bluetooth/network/display tray items removed (Quick Settings covers them). See `TASKBAR.md`.
- [x] Flameshot (Lightshot-style) with tray icon and autostart. See `TASKBAR.md`.
- [x] Coloured Start menu (tyrsolution.app-launcher). See `PLUGINS.md`.
- [x] Hollow-cursor (lost keyboard) fixes. See `TROUBLESHOOTING.md`.
- [x] Dictation cap raised from 60 s to 10 minutes. See `DICTATION.md`.
- [x] Claude Desktop keyring flag (`claude-desktop-flags.conf`).
- [x] Grey dash under open-but-inactive taskbar apps. See `TASKBAR.md`.
- [x] Claude Code status line showing context used. See `CLAUDE.md`.
- [x] Chrome default zoom 90%.
- [x] Loupe as the image viewer. See `setup/apps/`.
- [x] Quieter fan: orphaned `lua` killed, AC power profile Balanced. See `MACHINE.md`.

- [x] Approved: install OmaPanel, move the bar to the bottom, enable hover previews, and pin Chromium/Dolphin/terminal. See `setup/omapanel/`.

- [x] Uninstall Plasma and its setup-specific extras, keeping Dolphin and thumbnails.
- Working agreement: discuss changes first and wait for approval before acting;
  always ask before installing software or plugins. See `AGENTS.md`.

- [x] Make the desktop familiar to a Windows/macOS user (done via `setup/windows-style/`; Plasma route abandoned): floating windows, a bottom taskbar with icons and window previews, desktop icons, and a file manager with image thumbnails. Track installation, configuration, verification, and rollback so the setup can be repeated.
- [x] Install Plasma alongside Omarchy and configure Dolphin with verified image thumbnails; record scripts, package versions, and backups in `setup/plasma/`.
- [x] Check Omarchy plugins before switching desktops; record taskbar/dock candidates and restore the original Omarchy login configuration.
- [x] Continue the Windows-style desktop work with Omarchy plugins and floating-window configuration; evaluate desktop icons and window controls. Done in `setup/windows-style/`.

- [x] Create a local Git repository for tracking machine setup changes and requests.
- [x] Rename the repository to `omarchy-setup` for tracking Omarchy setup.
- [x] Authenticate GitHub CLI and publish the `JoshSimerman/omarchy-setup` repository.
- [x] Add separate Codex, Claude, and machine logs, including the setup history and repeat procedure.
- [x] Claude: fill in `CLAUDE.md` with your own setup and work history.
- [x] Claude: stop the folder-trust prompt that appeared on every start.
- [x] Claude: remove the version warning and run the latest Claude Code release.
- [x] Claude: fix text paste failing with "No image found in clipboard".
