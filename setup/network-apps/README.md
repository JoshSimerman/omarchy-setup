# Proton VPN, Tailscale, and Parsec — 2026-09-22

Josh explicitly requested installation of all three applications.

| Application | Package | Installed version | Source |
| --- | --- | --- | --- |
| Proton VPN GUI | proton-vpn-gtk-app | 4.18.1-1 | Arch extra, community maintained |
| Tailscale | tailscale | 1.102.3-1 | Arch extra |
| Parsec | parsec-bin | 150_104a-1 | AUR, repackages upstream binary |
| Parsec dependency | ffmpeg4.4 | 4.4.8-5 | Arch extra |

The package transaction added 60 repository packages and one Parsec package.
The accompanying `installed-2026-09-22.txt` records packages added during this
installation, including dependencies. NetworkManager and GNOME Keyring were
already installed; NetworkManager was active.

## Installation and repeat steps

```bash
omarchy pkg add proton-vpn-gtk-app tailscale ffmpeg4.4
```

For this agent session, the underlying `omarchy-pkg-add` command was run through
`pkexec` for graphical authentication. No full system upgrade was performed.
Proton's package enabled and started `proton.VPN.service` during installation.

Reviewed the entire Parsec PKGBUILD from AUR revision
`ec92048c3a078f656256e37fc9ce1afe6bfaf3c6`. It downloads the official
`https://builds.parsec.app/package/parsec-linux.deb`, verifies SHA-256
`c8a4407713d72dcb1c59f082977e81e1b9e8ffd679d0666882cde4c8a0821dd2`,
and extracts its packaged files. Source verification passed. Built as Josh
using `makepkg --noconfirm`, then installed the exact resulting archive with
`pkexec pacman -U --noconfirm`. Checkout and artifact are under
`~/.cache/omarchy-setup/network-apps/parsec-bin/`.

On another machine, review the current AUR recipe before building/installing
`parsec-bin` (or using `omarchy pkg aur add parsec-bin`). Versions and upstream
download checksums may change; do not bypass checksum failures.

Enabled Tailscale's daemon at boot and allowed the local user to manage it:

```bash
sudo systemctl enable --now tailscaled
sudo tailscale set --operator="$USER"
```

Added `~/.local/share/applications/tailscale.desktop` (copy alongside this guide)
for Start menu access to the built-in `tailscale systray` control. Started that
tray control for this session; no tray autostart entry was added. On a new
machine copy this launcher into the local applications directory and run
`update-desktop-database ~/.local/share/applications`.

## Use and verification

- Proton VPN: open **Proton VPN** from Start and sign in. `protonvpn-app`
  created a mapped window and initialized disconnected; the tray initialized.
- Tailscale: open **Tailscale** from Start to show its tray control, then use its
  login action. Alternatively run `tailscale up` in a terminal and follow the
  browser login link. Version check passed; `tailscaled` is enabled and active.
  Status was **Logged out** at verification. The initial tray attempt reported
  missing management permission; setting the desktop user as operator
  resolved that error.
- Parsec: open **Parsec** from Start and sign in. The packaged launcher is
  `parsecd.desktop`, command `/usr/bin/parsecd`. An initial `uwsm-app` invocation
  exited with status 2; directly launching `parsecd` produced a mapped Parsec
  window. Startup warned that the NVIDIA VDPAU backend was unavailable, but
  the window opened. Actual remote streaming/decoder behavior is untested.

No account credentials, login URLs, or VPN profiles are recorded here. Sign-in,
VPN connectivity, simultaneous Proton/Tailscale operation, and Parsec remote
sessions remain untested. No exit node, advertised subnet, or Tailscale SSH
configuration was enabled during this installation.

Parsec on Linux is a client only: it can connect to another supported host but
cannot host this machine. Upstream documents XWayland compatibility; its listed
Linux support targets Ubuntu. See [Parsec installation](https://support.parsec.app/hc/en-us/articles/32381552552340-Install-Parsec-App-on-Linux)
and [Linux details](https://support.parsec.app/hc/en-us/articles/32381494397332-Parsec-App-for-Linux).
Proton documents the community Arch package and required services in its
[Arch guide](https://protonvpn.com/support/linux-vpn-arch).
Tailscale's [CLI guide](https://tailscale.com/kb/1080/cli) covers login and management.

## Undo

Disconnect and close the apps first. If this machine has since joined a tailnet,
log it out and remove its device entry as appropriate before uninstalling.

```bash
sudo tailscale set --operator=
sudo systemctl disable --now tailscaled proton.VPN
sudo pacman -R proton-vpn-gtk-app tailscale parsec-bin
rm ~/.local/share/applications/tailscale.desktop
update-desktop-database ~/.local/share/applications
```

Review dependencies before removing them; the inventory is a record, not a
blanket removal list. In particular, remove ffmpeg4.4 or Proton components only
if no other installed applications need them. Package removal does not erase
application profiles or credentials. Preserve later changes by other agents.
