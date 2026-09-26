# Telegram and WhatsApp — 2026-09-22

Josh requested Telegram and WhatsApp.

## Telegram

Installed the official Telegram Desktop client from Arch extra using
`omarchy pkg add telegram-desktop` with graphical privilege escalation.

New packages:

- telegram-desktop 7.2.5-1
- ada 4.0.0-1
- libcbor 0.14.0-1
- libfido2 1.17.0-1

The executable is capitalized `Telegram` (not `telegram-desktop`). Launched with
`uwsm-app -- Telegram`; Hyprland reported a mapped `org.telegram.desktop` window.
The menu entry is `/usr/share/applications/org.telegram.desktop.desktop`.
User account login was left to Josh.

Official project: https://desktop.telegram.org/

To reproduce, install the same package and open Telegram from the application
menu. To undo, close Telegram and use `sudo pacman -R telegram-desktop`; review
whether dependencies are still needed before removing them. User profile data
is separate from the package and should be preserved unless explicitly deleting it.

## WhatsApp

Omarchy already had `~/.local/share/applications/WhatsApp.desktop`, launching
`omarchy-launch-webapp https://web.whatsapp.com/` with icon `whatsapp`.
Retained this existing launcher; no additional wrapper package was installed.
This is the official WhatsApp Web service in a browser app window, not a native
WhatsApp Linux desktop client.

Launched with `omarchy launch webapp https://web.whatsapp.com/`. Hyprland reported
a mapped `chrome-web.whatsapp.com__-Default` window. Inspected the window and
confirmed that the login/link-device QR screen loaded. The QR screenshot was
not added to the repository. No messages were sent or accounts linked.

Official service: https://web.whatsapp.com/

On another Omarchy machine, if the launcher is missing, create it using:

```bash
omarchy webapp install "WhatsApp" "https://web.whatsapp.com/" "whatsapp"
```

The launcher predates this task, so no rollback is needed. If intentionally
removing it later, use `omarchy webapp remove WhatsApp`; this does not automatically
unlink the device or remove browser site data. Browser default and taskbar pins
were not changed by this installation.
