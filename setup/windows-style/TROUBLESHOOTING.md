# Troubleshooting

## Typing stops working in a window that still looks focused

**Symptom (Josh, 2026-09-22):** the terminal cursor turns from a solid block
into a hollow box and typing goes nowhere. The window's title bar stays blue
(Hyprland still reports it as the active window), and clicking inside it does
not help; only clicking another window and back restores typing.

**Cause:** an Omarchy shell panel (layer namespace `omarchy-keyboard-panel`,
used by the Start menu, calendar, audio, and other popups) takes keyboard
focus while it is open, even when it is not visible. Hyprland does not treat
that as a window focus change, so the title bar stays blue and clicking the
same window changes nothing.

**Evidence:** a Hyprland event logger (`socket2`: `activewindowv2`,
`openlayer`, `closelayer`) plus a process watcher for `omarchy-shell` / `qs
ipc` commands showed:

- `omarchy-keyboard-panel` open 11:30:48 to 11:30:58 and 11:32:43 to
  11:33:54 while Josh was typing, with nothing visible on screen;
- at 11:33:44 and 11:33:53, panels opened and closed by commands such as
  `omarchy-shell shell summon io.github.librael-the-culprit.simple-start-menu`
  and `omarchy-shell shell hide omarchy.audio`, whose parent process was
  `codex resume`: Codex measuring popup geometry for its OLED work.

The Win-tap Start-menu binding was a suspect but is not implicated.

**Fix:** press **Esc** (Omarchy panels close on Esc), or click another window
and back. Avoid summoning shell panels from scripts while someone is typing,
and always close them afterwards.

**Second cause, and the fix (later on 2026-09-22):** it kept happening after
Codex's tests stopped, right after Josh closed the new Start menu (App
Launcher, an exclusive-keyboard layer). Josh's Flameshot screenshot
(`~/2026-09-22_15-43.png`) caught it in Claude's own terminal after a test
opened and closed the launcher. With click-to-focus (`input.follow_mouse =
2`) Hyprland does not hand the keyboard back to the still-"active" window when
such a layer closes; with Omarchy's default (focus follows mouse) moving the
mouse hides the problem. Fix in `windows_style.lua`: a `layer.closed` handler
re-focuses the active window (`hl.dsp.focus({ window = "address:…" })`), which
re-sends keyboard focus. **Tested** with a throwaway foot window that writes
its input to a file: it received text typed before and after opening and
closing the Start menu.

**Third case, after the screensaver:** the log showed the idle screensaver
closing at 15:52:53, focus briefly returning to the terminal, then going to
no window at all (`activewindow>>,`), most likely the dismissing click
landing on the desktop-icons layer. The screensaver launcher now remembers
the focused window when it starts and re-focuses it 0.4 s after the
screensaver closes (as Windows returns to the previous window). **Tested**:
focus test window → screensaver (fullscreen, focused) → keypress → focus back
on the test window, which received the next typed text.

**Fourth cause, clicking the desktop (the one Josh could trigger at will):**
the desktop-icons plugin's full-screen layer requested keyboard focus
`OnDemand`, so a click on the wallpaper moved the keyboard to it while
Hyprland kept the window "active" (title bar still highlighted). Clicking the
window again changed nothing because Hyprland saw no focus change. Local
patch [`desktop-icons-keyboard.patch`](desktop-icons-keyboard.patch): the
layer asks for the keyboard only while renaming, a menu, or the trust prompt
is open; otherwise `None`. **Confirmed fixed by Josh** (click desktop, click
back, type).

The `layer.closed` re-focus now waits 150 ms (`hl.timer`), since an
immediate re-focus was lost once in practice. A 15-round test (Start menu
closed by Esc, by toggling, and opened from the bar) delivered all 15 typed
markers to a throwaway window. A baseline run with the fix disabled was
interrupted by Josh; its first step had already disabled the fix, which was
immediately restored from a saved copy.

**Loggers used** (session-only, in Claude's scratchpad; they stop at logout):
`socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock`
filtered for `activewindowv2|openlayer|closelayer`, and a 0.2 s `ps` poll for
`omarchy-shell |qs ipc`.

## Claude Desktop: "Your sign-in won't be saved on this device"

Josh installed Claude Desktop (`claude-desktop` 2.2553.1-1) and it asked for a
system keyring. GNOME Keyring was already installed, running, owning
`org.freedesktop.secrets`, and its default collection was **unlocked**.
Cause: Electron picks its password store from the desktop name and does not
recognise Hyprland (`XDG_CURRENT_DESKTOP=Hyprland`), so it falls back to no
keyring; Omarchy passes `--password-store=gnome-libsecret` to Chromium for the
same reason.

Fix: the package's launcher (`/usr/bin/claude-desktop`) reads extra flags from
`~/.config/claude-desktop-flags.conf`, now containing
`--password-store=gnome-libsecret` (copy in
[`apps/claude-desktop-flags.conf`](apps/claude-desktop-flags.conf)). Restarted
the app through Hyprland; the main process shows the flag, the app stayed
signed in, and `Default_keyring.keyring` was written 2 s after launch (5 items
in the collection). KDE's `ksecretd` (from the KDE apps) is also running but
does not own the Secret Service name.

Other Electron apps with the same message (VS Code, Obsidian, …) need the same
flag in their own flags file.
