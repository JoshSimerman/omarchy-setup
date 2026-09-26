# Codex setup and work log

Record requests made to Codex, actions taken, manual steps required from the user,
problems encountered, and verified results. Keep machine-wide instructions in
[MACHINE.md](MACHINE.md), linking to them rather than duplicating them.

## 2026-09-22 — Establish setup tracking

### Requests and results

- Asked where the home folder and current working directory were: both were
  the home folder, `~`.
- Asked for a Git repository to track setup requests and changes. Codex created
  `~/machine-setup` on branch `main`, with a README, request list, change log,
  and ignore rules for common secret and temporary files.
- The initial commit failed because Git had no author identity. The user supplied
  `JoshSimerman@users.noreply.github.com`; Codex configured that email and the name `josh` locally
  in this repository, then created the initial commit.
- Asked to sync with GitHub. GitHub CLI was present but not authenticated.
  The eventual authenticated GitHub account was `JoshSimerman`.
- Asked to rename the repo to `omarchy-setup`. Codex renamed the local directory,
  updated the documentation, and committed the change before publication.
- Codex created the GitHub repository `JoshSimerman/omarchy-setup`, pushed
  `main`, and verified the local branch tracked `origin/main` with no pending changes.
- Asked for separate Codex, Claude, and machine logs to make setup repeatable.
  Codex created these three documents; Claude's log is reserved for Claude to fill in.

### GitHub authentication troubleshooting

- Interactive login sessions did not result in saved authentication, even after
  the user reported completing the browser step. One session later no longer
  existed. The exact cause was not established.
- The chat links could not be opened directly from the session. Codex opened
  `https://github.com/login/device` using `xdg-open`, explained clicking the
  code field and pressing **Ctrl+V**, and offered typing the code.
- A `nohup` attempt did not remain running. A transient user systemd service
  kept the login process running independently; authentication then succeeded.
  The command used was:

  ```bash
  systemd-run --user --unit=omarchy-setup-github-login --collect \
    /bin/bash -c 'printf "\n" | GH_BROWSER=true gh auth login --hostname github.com --git-protocol https --web > /tmp/omarchy-setup-gh-login.log 2>&1'
  cat /tmp/omarchy-setup-gh-login.log
  xdg-open https://github.com/login/device
  ```

  This was a troubleshooting workaround. For another machine, first use the
  ordinary terminal login procedure in [MACHINE.md](MACHINE.md). Device codes
  expire and must be generated anew; do not store them or access tokens here.

### Limits of this record

Codex was already available when this conversation began. Its installation,
version, and sign-in have not been documented or verified in this session. Do
not infer those steps from its availability.

**Correction (Claude, 2026-09-25, from the Codex session transcripts):** two
earlier Codex sessions that morning did change its configuration:

- 07:21 (first session): added to the top of
  `~/.codex/config.toml`

  ```toml
  approval_policy = "never"
  sandbox_mode = "danger-full-access"
  ```

  Codex runs every command without asking and without a sandbox.
- 07:23 (second session): appended to
  `~/.bashrc` (backup `~/.bashrc.bak.<timestamp>`), overriding
  Omarchy's `cy` alias, which passes `--approve-for-me`:

  ```bash
  # Keep the Codex shortcut in YOLO mode after Omarchy loads its aliases.
  alias cy='codex --yolo'
  ```

Undo: delete the two lines from `~/.codex/config.toml`, and the alias and its
comment from `~/.bashrc`.

### Follow-up — Git credentials for later pushes

The push of the three setup logs failed with `could not read Username for
'https://github.com'`. Codex ran `gh auth setup-git` to configure Git to use
GitHub CLI's saved credentials, then retried the push.

## 2026-09-22 — Windows-style desktop setup

- Request: replace forced tiling with a familiar Windows/macOS-style workflow,
  including floating windows, bottom taskbar, app icons/previews, desktop icons,
  and a file explorer with image thumbnails. Track everything for other machines.
- Used the local Omarchy skill and its Hyprland/shell guides. Inspected the actual
  installed packages, user configs, and SDDM configuration before changes.
- Proposed Plasma as an additional desktop; proceeded with this reversible
  approach after allowing time for a preference response. Kept Omarchy available.
- Installed Plasma/Dolphin and supporting packages via Omarchy's package command.
  Configured user settings, desktop links, and a KDE-only first-login panel task.
- Discovered Desktop resolved to the home directory with a trailing slash;
  corrected the script to normalize that path and use a real Desktop directory.
- Opened Dolphin and visually confirmed thumbnails of the installed wallpaper
  images. Checked scripts, desktop entries, package versions, and MIME default.
- See [setup/plasma/README.md](setup/plasma/README.md) for reproducible steps,
  limitations, local backup locations, and remaining session verification.

## 2026-09-22 — Correction: inspect Omarchy plugins first

The user asked to check Omarchy plugins. Found OmaPanel (taskbar with optional
live window previews), several docks, and an icon theme manager. Plasma was
installed before this investigation; that was premature. Removed and verified
absence of the completed Plasma SDDM override so the machine continues to start
Omarchy. Dolphin remains useful in Hyprland. No community plugin was installed
during this research. Findings and remaining gaps are in
[setup/OMARCHY-PLUGINS.md](setup/OMARCHY-PLUGINS.md).

## 2026-09-22 — Uninstall Plasma; discuss before acting

The user explicitly requested uninstalling Plasma and stated: ask before
installing; discuss first, then act. This is now recorded in `AGENTS.md`.
Removed 88 packages from the earlier installation after checking the proposed
removal against the saved pre-install package list. Removed no pre-existing
packages. Kept Dolphin and thumbnail providers. Removed Plasma-only `kwinrc`
and the first-login helper/autostart, with a local backup. The login override
was already absent. No further desktop changes or plugin installations approved.

## 2026-09-22 — Approved OmaPanel installation

Presented the taskbar-only scope and waited for the user's “do it.” Backed up
the shell config, installed and inspected OmaPanel, enabled it, moved the bar,
and configured Chromium, Dolphin, and Foot pins with previews enabled. Verified
manifest, shell responsiveness, and visible taskbar icons. Added exact settings,
a replay script, and undo instructions in `setup/omapanel/`. Floating windows
remain a separate change to discuss before acting.

## 2026-09-22 — Clock placement and floating-window proposal

Moved the clock to the far right as explicitly requested and recorded the
backup/replay change. Inspected Hyprland defaults and current official window
rule documentation to prepare the floating-window proposal. Current focus
follows the pointer (`input.follow_mouse=1`); existing shortcuts support
Super+left-drag to move, Super+right-drag to resize, and Super+T to toggle
floating. No Hyprland settings changed during this step.

## 2026-09-22 — OLED, terminal, applications, and Start menu follow-up

Completed the following user-approved work; the linked notes contain commands,
versions, configuration patches, verification, and undo/repeat instructions.

- Adapted OLED pixel shifting for the current Omarchy bar after the community
  plugin proved incompatible. Applied a user-owned bar clone and desktop-icon
  offsets every three minutes, preserving Claude's modifications. Verified
  rendered movement and unchanged saved icon positions. See
  [bar shifting](setup/oled-bar-proposal/README.md) and
  [desktop icons](setup/oled-desktop-icons/README.md).
- Installed [Ghostty](setup/ghostty/README.md) alongside Foot. Iterated on the
  visible new-tab button after screenshots exposed the initial incomplete fix;
  added clearer tabs and matched Josh's Windows PowerShell reference. Restored
  terminal colors with the Campbell ANSI palette. See the Ghostty follow-ups
  linked from its README.
- Fixed the home-directory `claude` shell function's `exec: command: not found`
  error while retaining the `~/code` trust workaround. Verified version commands
  from home and the repo; existing shells need reloading or a new tab. See
  [shortcut fix](setup/ghostty/tab-contrast-and-claude.md).
- Installed and pinned Firefox, Brave, Helium, and Google Chrome Beta (Josh's
  approved substitute for Chromium Beta). Kept Chromium as the default. See
  [browsers](setup/browsers/README.md).
- Installed VS Code, ChatGPT desktop with Codex, and Claude Desktop from the
  configured Omarchy repository; verified mapped application windows. See
  [desktop applications](setup/desktop-apps/README.md).
- Verified the official Grok CLI and installed Kimi Code with a command on PATH.
  Version/help checks passed; authentication and model calls were not tested.
  See [Grok and Kimi](setup/ai-clis/grok-kimi.md).
- Installed Telegram and opened the existing official WhatsApp web launcher.
  Account sign-in was left to the user. See [messaging](setup/messaging/README.md).
- Investigated repeated reports that WhatsApp would not reopen from Start.
  Direct launches worked but did not establish that the actual menu worked.
  Found the active `tyrsolution.app-launcher` destroyed its local AppLibrary
  before calling it. Reordered launch before dismiss, preserving Claude's
  existing plugin changes, then restarted the shell and verified the actual
  menu handler. Josh subsequently confirmed: “yep, worked.” See
  [Start menu fix](setup/start-menu-launch-fix/README.md).

These entries consolidate previously committed detailed notes. No additional
software or desktop configuration was changed during this documentation pass.

## 2026-09-22 — Install Proton VPN, Tailscale, and Parsec

Installed all three at Josh's request. Verified Proton VPN and Parsec windows,
Tailscale version and running daemon, and enabled user management for its tray
control. Added a Tailscale Start menu launcher. Sign-in, VPN connections, and
remote streaming remain for the user; Linux Parsec is client-only. Recorded
package inventory, source verification, service changes, repeat/undo steps, and
startup caveats in [network apps](setup/network-apps/README.md).

## Future entry template

### YYYY-MM-DD — Request or task

- Request and purpose:
- Starting state / prerequisites:
- Actions and commands (with file paths):
- User steps:
- Problems and resolutions:
- Verification and result:
- Undo instructions, if relevant:
- Remaining work:
