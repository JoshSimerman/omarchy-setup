# Claude setup and work log

Claude Code installation, configuration, requests, and troubleshooting on this
machine. Shared machine changes are cross-referenced in [MACHINE.md](MACHINE.md).

Keep secrets out of this file. `~/.claude/.credentials.json` holds the OAuth
token and must never be copied into this repository.

## Observed state — 2026-09-22

Recorded by Claude at the start of its first logged session; the install itself
predates this log and was not performed by Claude.

- Installed and version-managed by **mise**, not npm:
  - `~/.config/mise/config.toml` pins `claude = "latest"` (also `codex`, `gh`,
    and `node = "26.8.2"`).
  - Backend is `aqua:anthropics/claude-code` (GitHub release tarballs).
  - Binaries live in `~/.local/share/mise/installs/claude/<version>/claude`.
  - `[settings.upgrade] auto_prune = false`, so old versions are kept on disk.
- Version at session start: `2.1.278`.
- Authentication: OAuth through a Claude account (`oauthAccount` in
  `~/.claude.json`). Token stored in `~/.claude/.credentials.json` (secret).
- User settings `~/.claude/settings.json`:

  ```json
  { "theme": "dark", "tui": "fullscreen" }
  ```

- `~/.claude/skills/` contains `diagnose-crash`, `omarchy`, and `synced/`;
  `~/.claude/plugins/` contains `marketplaces/` and `synced/`. These sync down
  from the Claude account on login and do not need to be copied between
  machines.
- Terminal in use is **foot**; `omarchy` ships an alias
  `cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode auto'`.

### Repeat on another machine

1. Install mise, then `mise use -g claude@latest` (see [MACHINE.md](MACHINE.md)
   for the `minimum_release_age` setting).
2. Run `claude` and complete the browser OAuth login. Skills, plugins, and
   connectors sync down automatically.
3. Recreate `~/.claude/settings.json` with the values above.
4. Apply the home-directory trust workaround below.

## Entry template

### YYYY-MM-DD — Request or task

- Request and purpose:
- Starting state / prerequisites:
- Actions and commands (with file paths):
- User steps:
- Problems and resolutions:
- Verification and result:
- Undo instructions, if relevant:
- Remaining work:

---

## 2026-09-22 — Stop the folder-trust prompt on every start

- **Request and purpose:** Claude Code asked "Do you trust the files in this
  folder?" at every start. Make the trust decision stick.
- **Starting state:** Claude was always launched from the home directory.
  `~/.claude.json` held exactly one project entry, `$HOME`, with
  `hasTrustDialogAccepted: false` — still false despite many accepts.
- **Diagnosis:** Not a bug and not fixable by configuration. Claude Code treats
  the home directory as a restricted workspace root and grants it
  **session-only trust**, so the accept is deliberately never persisted. The
  string is in the binary: *"rooted at the home directory ... (home trust is
  session-only)"*. The trust check short-circuits on restricted roots before it
  ever reads `hasTrustDialogAccepted`, so hand-editing that flag does not help.
- **Actions:**
  1. Created `~/code` as a working directory.
  2. Backed up `~/.bashrc` to `~/.bashrc.bak.<epoch>`.
  3. Appended a `claude` shell function to `~/.bashrc` that redirects only when
     invoked from `$HOME`:

     ```bash
     claude() {
       if [[ "$PWD" == "$HOME" ]]; then
         (builtin cd "$HOME/code" && command claude "$@")
       else
         command claude "$@"
       fi
     }
     ```

     This is the current version. The original line,
     `(cd "$HOME/code" && exec command claude "$@")`, failed with "exec:
     command: not found" and Codex fixed it on 2026-09-22 at 23:44 (see
     [Ghostty notes](setup/ghostty/tab-contrast-and-claude.md)).

     Running from a real project directory is unaffected. The `cx` alias is
     covered too: alias expansion emits the word `claude`, which then resolves
     to this function.
- **User steps:** Open a new terminal so `.bashrc` reloads, then accept the
  trust dialog once in `~/code`. That accept persists.
- **Verification:** `bash -n ~/.bashrc` clean; in a fresh interactive shell
  `type claude` reports `claude is a function`.
- **Undo:** Remove the function block from `~/.bashrc` or restore
  `~/.bashrc.bak.<epoch>`.

## 2026-09-22 — Upgrade to the newest Claude Code release

- **Request and purpose:** Remove a startup warning and run the latest version.
- **Problem:** The warning came from mise, not Claude:

  ```
  mise WARN  1 newer claude release hidden by minimum_release_age
  ```

  mise's `minimum_release_age` withholds very fresh releases, so `latest`
  resolved to `2.1.278` while `2.1.280` was already published.
- **Actions:**

  ```bash
  mise settings set minimum_release_age 0
  mise install claude@2.1.280
  ```

- **Result:** `mise ls claude` shows `2.1.280` as `latest`; `2.1.278` is kept on
  disk because `auto_prune = false`. A restart is required for a running session
  to pick up the new binary.
- **Trade-off (deliberate):** `minimum_release_age` is a supply-chain guard that
  delays installing a release in its first hours, before a compromised publish
  would likely be caught. It is now disabled for **all** mise-managed tools. See
  [MACHINE.md](MACHINE.md).
- **Undo:** Remove `minimum_release_age` from the `[settings]` block in
  `~/.config/mise/config.toml`.

## 2026-09-22 — Pasting text failed with "No image found in clipboard"

- **Request and purpose:** Ctrl+V in Claude Code reported no image instead of
  pasting text.
- **Diagnosis:** Ctrl+V checks the clipboard for an image first, then falls back
  to pasting text. The text fallback runs
  `xclip -selection clipboard -t text/plain -o 2>/dev/null || wl-paste 2>/dev/null`.
  `xclip` is not installed, but `wl-paste` handles it, and a manual round-trip
  worked — so the clipboard was genuinely empty at the time. Two causes:
  1. In foot, a mouse selection only fills the **primary** selection, not the
     clipboard, and `~/.config/foot/foot.ini` sets `primary-paste=none`.
     Clipboard copy is `Ctrl+Shift+C`.
  2. On Wayland the clipboard is owned by the source application, so its
     contents vanish when that application closes.
- **Actions:** Installed `wl-clip-persist` and autostarted it — see
  [MACHINE.md](MACHINE.md) for the package and Hyprland changes.
- **Guidance for use:** Copy with `Ctrl+Shift+C`; paste with `Ctrl+Shift+V`
  (foot's own `clipboard-paste`), which sends the text straight to Claude as a
  bracketed paste and bypasses the clipboard-reading code entirely.
- **Verification:** Copied text, killed the owning `wl-copy` process, and
  `wl-paste` still returned the text.
- **Remaining work:** None.

## 2026-09-22 — Start every session in bypass-permissions mode

- **Request and purpose:** Run Claude Code with permission prompts bypassed
  whenever it is launched from the command line.
- **Actions:** Backed up `~/.claude/settings.json` to
  `~/.claude/settings.json.bak.<epoch>` and added:

  ```json
  "permissions": { "defaultMode": "bypassPermissions" },
  "skipDangerousModePermissionPrompt": true
  ```

  The second key suppresses the one-time "Bypass Permissions mode" warning.
- **`cx` alias:** An explicit `--permission-mode` flag overrides the default,
  and Omarchy's `cx` passes `--permission-mode auto`. Backed up `~/.bashrc` to
  `~/.bashrc.bak.<epoch>` and appended an override after the Omarchy rc is
  sourced:

  ```bash
  alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode bypassPermissions'
  ```

  It still goes through the `claude` function, so the `$HOME` → `~/code`
  redirect applies.
- **Trade-off (deliberate):** Claude can run any command and edit any file
  without asking. Shift+Tab still cycles modes within a session.
- **Verification:** `python3 -m json.tool` accepts the file; `bash -n ~/.bashrc`
  is clean and `bash -ic "alias cx"` shows the override. Takes effect on
  the next launch.
- **Undo:** Remove both keys from `~/.claude/settings.json` and the `cx` alias
  from `~/.bashrc`, or restore the backups.

## 2026-09-22 — Bypass-permissions default reverted to auto

- **Request and purpose:** New sessions still started in auto mode, not bypass.
- **Diagnosis:** `~/.claude/settings.json` had `"defaultMode": "auto"`; it was
  rewritten at 08:44, 30 minutes after the bypass change. Claude Code shows a
  one-time prompt, *"Make auto mode your default permission mode?"*, and
  answering yes writes `defaultMode: "auto"` over whatever was there. That is
  the most likely cause, though the rewrite itself was not observed.
  `~/.claude.json` records `hasSeenAutoDefaultNudge: true`, so it should not be
  offered again.
- **Actions:** Backed up `~/.claude/settings.json` to
  `~/.claude/settings.json.bak.<epoch>` and set `defaultMode` back to
  `"bypassPermissions"`.
- **Verification:** `python3 -m json.tool` accepts the file. Takes effect on the
  next launch; the running session keeps its mode.
- **Watch for:** If the prompt reappears after an upgrade, answer **No**.

## 2026-09-22 — Windows-style desktop: research, plugin review, apply

- **Request and purpose:** Research more ways to make Omarchy feel like
  Windows (Codex had installed OmaPanel), then "test it out … the goal is to
  turn Omarchy into the closest thing to Windows". Josh approved the four
  plugin groups on condition the code be reviewed, plus Kate and Gwenview, and
  postponed theming and the tray.
- **Research:** a background agent read the marketplace catalog
  (`site/catalog.json` in `omacom/omarchy-plugin-marketplace`), since
  plugins.omarchy.org renders client-side. Hyprland 0.56 option names were
  checked against the wiki source (`content/configuring/core/…` in
  `hyprwm/hyprland-wiki`) and `/usr/share/hypr/stubs/hl.meta.lua`.
- **Review:** cloned each plugin, confirmed HEAD equalled the marketplace's
  validated commit, and had parallel agents read every file for network use,
  privilege escalation, shell injection, and file writes. Verdicts are in
  `setup/windows-style/README.md`. After `omarchy plugin add`, re-checked each
  installed HEAD against the reviewed commit.
- **Actions:** see [MACHINE.md](MACHINE.md) and `setup/windows-style/`.
- **Problems and resolutions:**
  - `omarchy-capture-screenshot --help` has no help flag; it took a screenshot,
    saved it to `~/Pictures`, copied it to the clipboard, and sent a
    notification. Deleted the file. Read scripts instead of passing `--help`.
  - Testing snap with `hl.dsp.focus({ window = "address:…" })` did not move
    focus, so a test resize hit the tiled Claude terminal and shifted the split
    by 4 px. Restored it to 701/701. Pass `window = "address:…"` to each
    dispatcher when testing instead of relying on focus.
  - `pkexec omarchy-pkg-add` waits on the Omarchy polkit layer
    (`omarchy-polkit`) until the user enters a password.
- **Verification:** listed in MACHINE.md.
- **Remaining work (as of that entry):** the user should try maximize buttons (the
  `suppress_event` override is untested), the lone Win-key release binding,
  and Grabbar before enabling its autoload. **Update 2026-09-25:** the
  `suppress_event` override was later removed (maximize requests stay
  suppressed, see WINDOWS-AND-SHORTCUTS.md), and Grabbar's autoload has been
  enabled (windows-style LOG).

## 2026-09-22 — Windows-style follow-ups: working notes

The work itself is logged in `setup/windows-style/LOG.md` and the topic docs
there; machine-level changes in [MACHINE.md](MACHINE.md). Lessons for future
sessions:

- **Omarchy's keybindings menu runs `hyprland.lua` in a stub Lua
  environment.** Any `hl.*` call returns a placeholder, so `ipairs()` over
  `hl.get_loaded_plugins()` never ended and Win+K hung. Use counted loops.
  After editing `windows_style.lua`, check `omarchy menu keybindings --print`
  finishes, not just `hyprctl configerrors`. A hung run leaves an orphaned
  `lua` at 100% CPU: the one from 2026-09-22 11:00 ran for 19 h, holding the
  package at 86 °C and the fan on, until it was killed on 2026-09-23
  (`pgrep -a lua`).
- **Invisible shell panels steal the keyboard.** `omarchy-keyboard-panel`
  layers opened by scripts (Codex's popup tests) held focus while Hyprland
  still showed the window as active. Diagnosed with a `socket2` logger
  (`openlayer`/`closelayer`) plus a `ps` poll for `omarchy-shell` commands.
  Always close panels opened for testing; Esc closes them.
- **Installs:** `omarchy pkg add` / `yay` need a sudo prompt an agent can't
  answer. Official packages: `pkexec omarchy-pkg-add …` or
  `pkexec pacman …`. AUR: read the PKGBUILD, build with `makepkg` as the
  user, then `pkexec pacman -U`. Watch for undeclared make-dependencies
  (Fluent GTK needed `sassc`).
- **Plugins update to upstream HEAD.** After `omarchy plugin add`, compare
  `git rev-parse HEAD` with the reviewed commit. Local patches live in
  `setup/windows-style/*.patch`; the desktop-icons plugin also carries
  Codex's OLED patch (`setup/oled-desktop-icons/`), applied in the order
  dolphin → OLED → sizes.
- **Grabbar colours** come from Hyprland options, not its shell theme push
  (which never arrived here).
- **`fc-match` misreads hyphens** (`system-ui` becomes family `system`,
  size `ui`); escape them: `fc-match 'system\-ui'`.
- **Screenshots for verification:** `grim -s 0.5` into the scratchpad;
  `omarchy-capture-screenshot` has no `--help` and takes a real screenshot.
- Josh allows closing idle apps (e.g. Dolphin) to apply settings; avoid
  anything holding unsaved work.

## 2026-09-22 — Status line showing context used

- **Request:** show context usage in the Claude Code window, like Josh's
  Windows setup (`[Opus 5] 72% ctx`).
- **Actions:** `~/.claude/statusline.sh` (copy in
  [setup/claude/statusline.sh](setup/claude/statusline.sh)) prints
  `[<model>] <N>% ctx` from the status-line JSON on stdin
  (`context_window.used_percentage`, else `total_input_tokens /
  context_window_size`, else just the model). `~/.claude/settings.json` gained
  `"statusLine": {"type": "command", "command": "bash \"$HOME/.claude/statusline.sh\""}`;
  backup `~/.claude/settings.json.bak.20260922`.
- **Verification:** settings JSON valid and every other key unchanged; sample
  payloads print `[Opus 5.5] 72% ctx`, `[Opus 5.5] 25% ctx`, and
  `[Opus 5.5]`. Shows from the next prompt or restart.
- **Undo:** delete the `statusLine` key (or restore the backup).

## 2026-09-24 — Tooltips, Sunshine, browsers: working notes

The work is logged in `setup/windows-style/TASKBAR.md`, `setup/sunshine/`,
`setup/apps/`, and [MACHINE.md](MACHINE.md). Lessons for future sessions:

- **Testing hover in the bar:** `hyprctl dispatch 'hl.dsp.cursor.move({x=…, y=…})'`
  warps the pointer (the old `movecursor x y` syntax is rejected), but a warp
  within the same layer surface sends no motion, so Quickshell never sees the
  move. For real motion, create a temporary uinput mouse from Python
  (`/dev/uinput` is writable by the desktop user via Sunshine's udev rule):
  [`setup/claude/vmouse.py`](setup/claude/vmouse.py) `<target-x>` moves right
  until the cursor reaches that x. Coordinates are logical
  (physical ÷ 1.6); a `grim -s 0.5` screenshot is physical ÷ 2.
- `grim -g` takes `"x,y WxH"`, not `"x,y W,H"`.
- **OmaPanel's bundler isn't reproducible here:** `scripts/bundle-qml.py`
  needs `/usr/lib/qt6/bin` on PATH for `qmlformat`, and even then its output
  differs from upstream's bundle. Hand-edit `BarWidget.qml` and the matching
  `src/` or `taskbar/` file, then check the patches rebuild the live files
  from a clean clone.
- `qmllint` on OmaPanel's bundle ran for over 2 minutes; don't run it inline.
- **`pkill -f <pattern>` kills its own shell** when the pattern appears in the
  command line (exit 144). Use `pgrep` first, or a pattern that can't match
  itself.
- Found and killed a leftover `pgrep` polling loop from an earlier Claude
  session (the `socket2`/panel diagnosis), still writing to an old scratchpad.
  Stop diagnostic loops before a session ends.
- **Password prompts:** run `pkexec` in the background with `notify-send`
  first, tell Josh, and wait for the completion notice. One script per
  prompt covers several steps.
- **Omarchy's edge repo** (`https://pkgs.omarchy.org/edge/x86_64/`) can supply
  a fix before stable. Verify with
  `gpg --homedir /etc/pacman.d/gnupg --verify <pkg>.sig <pkg>` (the keyring is
  readable without root).
- **Memory diagnosis:** the kernel OOM report's `Mem-Info` line
  (`shmem:`, `gpu_active:`) and `/proc/meminfo`'s `GPUActive`/`GPUReclaim`
  show GPU buffers that no process's RSS or cgroup accounts for.
