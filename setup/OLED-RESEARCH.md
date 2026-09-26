# OLED protection research — 2026-09-22

Research only; no installation or display setting changes approved or applied.

Observed display: Samsung ATNA53JB01-0 on eDP-1. Current shell configuration:
screensaver 150 seconds, lock 300 seconds. Those settings alone do not prove
that the panel turns off. No screen shader currently configured. `brightnessctl`
is installed; `hypridle` is not.

## Candidates

### Follow-up: actual bar pixel shifting

Found [Pixel Shift for Omarchy](https://github.com/evindor/omarchy-pixel-shift),
version 1.0.0, requiring Omarchy 4.0.2+. It moves the built-in bar's widget
sections on a timer (180 seconds by default). Left/right sections travel ±2
logical pixels; the center travels ±1. The current 2x display scale doubles
these physical distances. QML source handles horizontal and vertical bars.
Because OmaPanel is inside the built-in bar, it appears compatible with our
bottom taskbar; this remains an inference until tested. It moves bar contents,
not the whole desktop, and does not dim or blank the panel. Small shifts are
only mitigation: large solid icon regions still overlap between positions.
Best-matched candidate for the user's concern about taskbar icons. No install
or live test performed; explicit approval is required before proceeding.

### Other candidates

- [hyproled](https://github.com/mklan/hyproled): Hyprland shader that blacks out
  alternating pixels, optionally restricted to a bar-sized region. Its shift
  option swaps the affected pixels; this is not physical panel refresh or
  shifting the entire desktop. Current source supports Hyprland's Lua config.
  Tradeoffs: dimming/checkerboard appearance, possible text-quality impact,
  and competition with other screen shaders. Effectiveness has not been
  measured here; do not promise burn-in prevention.
- [OLED Saver](https://github.com/esleghel/oled-saver): tray app with idle
  blanking/dimming, monitor selection, and media exceptions. Documents Linux
  support for KDE/GNOME. Source `platform/__init__.py` chooses GNOME for any
  non-KDE Linux session, including Hyprland. Not a verified fit for this machine.
- [hypridle](https://wiki.hypr.land/Hypr-Ecosystem/hypridle/): Hyprland idle
  manager suitable for timed dimming/display-off and wake actions. It is not an
  OLED repair utility. Any adoption needs coordination with the existing
  Omarchy idle service to avoid competing lock/dim timers.

Suggested first proposal: automatic dimming after 60 seconds and panel-off
after 3 minutes of inactivity, respecting video/presentation inhibitors and
restoring brightness on input. These are proposed settings, not applied ones.
For protection while actively working, evaluate hyproled on the static taskbar
only, with an easy off switch, if the user accepts its visual tradeoff.

No app was installed and none of these candidates was live-tested. Floating
windows and title-bar controls remain a separate pending desktop discussion.
