# Wallpaper, screensaver, and clock

## Wallpaper: Dark Waters

Josh disliked the ASCII-style Omarchy logo wallpaper and remembered an
earlier grey-and-black textured one. **Cause of the change:** every
`omarchy theme set` advances to the theme's next background
(`choose_theme_background` in `omarchy-theme-set`), and Vantablack was
re-applied several times during the icon work, cycling to `omarchy.png`.

From a contact sheet of 16 abstract backgrounds shipped with Omarchy's themes
he chose **matte-black `1-dark-waters.jpg`** (black-and-grey ocean texture):

```bash
mkdir -p ~/.config/omarchy/backgrounds/vantablack
cp /usr/share/omarchy/themes/matte-black/backgrounds/1-dark-waters.jpg \
   ~/.config/omarchy/backgrounds/vantablack/0-dark-waters.jpg
omarchy theme bg set ~/.config/omarchy/backgrounds/vantablack/0-dark-waters.jpg
```

`~/.config/omarchy/backgrounds/<theme>/` is Omarchy's per-theme user folder,
so the image also appears in the background switcher (Win+Ctrl+Space).
Re-applying the theme would move to the next background; avoid
`omarchy theme set` unless needed, or re-run the `bg set` line.

## Screensaver: drifting nebula

Josh found Omarchy's ASCII screensaver obnoxious. First choice was a
landscape slideshow (a reviewed copy of `jkwuc89/omarchy-wallpaper-screensaver`
@ `2c940bc`, using `swayimg`); he then asked for **one image (ethereal
`1-cosmic.jpg`) with gentle movement**, so the approach changed and `swayimg`
was removed again.

- **Video:** rendered once with ffmpeg from the 5120×2880 source, cropped to
  16:10 and upscaled 2× for smooth sub-pixel motion, then `zoompan` with
  sine-based drift and zoom whose periods divide 60 s, so the loop is
  seamless: 60 s, 2880×1800, 30 fps, H.264, 40 MB, stored with the source image
  in `~/.local/share/omarchy-setup/screensaver/` (hidden on purpose; see
  below).

  ```bash
  magick ethereal-1-cosmic.jpg -gravity center -crop 4608x2880+0+0 +repage -resize 200% -quality 95 cosmic-2x.jpg
  ffmpeg -i cosmic-2x.jpg -vf "loop=loop=-1:size=1,zoompan=z='1.15+0.04*sin(2*PI*on/1800)':x='(iw-iw/zoom)/2+420*sin(2*PI*on/1800)':y='(ih-ih/zoom)/2+250*cos(2*PI*on/900)':d=1:s=2880x1800:fps=30,format=yuv420p" \
    -frames:v 1800 -c:v libx264 -preset medium -crf 20 -movflags +faststart cosmic-drift.mp4
  ```

- **Launcher:** [`screensaver/omarchy-launch-screensaver`](screensaver/omarchy-launch-screensaver)
  (structure adapted from jkwuc89's MIT-licensed launcher,
  [`LICENSE.jkwuc89`](screensaver/LICENSE.jkwuc89)) runs `mpv` full-screen
  and looped with app id `org.omarchy.screensaver`, which Omarchy's idle
  service tracks. Installed to `~/.local/lib/omarchy-overrides/bin/`, a folder
  that holds only deliberate overrides of Omarchy commands.
- **Dismissal:** [`screensaver/screensaver-mpv-input.conf`](screensaver/screensaver-mpv-input.conf)
  → `~/.config/omarchy/screensaver-mpv-input.conf`: any typed character, named
  keys, clicks, and scrolling quit. `UNMAPPED` was tried first and closed the
  screensaver instantly (it fires on startup events). Mouse movement does not
  dismiss it.
- **Making the idle service use it:** the idle service runs
  `bash -lc "… || omarchy-launch-screensaver"`. A login shell's PATH comes
  from `~/.bashrc`'s Omarchy bootstrap, which puts `/usr/share/omarchy/bin`
  first, so `~/.bash_profile` now prepends the override folder *after*
  sourcing `.bashrc` ([snippet](screensaver/bash_profile-snippet.sh); backup
  `~/.bash_profile.bak.<epoch>`). `windows_style.lua` also prepends it for
  commands Hyprland starts.
- **Verified:** with the shell's own PATH, `bash -lc 'command -v
  omarchy-launch-screensaver'` resolves the override; launching it opened a
  full-screen `org.omarchy.screensaver` window; two screenshots 6 s apart
  showed the drift; a synthetic keypress (`wtype a`) closed it and the
  launcher exited.
- **Covering the taskbar (fixed):** Josh noticed the idle screensaver left
  the taskbar visible (bad for the OLED). The window had ended up floating
  1440×900 instead of fullscreen: the float/maximize handling interfered with
  mpv's and Omarchy's fullscreen request (the idle run at 15:25 logged a
  fullscreen event that the maximize handler converted). Fixes: the maximize
  handler ignores `org.omarchy.screensaver`, and the launcher now waits for
  each screensaver window, sets it fullscreen with
  `hl.dsp.window.fullscreen({ … mode = "fullscreen" })`, and focuses it (without
  focus, keys could not dismiss it). Verified: fullscreen 2 at 1800×1125, the
  taskbar area shows the nebula, focused, and a keypress closes it.
- **Why hidden storage:** the first screensaver files had been put in new
  `~/Pictures/Screensaver` and `~/Videos/Screensaver` folders, which were
  removed in an unrelated clean-up of the home folder. They were recovered
  into the hidden folder, where a tidy-up of user folders can't reach them.
  (`~/.config/user-dirs.dirs` still names folders that no longer exist; open
  item in REQUESTS.md.)
- **Undo:** `rm ~/.local/lib/omarchy-overrides/bin/omarchy-launch-screensaver`
  (Omarchy's ASCII screensaver returns immediately); optionally remove the
  `~/.bash_profile` snippet, `~/.config/omarchy/screensaver-mpv-input.conf`,
  and `~/.local/share/omarchy-setup/screensaver/`.

## Clock with date

Josh asked for the date under the clock. The clock widget's `format` is a Qt
date format, and a newline gives two lines in the 34px bar:

```bash
omarchy bar set omarchy.clock format '"h:mm AP\nM/d/yyyy"' --json
```

Shows e.g. "1:32 PM" over "9/22/2026" (Windows US style; the time is now
12-hour, previously `dddd HH:mm`). Right-click the clock still cycles formats.
Verified by screenshot. Undo: set `format` back to `"dddd HH:mm"`.
