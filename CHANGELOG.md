# Omarchy setup changes

## 2026-09-25

- Claude: full audit of every Claude and Codex session against the repo. No
  undocumented changes by Claude; two by Codex from 2026-09-22 morning (Codex
  set to run without approvals or sandbox, and `alias cy='codex --yolo'`),
  now in CODEX.md and MACHINE.md. Fixed stale docs: the `claude()` snippet,
  Gwenview→Loupe in `install.sh`, Dolphin Details size, border colours, the
  Selawik undo, mailto default, the desktop-icons undo, and the Plasma
  leftovers. Added missing REQUESTS.md lines and the open items found.
- Claude: decision note: stay on Omarchy rather than plain Arch; Arch + KDE
  Plasma for a future machine. See [decision](setup/DECISION-OMARCHY-VS-ARCH.md).
- Claude: `windows-style/install.sh` now applies Codex's Start menu launch
  fix. Every patched plugin rebuilds its live files exactly from the repo.
- Claude: desktop icons now open on double-click (single click selects), like
  Windows.
- Claude: OLED audit: both pixel shifts are live and rebuild exactly from the
  repo. `windows-style/install.sh` was missing the desktop-icon OLED patch
  (now added, plus the bar step). A post-update hook now checks both shifts
  after every `omarchy update`. New index and log: [OLED](setup/OLED.md).
- Claude: checked that every installed app is documented. All are, apart
  from Omarchy's own installer packages and stock web apps.

## 2026-09-24

- Claude: finished the Sunshine setup Codex started, so this laptop can be
  streamed to the Windows PC with Moonlight. See [Sunshine](setup/sunshine/README.md).
- Claude: taskbar tooltips show the app name for pinned apps that are not open.
- Claude: installed Brave Origin, Mullvad Browser, LibreWolf, and Waterfox.
  See [apps](setup/apps/README.md).
- Claude: Sunshine security update (GHSA-fp6g-27w5-489j) to 2026.914.233613
  from Omarchy's signed edge repo; `capture = wlr` for a fast start.
- Claude: an unattended Sunshine stream on the lock screen used up all
  memory and the kernel killed several apps. Added a memory guard that
  restarts Sunshine first. A test to confirm the cause is pending.
  See [Sunshine](setup/sunshine/README.md).

## 2026-09-23

- Claude: fan running constantly: killed an orphaned `lua` left at 100% CPU
  by the Win+K menu hang, and set the on-charger power profile to Balanced.

## 2026-09-22

- Claude: installed Loupe and made it the default image viewer (Gwenview kept).

- Codex: installed Proton VPN, Tailscale, and Parsec; verified application
  windows and Tailscale daemon/tray startup, added Tailscale to Start, and
  documented pending sign-ins. See [network apps](setup/network-apps/README.md).

- Claude: removed unused apps (Kdenlive, Moonlight, Pinta, Xournal++,
  Omawrite, Aether, LibreOffice, imv; Basecamp/HEY/Zoom web apps) and
  installed OnlyOffice as the default office app. Added
  [setup/apps](setup/apps/README.md) listing every app added or removed.

- Codex: consolidated recent work in `CODEX.md`, `MACHINE.md`, and
  `REQUESTS.md`: OLED bar/icon shifting, Ghostty tabs and Windows-style colors,
  Claude shell shortcut repair, browser installs and pins, desktop development
  apps, Grok/Kimi CLIs, Telegram, and WhatsApp. Linked existing detailed guides
  with versions, repeat steps, verification limits, and undo instructions.
- Codex: fixed the Start menu's application launch order so it launches before
  destroying its local AppLibrary. Josh confirmed WhatsApp now opens from the
  Start menu. See [fix and verification](setup/start-menu-launch-fix/README.md).

- Claude: fixed keyboard focus not returning after pop-ups close, the
  screensaver not covering the taskbar, and dictation stopping after 60 s.

- Claude: Start menu switched to tyrsolution.app-launcher (coloured app grid),
  with a local fix for its empty app list on Omarchy 4.0.4.

- Claude: installed Flameshot (Lightshot-style tray screenshots), pinned in
  the tray and started at login.

- Claude: Windows-style taskbar (48px, #1C1C1C, active highlight, fewer tray
  icons); fixed minimize (Grabbar restore host) and Chrome opening tiled
  behind floating windows; maximize is now a normal floating fill.

- Claude: title bars and borders switched from blue to Windows-style greys.

- Claude: darker Qt apps with subtle alternating rows in Dolphin (Qt GTK
  palette JSON override + KDE colour scheme). See
  `setup/windows-style/FILE-MANAGER.md`.

- Claude: a home-NAS SMB share as a fast automounted drive with a
  Dolphin place; `.local` name lookups fixed (5 s → 0.07 s). See
  `setup/windows-style/NAS.md`.

- Claude: Dark Waters wallpaper, drifting-nebula mpv screensaver (replaces
  the ASCII one), and the date under the clock. See
  `setup/windows-style/DESKTOP.md`.

- Claude: removed Selawik (colour fringing on the OLED); interface font is
  now JetBrains Mono 9pt, matching the terminals and bar.

- Claude: Quick Settings (reviewed `aryal.control-center`, hover corners
  disabled) on Win+A; KDE file dialogs skipped (57 Plasma packages).

- Claude: consistent sizing (font 10pt, taskbar 34px, desktop icons 48px,
  Dolphin icons 64px) and 1px borders in the title-bar colours.

- Claude: Action Center — reviewed and installed `jankeesvw.notification-center`
  (bell at the far right, 30-day history panel, Win+N).

- Claude: Grabbar title bars now load at login through its guarded autoload.

- Claude: live dictation — voxtype now runs Parakeet streaming
  (`parakeet-unified-en-0.6b`) via its ONNX build; see
  `setup/windows-style/DICTATION.md`. Diagnosed lost typing: shell panels
  summoned by Codex's tests hold keyboard focus invisibly; see
  `setup/windows-style/TROUBLESHOOTING.md`.

- Claude: every window is now opaque; Win+H toggles dictation; Selawik
  (AUR `ttf-selawik`, reviewed) is the interface font through GTK settings and
  a fontconfig rule. See `setup/windows-style/`.

- Claude: removed the Fluent GTK theme at Josh's request. Standardized on
  Dolphin: rebound Omarchy's file-manager keys, recreated LocalSend/Transcode
  right-click actions, archives to Ark, separate windows, no transparency,
  and uninstalled Nautilus (kept `xdg-user-dirs`). Fixed a hang in Omarchy's
  keybindings menu caused by `windows_style.lua`. See
  `setup/windows-style/FILE-MANAGER.md`.

- Claude: installed the Fluent GTK theme (AUR `fluent-gtk-theme`, reviewed)
  with a theme-set hook that keeps Fluent-round-Dark applied. See
  `setup/windows-style/APPEARANCE.md`.

- Claude: split `setup/windows-style/README.md` into an index plus topic
  docs (`WINDOWS-AND-SHORTCUTS.md`, `PLUGINS.md`, `APPEARANCE.md`) and a
  dated `LOG.md`.

- Claude: clicking an app on the taskbar now brings its window to the front;
  focused floating windows are raised by a `window.active` handler in
  `windows_style.lua`.

- Claude: title bars are now blue (focused `#005FB8`, unfocused `#1B2838`)
  via Grabbar's Hyprland options in `windows_style.lua`. The earlier grey
  contrast patch never took effect; see `setup/windows-style/README.md`.

- Claude: installed the Fluent icon theme (AUR `fluent-icon-theme`
  20260727-1, PKGBUILD reviewed) and switched Vantablack's icons to
  Fluent-dark.

- Claude: fixed taskbar icons showing as letters after the Vantablack switch;
  its `Yaru-gray` icon theme is not installed. A theme overlay now selects
  Breeze Dark.

- Claude: display scaling 200% → 160%, theme Tokyo Night → Vantablack (true
  black for the OLED), and a local Grabbar patch so title bars stand out from
  the black theme. See `setup/windows-style/README.md`.

- Claude: applied the approved Windows-style desktop. New windows float and
  centre, click-to-focus, edge resize and snapping, Windows shortcuts (Win key
  Start menu, Win+E/D/L/V/./I, Win+Arrows snap, Win+Tab Task View, Alt+F4,
  Ctrl+Shift+Esc). Ctrl+Alt+Del no longer closes every window. Installed five
  plugins after reading their source (Simple Start Menu, altswitch, Omascape,
  Desktop Icons, Grabbar) and Kate, Gwenview, and Ark. One file,
  `~/.config/hypr/windows_style.lua`, holds the Hyprland side. See
  `setup/windows-style/`.

- Moved the bottom-bar clock from the center to the far right at the user's
  request. Updated the replay script and saved a pre-change layout backup.

- With explicit approval, installed OmaPanel 1.11.0, moved Omarchy's bar to the
  bottom, enabled hover previews and icon-only buttons, and pinned Chromium,
  Dolphin, and Foot. Saved the prior bar configuration and repeat/undo steps.

- Uninstalled Plasma at the user's request: removed 88 newly added packages
  (about 430 MiB), preserving all packages present before the installation.
  Removed Plasma-only user startup/configuration files; retained Dolphin and
  thumbnail support. Recorded the requirement to discuss changes and obtain
  approval before acting, particularly before any installation, in `AGENTS.md`.

- User redirected desktop customization to Omarchy plugins. Researched OmaPanel,
  docks, and icon themes; removed the Plasma login override and verified that
  original Omarchy login settings apply. Recorded findings in `setup/OMARCHY-PLUGINS.md`.

- Installed KDE Plasma alongside Omarchy, plus Dolphin and thumbnail providers.
  Configured double-click opening, click focus, desktop shortcuts, and a bottom
  taskbar setup for first Plasma login. Added scripts, a package inventory, and
  rollback instructions in `setup/plasma/`. Verified Dolphin image thumbnails;
  Plasma session verification remains pending until a desktop switch.

- Created `~/machine-setup` as a local Git repository on branch `main`.
- Added a request tracker and this change log.
- Renamed the repository directory to `~/omarchy-setup` and clarified its purpose.
- Authenticated GitHub CLI as `JoshSimerman` and pushed to the GitHub repository `JoshSimerman/omarchy-setup`.
- Added `CODEX.md`, `CLAUDE.md`, and `MACHINE.md` to track setup history, troubleshooting, and steps for other machines. Claude's log is a template awaiting Claude's entries.
- Configured Git to use GitHub CLI credentials with `gh auth setup-git` after a later push failed to obtain an HTTPS username.
- Recorded Claude Code's installed state (managed by mise, OAuth login) and filled in `CLAUDE.md`.
- Worked around the repeating folder-trust prompt: Claude Code never persists trust for `$HOME`, so `~/code` was created and a `claude` shell function in `~/.bashrc` launches there when invoked from the home directory.
- Set `minimum_release_age = "0"` in `~/.config/mise/config.toml` and installed Claude Code `2.1.280`; this disables mise's fresh-release delay for all managed tools.
- Installed `wl-clip-persist` and autostarted it from `~/.config/hypr/autostart.lua` so the Wayland clipboard survives the copying application exiting, fixing text paste in Claude Code.
