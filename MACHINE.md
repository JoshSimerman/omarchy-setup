# Machine setup and requests

The shared record for preparing this machine and repeating the process on other
machines: installs, setup, configuration, and other requests. Record exact
commands and paths when known, including manual steps and failed attempts that
explain a working solution. Distinguish observed state from changes made here.

## Known starting state — 2026-09-22

- This machine is being tracked as an Omarchy setup.
- Single desktop user; use `~` for the home directory in repeatable instructions.
- Git was already installed; observed version: `2.55.0`.
- GitHub CLI (`gh`) was already installed. Its installation and version were not
  recorded during this setup.
- Base OS installation, hardware details, and previous package/configuration
  changes have not yet been inventoried.

## 2026-09-22 — Set up the tracking repository

**Request:** Track the full setup process in Git and on GitHub so it can be
repeated on other machines.

**Changes made:**

1. Created `~/machine-setup` and initialized Git with branch `main`.
2. Added `README.md`, `REQUESTS.md`, `CHANGELOG.md`, and `.gitignore`.
3. Set repository-local Git identity to `josh <JoshSimerman@users.noreply.github.com>` and committed.
4. Renamed the directory to `~/omarchy-setup` and updated its documentation.
5. Authenticated GitHub CLI as `JoshSimerman`, using HTTPS for Git operations.
6. Created the GitHub repository and pushed using:

   ```bash
   gh repo create JoshSimerman/omarchy-setup --public \
     --description 'Track Omarchy machine setup requests and changes' \
     --source ~/omarchy-setup --remote origin --push
   ```

7. Added `CODEX.md`, `CLAUDE.md`, and this machine log for ongoing records.
8. A subsequent push could not obtain an HTTPS username. Ran `gh auth setup-git`
   to configure Git's credential helper to use the authenticated GitHub CLI.

**Result:** Remote is `https://github.com/JoshSimerman/omarchy-setup.git`; local `main`
tracks `origin/main`. At the time, GitHub reported the repository as
private, although the command above is recorded with `--public`; the
repository is now public, as a squashed snapshot (see the README). Login
troubleshooting and user assistance are recorded in [CODEX.md](CODEX.md).

## 2026-09-22 — Claude Code usability fixes (clipboard, mise, shell)

**Request:** Three problems raised while using Claude Code: a folder-trust
prompt on every start, a version warning, and text paste failing. Tool-specific
detail and diagnosis are in [CLAUDE.md](CLAUDE.md); the machine-level changes
are below.

**Observed state correction:** `gh` is not a standalone install — `~/.config/mise/config.toml`
manages `claude`, `codex`, `gh`, and `node = "26.8.2"`. Desktop is Hyprland with
**foot** as the terminal.

**Packages installed:**

| Package | Version | Repo | Purpose |
| --- | --- | --- | --- |
| `wl-clip-persist` | `0.5.0-2` | `extra` | Keep the Wayland clipboard after the copying app exits |

```bash
pkexec omarchy-pkg-add wl-clip-persist
```

`omarchy-pkg-add` calls `sudo` internally, which an agent cannot answer; `pkexec`
raises a graphical polkit prompt instead and the script's `EUID == 0` branch runs
`pacman` directly.

**Configuration changed:**

1. `~/.config/hypr/autostart.lua` — start the clipboard daemon at login
   (backup: `~/.config/hypr/autostart.lua.bak.<epoch>`):

   ```lua
   -- Keep the Wayland clipboard alive after the copying app closes.
   o.launch_on_start("wl-clip-persist --clipboard regular")
   ```

   Started for the running session with
   `setsid uwsm-app -- wl-clip-persist --clipboard regular &`.

2. `~/.config/mise/config.toml` — added `[settings] minimum_release_age = "0"`
   via `mise settings set minimum_release_age 0`, then
   `mise install claude@2.1.280`.

   **Security trade-off, applied deliberately:** this removes the delay that
   keeps mise from installing a release in its first hours, for **every**
   mise-managed tool, not just Claude. Revert by deleting the setting.

3. `~/.bashrc` — added a `claude` shell function that launches from `~/code`
   when invoked from `$HOME`, because Claude Code never persists trust for the
   home directory (backup: `~/.bashrc.bak.<epoch>`). Full snippet and rationale
   in [CLAUDE.md](CLAUDE.md). Also created `~/code`.

4. **Codex runs without approvals or sandbox** (Codex, 2026-09-22 07:21–07:23;
   recorded 2026-09-25 from its transcripts). `~/.codex/config.toml` has
   `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`, and
   `~/.bashrc` has `alias cy='codex --yolo'` (overrides Omarchy's
   `--approve-for-me`). **Security trade-off, like Claude's
   bypass-permissions default:** Codex can run any command and edit any file
   without asking. Details and undo in [CODEX.md](CODEX.md).

**Verification:**

- `hyprctl reload` succeeded and `hyprctl configerrors` reported nothing.
- Copied text, killed the owning `wl-copy`, and `wl-paste` still returned it.
- `bash -n ~/.bashrc` clean; `type claude` in a fresh interactive shell reports
  a function.
- `mise ls claude` shows `2.1.280` as `latest`.

**Undo:** Restore the two `.bak.<epoch>` files, remove `minimum_release_age`
from `~/.config/mise/config.toml`, and `sudo pacman -Rns wl-clip-persist`.

**To repeat on another machine:**

```bash
mise settings set minimum_release_age 0   # optional; skips the release delay
omarchy pkg add wl-clip-persist
```

Then re-apply the `autostart.lua` and `~/.bashrc` snippets above.

## Repeat on another machine

These steps reuse the existing repository. Run them in a terminal, completing
browser authorization when prompted. Git and GitHub CLI must already be
installed; installation steps remain to be documented when performed.

```bash
git --version
gh --version
gh auth login --hostname github.com --git-protocol https --web
gh auth status
gh auth setup-git
gh repo clone JoshSimerman/omarchy-setup ~/omarchy-setup
cd ~/omarchy-setup
git config --local user.name josh
git config --local user.email JoshSimerman@users.noreply.github.com
git status --short --branch
git remote -v
```

- Authorize with a GitHub account that can access the repository.
- In the browser, click the device-code field and press **Ctrl+V** if the code
  was copied to the clipboard, or type the newly generated code. Continue
  through authorization until GitHub reports success.
- If the repository already exists on the next machine, inspect it and its
  working tree before cloning or pulling. Do not overwrite local work.
- The commands above are a repeat procedure derived from this setup; they have
  not yet been tested on a second machine.
- Cloning restores the tracked files, not the machine's configuration. Apply
  documented installation and configuration steps separately as they are added.

## Ongoing workflow

1. Start a request in [REQUESTS.md](REQUESTS.md). Record the date and machine
   identifier for work on additional machines; do not overwrite earlier history.
2. Record tool-specific details in `CODEX.md` or `CLAUDE.md`, and shared machine
   changes here. Include prerequisites, exact commands, configuration paths,
   manual steps, and verification. Keep secrets out of all records.
3. Mark completed requests and add a brief entry to [CHANGELOG.md](CHANGELOG.md).
4. Review the diff, commit the relevant files, and push to GitHub. On multiple
   machines, synchronize before starting work when the working tree is clean.

## 2026-09-22 — omarchy — Windows-style desktop

Requested floating windows, a bottom taskbar with icons/previews, desktop icons,
and a file explorer with image thumbnails. Added KDE Plasma alongside Omarchy
and installed/configured Dolphin and supporting desktop applications.

The complete package list, reproducible configuration scripts, changed paths,
backups, verification, and undo procedure are in
[setup/plasma/README.md](setup/plasma/README.md). Dolphin thumbnails were visually
verified in the current Hyprland session. A session switch is still needed to
verify Plasma's desktop and taskbar behavior; no logout/reboot was triggered.

## 2026-09-22 — omarchy — Retain Omarchy and investigate plugins

Removed `/etc/sddm.conf.d/zz-omarchy-setup-plasma.conf` after the user redirected
the work to Omarchy plugins. Confirmed the override no longer exists; the
original login configuration applies again. Plasma packages remain installed,
and the active session is Hyprland. Dolphin thumbnails work in this session.
See [plugin findings](setup/OMARCHY-PLUGINS.md) for candidates and next steps.

## 2026-09-22 — omarchy — Plasma uninstalled

Explicitly requested by the user. Previewed recursive removal using `pacman -Rs
--print`, checked every candidate against the saved pre-install package list,
then used `pkexec /usr/bin/pacman -R --noconfirm` with the explicit 88-package
list in `setup/plasma/removed-2026-09-22.txt`. Recovered about 430 MiB.
Plasma, KWin, and its session/portal were removed along with its setup extras.
No pre-existing packages were removed. Dolphin/thumbnail packages and their
settings remain; Desktop links and the corrected Desktop directory remain.
Plasma-only user settings and autostart scripts were backed up to
`~/.local/state/omarchy-setup/plasma-uninstall-20260922-084712` and removed.
The original Omarchy login settings remain in effect.

## 2026-09-22 — omarchy — Approved bottom taskbar

Installed and enabled OmaPanel 1.11.0 with the user's explicit approval.
Moved the bar to the bottom and set pinned apps, icon-only buttons, and hover
previews in `~/.config/omarchy/shell.json`. Original configuration is backed up
at `~/.local/state/omarchy-setup/shell-before-omapanel.json`. Visually verified
the bar and running-app icons; hover preview rendering awaits user confirmation.
See [setup/omapanel](setup/omapanel/README.md) for exact settings and repeat/undo
instructions. Hyprland window behavior is unchanged.

## 2026-09-22 — Clock at far right

Moved `omarchy.clock` to the last position in the bar's right section with
`omarchy bar move omarchy.clock --section right --index 99`. Configuration and
visual placement verified. Backup: `~/.local/state/omarchy-setup/shell-before-clock-right.json`.
Replay script in `setup/omapanel/configure.py` now retains this arrangement.
Floating windows are the next proposed change, awaiting discussion/approval.

## 2026-09-22 — omarchy — Windows-style desktop (Claude)

Approved by the user after a research proposal; applied by Claude. Details,
the shortcut table, plugin review verdicts, repeat script, and undo steps are
in [setup/windows-style/README.md](setup/windows-style/README.md).

- Added `~/.config/hypr/windows_style.lua`, loaded by one `require` at the end
  of `~/.config/hypr/hyprland.lua` (backup `hyprland.lua.bak.1790103995`).
- Installed and enabled five Omarchy shell plugins at reviewed commits (see
  `setup/windows-style/plugins.txt`); built Grabbar's native plugin with
  `make`. Grabbar is loaded per session, not at login.
- Removed `omarchy.menu` from the bar; the Start menu replaces it
  (backup `~/.config/omarchy/shell.json.bak.1790103995`).
- Packages: `kate`, `gwenview`, `ark` from `extra`; set as default text and
  image apps (backup `~/.config/mimeapps.list.bak.1790103995`).
- Verified: `hyprctl configerrors` clean; options live; all shortcuts
  registered; a new window opened floating and centred; snap-left geometry
  correct above the taskbar; Start menu and Task View open and close over IPC.

## 2026-09-22 — omarchy — Windows-style follow-ups (Claude)

Everything after the first Windows-style round, as it affects the machine.
Details and verification: [setup/windows-style/](setup/windows-style/README.md)
(dated list in its `LOG.md`).

**Packages — final state**

| Package | Change | How | Notes |
| --- | --- | --- | --- |
| `fluent-icon-theme` 20260727-1 | installed (AUR) | `makepkg` + `pkexec pacman -U` | PKGBUILD reviewed; Fluent-dark icons |
| `fluent-gtk-theme` 2025.04.17-1, `sassc` | installed, then **removed** | `pacman -Rns` | not noticeable |
| `ttf-selawik` 1-5 | installed (AUR), then **removed** | `pacman -Rns` | colour fringing on the OLED |
| `nautilus`, `nautilus-python` + 17 orphans | **removed** | `pacman -Rs` | list in `setup/windows-style/removed-nautilus-2026-09-22.txt`; `xdg-user-dirs` marked explicit first and kept |
| `xdg-desktop-portal-kde` | not installed | — | would pull 57 Plasma packages |
| `flameshot` 14.0.0 | installed | `pkexec pacman -S` | Lightshot-style screenshots; see TASKBAR.md |
| `swayimg` | installed, then **removed** | — | tried for the slideshow screensaver; see DESKTOP.md |
| `loupe` | installed (2026-09-22, evening) | `pkexec pacman -S` | default image viewer; see [setup/apps](setup/apps/README.md) |

**System-level changes**

- `/usr/bin/voxtype` now points to `/usr/lib/voxtype/voxtype-onnx-avx2`
  (`pkexec voxtype setup onnx --enable`) for live Parakeet dictation; model
  in `~/.local/share/voxtype/models/parakeet-unified-en-0.6b` (2.4 GB).
- Shell plugins added (reviewed first, pinned in
  `setup/windows-style/plugins.txt`): `jankeesvw.notification-center`,
  `aryal.control-center` (local patch), `tyrsolution.app-launcher` (the
  coloured Start menu; Simple Start Menu installed but disabled). Grabbar now
  loads at login.
- Local patches to plugins (all in `setup/windows-style/`, re-applied by its
  `install.sh`): Grabbar (colours, restore host), desktop icons (Dolphin,
  sizes, keyboard, double-click; plus Codex's OLED patch), OmaPanel (running
  dash, tooltips), app launcher (local, plus Codex's launch-before-dismiss).
- User config touched: `~/.config/hypr/windows_style.lua` and `hyprland.lua`
  (Grabbar autoload block), `~/.config/omarchy/shell.json` and new
  `shell.toml`, `~/.config/omarchy/themes/vantablack/icons.theme`,
  `~/.config/dolphinrc`, `~/.config/mimeapps.list`,
  `~/.config/voxtype/config.toml`, `~/.local/share/kio/servicemenus/`,
  `~/.local/bin/dolphin-transcode`, gsettings `font-name` (JetBrainsMono
  Nerd Font 9). Also: `~/.config/flameshot/`,
  `~/.config/claude-desktop-flags.conf`, Chromium `Preferences` (default zoom
  90%), `~/.local/share/user-places.xbel` (Dolphin places incl. NAS),
  `~/.config/omarchy/qt-gtk-palette.json` (loaded through `QT_GUI_GTK_JSON`
  in `windows_style.lua`), `~/.local/share/color-schemes/OmarchyDark.colors`,
  `~/.config/omarchy/backgrounds/`, `~/.local/lib/omarchy-overrides/bin`,
  `~/.local/share/omarchy-setup/screensaver/`, archive defaults to Ark
  (`xdg-mime`), and `omarchy bar transparent false`. Details are in the
  windows-style topic docs. Backups sit next to each file as `.bak.<epoch>`.
- Monitor scaling 1.6 and theme Vantablack (Omarchy commands).

## 2026-09-22 — omarchy — NAS mount and name-lookup fix (Claude)

- `/etc/fstab`: on-demand CIFS automounts for three SMB shares on a home NAS,
  under `/mnt/nas/<share>` (a backup of `/etc/fstab` was taken before each
  edit); credentials in a mode-600 file under `~/.config/nas/` (not in this
  repo).
- `/etc/nsswitch.conf`: `mdns_minimal` → `mdns4_minimal` (backup alongside);
  `.local` lookups 5 s → 0.07 s.
- `~/.bash_profile`: prepends `~/.local/lib/omarchy-overrides/bin` (screensaver
  override). Details in [setup/windows-style/](setup/windows-style/README.md)
  (`NAS.md`, `DESKTOP.md`).

## 2026-09-22 — Additional Codex setup inventory

This is an index of the completed changes, not a script to apply blindly.
Follow each linked guide for prerequisites, backups, verification, and undo;
review local patches against the destination machine's versions first.

| Area | Recorded setup and repeat instructions |
| --- | --- |
| OLED (index and log) | [setup/OLED.md](setup/OLED.md): what's active, the post-update check, history |
| OLED bar | [User-owned `josh.bar` clone, three-minute pixel shifting](setup/oled-bar-proposal/README.md) |
| OLED desktop icons | [Small rendering offsets without changing saved positions](setup/oled-desktop-icons/README.md) |
| Terminal | [Ghostty installation and subsequent tab/style/color changes](setup/ghostty/README.md) |
| Claude shell shortcut | [Fix home-directory invocation while retaining `~/code` workaround](setup/ghostty/tab-contrast-and-claude.md) |
| Browsers | [Firefox, Brave, Helium, Google Chrome Beta and taskbar pins](setup/browsers/README.md) |
| Desktop development apps | [VS Code, ChatGPT with Codex, Claude Desktop](setup/desktop-apps/README.md) |
| AI command-line apps | [Grok verification and Kimi Code installation](setup/ai-clis/grok-kimi.md) |
| Messaging | [Telegram and WhatsApp web app](setup/messaging/README.md) |
| Start menu | [Launch before dismiss; WhatsApp reopening confirmed by Josh](setup/start-menu-launch-fix/README.md) |

At installation, Foot remained the default terminal and Chromium the default
browser. AI application sign-in/model workflows and optional Claude Cowork
virtualization were outside the installation checks. OLED shifts are limited
wear mitigation, not guaranteed burn-in prevention; plugin updates may require
rebasing the local patches. Claude's separate desktop changes are recorded in
[CLAUDE.md](CLAUDE.md) and [Windows-style setup](setup/windows-style/README.md).

## 2026-09-22 — omarchy — App cleanup and OnlyOffice (Claude)

Josh reviewed the Start menu and chose what to drop. Removed `kdenlive`,
`moonlight-qt`, `pinta`, `xournalpp`, `omawrite`, `aether`,
`libreoffice-fresh`, `imv` (73 packages with orphans) and the Basecamp, HEY
and Zoom web apps. Installed `onlyoffice-bin` 9.4.0 (AUR, PKGBUILD reviewed) as
the default office app. The running list of everything added and removed, with
commands, verification and undo, is [setup/apps](setup/apps/README.md).

## 2026-09-22 — VPN and remote-access applications

Installed Proton VPN GUI 4.18.1-1, Tailscale 1.102.3-1, and Parsec
150_104a-1. `proton.VPN` and `tailscaled` services are enabled and active;
the desktop user is Tailscale's local operator. Added a Tailscale tray launcher to Start.
See [installation, inventory, verification, and undo](setup/network-apps/README.md).
Account authentication and actual connections remain pending.

## 2026-09-23 — omarchy — Quieter fan: Balanced on AC (Claude)

Josh noticed the fan running constantly. Cause: an orphaned `lua` from the
2026-09-22 keybindings-menu hang had kept a core at 100% for 19 h (package
86 °C); killed, and the package fell to about 45 °C. Omarchy also defaults to
`performance` on AC, so, with Josh's approval, set AC to Balanced:

```bash
omarchy-powerprofiles-set ac balanced   # remembered in ~/.local/state/omarchy/powerprofiles/ac
```

Verified: `powerprofilesctl get` → `balanced`, CPU energy preference
`balance_performance`. No state file existed before (Omarchy fell back to
performance). Undo: `omarchy-powerprofiles-set ac performance`. Fan RPM
cannot be read on this ThinkPad X9-15 (`thinkpad_acpi` reports 0 RPM even
when hot), so check `sensors` temperatures instead.

## 2026-09-24 — omarchy — Sunshine remote desktop host (Claude)

Finished Codex's Sunshine setup so Josh can use this laptop from his Windows
PC with Moonlight. Codex had installed `sunshine` 2026.516.143833-4.1 on
2026-09-23 but configured nothing. Enabled the user service
`app-dev.lizardbyte.app.Sunshine` (starts with the Hyprland session), and
added ufw rules that open Sunshine's ports to the home LAN and Tailscale
only. Web UI login, Moonlight pairing, and Tailscale sign-in were left for
Josh. See [setup/sunshine](setup/sunshine/README.md).

Later the same day: updated Sunshine to 2026.914.233613 (security advisory
GHSA-fp6g-27w5-489j) from Omarchy's signed **edge** repo, since stable
lagged; set `capture = wlr`. After an unattended stream on the lock screen
exhausted RAM and swap and got other apps OOM-killed, added the user service
`sunshine-memguard`, which restarts Sunshine when capture memory
(`Shmem + GPUActive`) passes 6 GB. Josh paired Moonlight from the PC.

## 2026-09-24 — omarchy — More browsers (Claude)

Installed Brave Origin (`brave-origin-bin` 1:1.96.59, AUR, Brave-maintained),
Mullvad Browser (`mullvad-browser-bin` 15.0.23, AUR, Tor Project signature
checked), LibreWolf (`librewolf` 155.0.1, extra), and Waterfox
(`waterfox-bin` 1:6.7.4, AUR) plus `startup-notification`. PKGBUILDs were
reviewed and packages built as Josh with `makepkg`. Default browser is still
Chromium. See [setup/apps](setup/apps/README.md).

## Future machine-change template

### YYYY-MM-DD — Machine identifier — Request or task

- Purpose and requested outcome:
- Starting state / prerequisites:
- Packages and versions installed:
- Commands and manual steps:
- Configuration files changed and relevant values:
- Problems and resolutions:
- Verification and result:
- Undo instructions, if relevant:
- Remaining work:
