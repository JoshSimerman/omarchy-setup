# NAS as a mapped drive

Josh opened a home NAS in Dolphin as `smb://<nas>.local/…` and found browsing
very slow compared with a Windows mapped drive.

## Why it was slow

1. **Dolphin's `smb://` goes through KIO** (a user-space SMB client via
   libsmbclient) and fetches each item's details separately; a Windows
   mapped drive is a kernel SMB client with caching.
2. **Every `<nas>.local` lookup took 5 seconds.** `/etc/nsswitch.conf` used
   `mdns_minimal`, which also asks for an IPv6 address; the NAS doesn't
   answer that over mDNS, so each lookup waited for the 5 s timeout
   (`avahi-resolve -4` 14 ms, `-6` timeout). Dolphin resolves the name
   repeatedly.

## What was set up (2026-09-22, first share)

- **Credentials:** a file under `~/.config/nas/` (mode 600, folder 700) with
  `username=` / `password=`, filled in by Josh in Kate. Never shown, copied,
  or committed. Checked with `smbclient //<nas>.local/<share> -A …`.
- **Kernel mount with automount** — one line in `/etc/fstab` (backed up
  first), mount point `/mnt/nas/<share>`:

  ```
  //<nas>.local/<share> /mnt/nas/<share> cifs credentials=/home/<user>/.config/nas/nas.cred,uid=1000,gid=1000,file_mode=0644,dir_mode=0755,iocharset=utf8,actimeo=30,_netdev,nofail,noauto,x-systemd.automount,x-systemd.idle-timeout=600,x-systemd.mount-timeout=20 0 0
  ```

  `x-systemd.automount` mounts on first access, `idle-timeout=600`
  disconnects after 10 idle minutes, `nofail`/`noauto` mean boot never waits
  for the network, `actimeo=30` caches file attributes for 30 s (faster
  browsing). Negotiated: SMB 3.1.1, 4 MB read/write size.
- **IPv4-only mDNS:** `/etc/nsswitch.conf` `mdns_minimal` → `mdns4_minimal`
  (backup `/etc/nsswitch.conf.bak.<epoch>`). `getent hosts <nas>.local`:
  5.0 s → 0.07 s. Speeds up every `.local` device, not just the NAS.
- **"Drive letter":** a Dolphin Places entry for the share
  (`folder-network` icon, `file:///mnt/nas/<share>`) in
  `~/.local/share/user-places.xbel`, after Videos (backup `.bak.<epoch>`).
  Also fixed the Desktop place, which pointed at the home folder instead of
  `~/Desktop` (left over from the earlier Desktop-path bug).

**Measured:** first access (mount + login, before the lookup fix) 5.4 s;
listing two levels (223 items) afterwards 0.56 s; Dolphin opened the share and
listed it immediately.

## More shares (2026-09-22)

Josh asked for two more shares from the same NAS (his usual Windows mapped
drives). The same login works for both (checked with `smbclient -A`). Two
lines appended to `/etc/fstab` with the same options (backed up first), a
mount point for each under `/mnt/nas/`, and a Dolphin place for each.
Verified: both automount units active, both mounted as `cifs`, listings
instant, Dolphin showed all three places in the sidebar. A few other shares
were left unmapped.

## Adding another share

Use the same credentials file if the login is the same:

```bash
sudo mkdir -p /mnt/nas/<share>
echo "//<nas>.local/<share> /mnt/nas/<share> cifs credentials=$HOME/.config/nas/nas.cred,uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755,iocharset=utf8,actimeo=30,_netdev,nofail,noauto,x-systemd.automount,x-systemd.idle-timeout=600,x-systemd.mount-timeout=20 0 0" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload && sudo systemctl restart remote-fs.target
```

Then add a Dolphin place (right-click the folder → Add to Places).

## Undo

```bash
sudo umount /mnt/nas/*; sudo cp /etc/fstab.bak.<epoch> /etc/fstab   # the backup from before the first share
sudo systemctl daemon-reload
sudo sed -i 's/mdns4_minimal/mdns_minimal/' /etc/nsswitch.conf
rm -rf ~/.config/nas     # removes the stored NAS password
```

Remove the places in Dolphin with right-click → Remove.
