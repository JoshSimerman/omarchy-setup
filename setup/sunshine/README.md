# Sunshine: stream this laptop to the Windows PC

Josh wants to use this laptop remotely from his Windows PC. Sunshine is the
host (on this laptop) and Moonlight is the client (on Windows). Parsec can't
be used for this: on Linux it can only connect to other machines, not host.

## Status (2026-09-24)

| Step | Who | State |
| --- | --- | --- |
| Install `sunshine` | Codex | Done 2026-09-23 |
| Start at login | Claude | Done |
| Firewall rules | Claude, Josh entered password | Done |
| Security update to 2026.914.233613 | Claude, Josh entered password | Done 2026-09-24 |
| Web UI username and password | Josh | Done 2026-09-24 |
| Moonlight on Windows, then pair | Josh | Done 2026-09-24 |
| Memory guard after the lock-screen incident | Claude | Done 2026-09-24 |
| Tailscale login, for use away from home | Josh | To do (optional) |

## Install (Codex, 2026-09-23)

Codex ran `pkexec omarchy-pkg-add sunshine`, which installed
`sunshine 2026.516.143833-4.1` from the `[omarchy]` repo plus `miniupnpc`
and `numactl`. Codex ran out of quota while it waited for Josh to enter his
password, so it never configured anything. Its package list from before the
install is at `~/.cache/omarchy-setup/sunshine/packages-before.txt`.

The package already provides what Sunshine needs:

- `/usr/bin/sunshine` has `cap_sys_admin,cap_sys_nice=p`.
- The udev rule `60-sunshine.rules` gives the logged-in user access to
  `/dev/uinput` (a `user:<you>:rw-` ACL), which Sunshine uses to create the
  remote keyboard, mouse, and gamepad.
- The user service `app-dev.lizardbyte.app.Sunshine.service` (alias
  `sunshine.service`).

## Start at login (Claude, 2026-09-24)

```bash
systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service
```

The service is wanted by `graphical-session.target`, so it starts with
Hyprland. The first start log showed:

- Capture: Hyprland's `zwlr_screencopy` (the `wlgrab` path), eDP-1
  2880×1800 (logical 1800×1125).
- Encoders: Intel VAAPI `h264_vaapi`, `hevc_vaapi`, `av1_vaapi`. The CUDA
  errors come from probing for NVIDIA and can be ignored.
- It advertises itself on the LAN over Avahi and adds a tray icon.
- Listening on Sunshine's default TCP ports, including the web UI.

`~/.config/sunshine/sunshine.conf` (copy: [`sunshine.conf`](sunshine.conf)) holds one setting, `capture = wlr` (see
the security update below). Everything else is on defaults.

## Security update (2026-09-24)

When Josh first logged in to the web UI, it warned of a high-severity fix for
Linux hosts,
[GHSA-fp6g-27w5-489j](https://github.com/LizardByte/Sunshine/security/advisories/GHSA-fp6g-27w5-489j):
before v2026.914.233613, the Qt tray could load GUI modules named in
environment variables, so a local user who controlled Sunshine's launch
environment could run code with its `CAP_SYS_ADMIN`. It is local only; network
access alone isn't enough.

Omarchy's stable repo still had 2026.516.143833-4.1; its **edge** repo had
2026.914.233613-1. Installed the edge build, which pacman's keyring
trusts:

```bash
cd ~/.cache/omarchy-setup/sunshine/omarchy-edge
curl -fLO https://pkgs.omarchy.org/edge/x86_64/sunshine-2026.914.233613-1-x86_64.pkg.tar.zst{,.sig}
gpg --homedir /etc/pacman.d/gnupg --verify *.sig *.zst   # Good signature from "Omarchy <pkgs@omarchy.org>"
pkexec pacman -U --noconfirm "$PWD/sunshine-2026.914.233613-1-x86_64.pkg.tar.zst"
systemctl --user restart app-dev.lizardbyte.app.Sunshine.service
```

Its SHA-256 (`4f23dc77…961b`) matches the edge repo database. LizardByte's
own Arch package for the release (`17eb8c4d…ba87`, matching GitHub's
digest, in `~/.cache/omarchy-setup/sunshine/`) was checked but not used.
When Omarchy stable reaches this version, normal updates take over. pacman
won't downgrade in the meantime.

The new version tries the desktop portal's RemoteDesktop capture first.
`xdg-desktop-portal-hyprland` doesn't provide it, so startup stalled for 20 s
on a screen-picker request before falling back to `wlgrab`. Setting
`capture = wlr` goes straight to `wlgrab`, and startup now takes about a
second. "Failed to gain CAP_SYS_ADMIN" lines in the log are the fix dropping
the capability, and `wlgrab` doesn't need it. Verified: all of Sunshine's TCP
ports listening; H.264, HEVC, and AV1 VAAPI encoders found.

## Firewall

ufw is active and drops incoming traffic by default. [`ufw-rules.sh`](ufw-rules.sh),
run with `pkexec`, opens Sunshine's default TCP and UDP ports only to the home
LAN subnet (set `LAN_CIDR` when running it) and to the `tailscale0` interface.
Nothing is opened to other networks.

Applied 2026-09-24; `ufw status` shows four `# sunshine` rules (plus IPv6
copies for `tailscale0`).

The web UI port is included so pairing can be done from the Windows PC's
browser. The web UI requires a username and password.

## Incident: memory exhausted during an unattended stream (2026-09-24)

Josh left Moonlight connected and walked away. From the journal and kernel
OOM reports:

- 20:20 stream started from the PC; 20:31 screensaver; 20:34 the
  lock screen came up. The stream kept running.
- By 21:20 RAM was full and 60 of 66 GB of swap was used. `systemd-oomd`
  killed a terminal scope (22 processes, open since 2026-09-22, including a
  Claude Code session). From 21:28 to 21:32 the kernel OOM killer took Claude
  Desktop, Chromium, ChatGPT, VS Code, and voxtype. One of the allocations
  that triggered it came from Sunshine's `stream::recv` thread.
- The memory wasn't in any app: the OOM reports show `shmem` 14–16.6 GB and
  `gpu_active` 7–26 GB with almost nothing mapped, and oomd's per-cgroup swap
  figures add up to only a few GB. Those are graphics buffers, and they grew
  by about one 2880×1800 frame (21 MB) per second.
- 21:32 the client timed out. 21:47 a reconnect left Sunshine unable to end
  the session ("Hang detected! Session failed to terminate in 10 seconds"),
  so it aborted and systemd restarted it. The memory came back (shmem
  75 MB, GPUActive 0.8 GB). Josh had to go to the laptop to unlock it.

So the leak is tied to Sunshine's screen capture. Whether the lock screen
causes it is still to be tested; see "Leak test" below.

### Leak test (pending)

[`leak-test.sh`](leak-test.sh) `<logfile>` waits up to 40 min for a
Moonlight client, logs `Shmem`, `GPUActive`, `GPUReclaim`, `MemAvailable`,
and `SwapFree` every 5 s for 3 min unlocked, then runs
`omarchy-system-lock` and logs 3 min locked. Growth only in the locked half
would confirm the lock screen as the trigger. The first run (2026-09-24
21:55) timed out because nobody connected. The memory guard stays on during
the test.

### Memory guard

[`sunshine-memguard.sh`](sunshine-memguard.sh) → `~/.local/bin/sunshine-memguard`,
run by [`sunshine-memguard.service`](sunshine-memguard.service) →
`~/.config/systemd/user/` (enabled; starts with the graphical session).
Every 5 s, if Sunshine is running and `Shmem + GPUActive` in
`/proc/meminfo` passes 6 GB (normally under 1 GB), or free memory drops
below 3 GB once those buffers pass 2 GB, it `SIGKILL`s and restarts Sunshine
and shows a critical notification. A plain stop can hang for Sunshine's 10 s
detector plus systemd's 90 s. At 21 MB/s it triggers about 4 minutes into a
leak, long before other apps are at risk. Moonlight can reconnect straight
away.

Tested with the limit set to 0: it restarted Sunshine (new PID), all its
ports came back, and the notification showed. Logs:
`journalctl --user -u sunshine-memguard`. Undo:
`systemctl --user disable --now sunshine-memguard`, then delete the two
files.

## Josh: finish setup

1. **Web UI login.** On this laptop, open <https://localhost:47990>, accept
   the self-signed certificate warning, and choose a username and password.
   They're kept in `~/.config/sunshine/sunshine_state.json`. Don't copy that
   file into this repo.
2. **Moonlight on Windows.** Install Moonlight from
   <https://moonlight-stream.org>. The laptop should appear automatically; if
   it doesn't, add its LAN IP address by hand.
3. **Pair.** Click the laptop in Moonlight. It shows a 4-digit PIN. Enter it
   in the Sunshine web UI's **PIN** tab, either on the laptop or from the
   PC's browser at the laptop's address.
4. Start **Desktop** in Moonlight.
5. **Away from home (optional).** Log in to Tailscale on the laptop
   (`tailscale up`, or the Tailscale tray from Start) and on the Windows PC,
   then add the laptop's Tailscale IP in Moonlight.

## Moonlight settings (on the PC)

The first session asked for only 7.3 Mbps, which looked blurry. Suggested:
resolution to match the PC monitor (or Native), 60 FPS, bitrate about
40 Mbps (the laptop is on Wi-Fi; up to 80 if smooth), **Windowed** or
**Borderless windowed**, HEVC (AV1 if the PC's GPU decodes it), "Optimize
mouse for remote desktop" on, and "Capture system keyboard shortcuts" set to
fullscreen only. Shortcuts: Ctrl+Alt+Shift+X to toggle full screen and
Ctrl+Alt+Shift+Z to release the mouse and keyboard. Ctrl+Alt+Shift+Q ends
the session.

## Things to know

- **Keep the lid open.** Closing the lid locks and suspends the laptop, and
  then there's nothing to stream. Changing logind's `HandleLidSwitch` would
  keep it awake with the lid shut; not done.
- **Idle.** Omarchy starts the screensaver after 150 s and locks after
  300 s, but never turns the screen off or suspends. Sunshine can capture the
  lock screen, so unlock it through Moonlight with your password.
- The laptop's own screen shows the same thing as the stream: Sunshine
  mirrors the desktop and does not create a separate one.
- **End the Moonlight session (Ctrl+Alt+Shift+Q) before walking away.**
  See the incident above.

## Undo

```bash
systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service
sudo ufw status numbered        # then `sudo ufw delete <n>` for each "sunshine" rule
sudo pacman -Rns sunshine
rm -r ~/.config/sunshine        # paired clients and web UI login
```
