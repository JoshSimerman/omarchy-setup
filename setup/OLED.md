# OLED burn-in protection

The laptop's screen is a Samsung ATNA53JB01-0 OLED (eDP-1, 2880×1800, 160%
scaling). Josh wants the taskbar and desktop icons protected from burn-in.
This page is the index and running log for everything OLED-related. Details
live in the linked docs.

## What is active

| Protection | How | Details |
| --- | --- | --- |
| Taskbar content shifts ±2 px (centre ±1) every 3 min, pausing while the bar is in use | `josh.bar`: a patched copy of Omarchy's bar, set as the active bar; `oledShiftEnabled`/`oledShiftIntervalSeconds` in `shell.json` | [oled-bar-proposal](oled-bar-proposal/README.md) |
| Desktop icons and labels shift up to 2 px every 3 min, without moving their saved positions | Patch to the `henri.desktop-icons` plugin | [oled-desktop-icons](oled-desktop-icons/README.md) |
| Automatic check after every `omarchy update` | [`oled-check.hook`](oled-check.hook), a post-update hook | below |
| True-black theme (Vantablack) | Black pixels are off on an OLED | [APPEARANCE.md](windows-style/APPEARANCE.md) |
| Screensaver after 150 s, lock after 300 s | Omarchy defaults, unchanged | [OLED-RESEARCH.md](OLED-RESEARCH.md) |

Not protected: application windows and the taskbar's background don't
shift. This reduces wear on the static taskbar and icons; it doesn't
guarantee there will be no burn-in.

## Checking it

```bash
~/omarchy-setup/setup/oled-check.hook
# OLED shifting OK: taskbar (josh.bar) and desktop icons
```

The same script runs at the end of every `omarchy update`. It shows a
critical notification if:

- `josh.bar` is no longer the active bar, has lost its shift code, or
  `oledShiftEnabled` isn't `true`;
- Omarchy's packaged `Bar.qml` no longer matches the SHA-256 the patch was
  made against. `josh.bar` then keeps running the old bar and misses
  Omarchy's bar changes, so rebase `bar-pixel-shift.patch` onto the new
  `Bar.qml` and re-clone;
- the desktop-icons plugin lost its OLED patch (e.g. after
  `omarchy plugin update`). Re-apply it in the order Dolphin → OLED → sizes →
  keyboard → double-click (see `windows-style/install.sh`).

Installed with `omarchy hook install post-update
~/omarchy-setup/setup/oled-check.hook` →
`~/.config/omarchy/hooks/post-update.d/oled-check.hook`. The hook runner
catches failures, so a failed check can't interrupt an update.

## Repeat on another machine

[`windows-style/install.sh`](windows-style/install.sh) applies both shifts. It
patches the bar only when the machine's `Bar.qml` matches
[`base-sha256.txt`](oled-bar-proposal/base-sha256.txt), and otherwise prints
a warning. Then install the hook as above.

## Log

Newest first.

- **2026-09-25 (Claude)** — Audit. Both shifts are live. Omarchy is still
  4.0.4-1, and the packaged `Bar.qml` still matches the base hash
  (`9874c0f3…590b`). Both setups rebuild exactly from the repo: the packaged
  bar plus `bar-pixel-shift.patch` equals `josh.bar` (only the clone's
  `manifest.json` id/name differ). Upstream `474cbd3` plus the Dolphin, OLED,
  sizes, and keyboard patches equals the live desktop-icons plugin. Found
  that `windows-style/install.sh` skipped the OLED icon patch; without it
  the later patches still apply, so icons would silently stop shifting. Added
  it, plus the guarded bar step. Added `oled-check.hook` as a post-update
  hook and this page.
- **2026-09-22 12:16 (Codex, `f47b6fa`)** — Desktop-icon shifting applied and
  verified by measurement. Real mouse hover, drag, and rename during a
  shift were not exercised.
- **2026-09-22 11:34 (Codex, `7f8abe1`)** — Bar shifting applied through the
  `josh.bar` clone. Movement measured live (clock x 1679 → 1681 → 1683).
- **2026-09-22 11:08 (Codex, `3647e5e`)** — Bar adaptation prepared for
  review.
- **2026-09-22 11:05 (Codex, `5072896`)** — Community plugin
  `io.github.evindor.pixel-shift` tried; it loads but can't move the bar on
  Omarchy 4.0.4. It stays installed but disabled.
  [Trial](OLED-PIXEL-SHIFT-TRIAL.md).
- **2026-09-22 10:33 (Codex, `08d83d7`)** — Research into OLED protection
  options. [Research](OLED-RESEARCH.md).
- **2026-09-22 (Claude)** — Other OLED-driven choices: Vantablack true-black
  theme, and the Selawik font removed because of colour fringing on the
  OLED. [APPEARANCE.md](windows-style/APPEARANCE.md).
