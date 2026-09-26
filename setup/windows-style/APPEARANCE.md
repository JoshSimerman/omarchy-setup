# Display, theme, icons, and title bars

Requested after the first round ("apps seem too big … I have an OLED and want
to use the true blacks … the title bar blends in"). Josh confirmed scaling,
theme, title bars, and icons were "better now" on 2026-09-22.

## Scaling

200% → **160%** with `omarchy hyprland monitor scaling 1.6`. The 13.3"
2880×1800 Samsung OLED (eDP-1) now behaves like 1800×1125. Omarchy persisted
it in `~/.config/hypr/monitors.lua` (`omarchy_monitor_scale = 1.6`; it keeps
`GDK_SCALE = 2`, as GTK only accepts whole numbers). Backup:
`~/.config/hypr/monitors.lua.bak.<epoch>`. Undo: `omarchy hyprland monitor
scaling 2`.

## Theme

Tokyo Night → **Vantablack**, the only stock theme with a pure `#000000`
background. Undo: `omarchy theme set tokyo-night`.

## Icons

- **Missing icons.** Vantablack's `icons.theme` names `Yaru-gray`, which the
  installed `yaru-icon-theme` 26.04.5.1 does not provide, so taskbar icons
  fell back to capital letters. Fixed with a theme overlay,
  `~/.config/omarchy/themes/vantablack/icons.theme` (copy in
  [`theme-overlay/`](theme-overlay/vantablack/icons.theme)), first set to
  `breeze-dark`. The shell only reads the icon theme at start, so each change
  needs `omarchy theme set vantablack && omarchy restart shell`.
- **Fluent icons** (first postponed idea, "the fluent icons next"):
  - AUR `fluent-icon-theme` 20260727-1 (maintainer ShinKouyo), chosen over
    `fluent-icon-theme-git` because it builds a tagged upstream release
    checked with a b2sum instead of an unchecked latest checkout. Read the
    PKGBUILD (no install hooks) and upstream `install.sh` (copies files only;
    its `rm -rf` is confined to the package directory); the tarball matched
    its checksum.
  - Built as the user with `makepkg` from the AUR repo (commit `a51d54b`) and
    installed with `pkexec pacman -U`, because `yay`'s sudo prompt cannot be
    answered by an agent. Adds 27 variants under `/usr/share/icons/Fluent*`.
  - The overlay now selects **Fluent-dark** (standard blue folders, for dark
    themes). Verified on the taskbar by screenshot. Other variants:
    `Fluent-grey-dark`, `Fluent-teal-dark`, and so on.
- Undo: put `breeze-dark` back in the overlay file (or delete the overlay
  directory to get Vantablack's broken default), re-apply as above, then
  `sudo pacman -Rns fluent-icon-theme`.

## Title-bar colours

**Current: slate focused, near-black unfocused.** Josh liked the #1C1C1C
unfocused bar but wanted the focused one darker than #333333 and clearly
different: focused title bar **#253040** (dark slate blue-grey); unfocused stays
#1C1C1C. Borders later changed to the same colours (see rounded corners). Measured #253040 on
the focused strip; screenshot confirmed.

**Rounded corners** (Josh: "classy, less blocky"): `decoration.rounding = 8`
(Windows 11's radius; Omarchy default 0). Grabbar rounds the title bar's top
corners to the window's rounding. The window's own rounded top corners left a
small curved border line where content meets the title bar (Grabbar draws its
bar outside the border and has no option to move it inside), so the borders
now use exactly the title-bar colours: active #253040, inactive #1C1C1C. The
title bar then flows into a thin frame around the window; only a soft inner
curve remains at the join. Verified with zoomed corner captures.

Earlier steps, kept for the record:

**Current (2026-09-22, later): Windows greys.** From Josh's Windows
screenshots (sampled: Windows Terminal title strip #333333, Explorer title
bar #202020, content #191919) he preferred grey/black to blue, with a clear
active/inactive difference:

- Focused title bar **#333333**, unfocused **#1C1C1C** (Grabbar
  `bar_color` / `inactive_bar_color` in `windows_style.lua`, and the same
  values in the plugin patch); text stays white (Grabbar has one text
  colour).
- Borders 1px: active **#4A4A4A**, inactive **#262626**.
- Grabbar recolours an already-focused strip only on the next focus change;
  after reloading, the focused window updates once focus moves.
- **Stale blue:** Josh still saw blue. Grabbar's compositor plugin keeps
  colours pushed by its shell widget in memory, and they win over the
  Hyprland options. It still held #005FB8 from the earlier blue patch; later
  pushes did not replace it (restarting the shell and Grabbar's
  disable/enable did not help). Fixed by unloading and reloading the plugin
  (`hyprctl plugin unload/load …/grabbar.so`, then `hyprctl reload`), which
  clears that memory; the strip then measured #333333. The plugin patch now
  carries the same greys, so a future push matches.
- Title text font set explicitly (`text_font = "JetBrainsMono Nerd Font"`),
  since without the shell push Grabbar fell back to "Sans".

The blue version below was replaced by this.


Josh asked for blue title bars that stand out from the greys and blacks.

- The focused window's title bar is `#005FB8` (Windows 11 dark-mode accent),
  unfocused ones `#1B2838` (dim navy), with white text.
- Set as Grabbar's Hyprland options in `windows_style.lua`, only while
  Grabbar is loaded, so they cause no config errors at login. After loading
  Grabbar by hand, run `hyprctl reload` to apply them.
- History: a first attempt tinted the bars grey by editing Grabbar's
  `BarWidget.qml`. It had no visible effect. Grabbar's shell part is meant to
  push theme colours to the title bars, but on this machine none arrived, and
  the grey seen was Grabbar's built-in default (`#2a2f36`). Setting the
  Hyprland options turned the bars blue.
- The plugin's local copy still carries
  [`grabbar-local.patch`](grabbar-local.patch) with the
  same blues, in case the shell push starts working (for example after a
  fresh login) and would otherwise paint the bars black. Undo:
  `git -C ~/.config/omarchy/plugins/tech.greyforge.grabbar checkout BarWidget.qml`.

## GTK theme (Fluent) — removed

Second postponed idea, done top to bottom as Josh asked. **Removed the same
day**: Josh found it "not noticeable anywhere" (only GTK apps change, and
Dolphin, Kate, and Gwenview are Qt). Removed the hook and the three
`~/.config/gtk-4.0` links, re-applied Vantablack (GTK back to `Adwaita-dark`),
and ran `pacman -Rns fluent-gtk-theme sassc`. The hook script was deleted from
this repo; it remains in git history. What was done:

- Package: AUR `fluent-gtk-theme` 2025.04.17-1 (maintainer aperez), which
  builds the newest upstream tag, checked with a b2sum. Read the PKGBUILD and
  upstream `install.sh`: it only generates theme folders inside the package;
  it links `~/.config/gtk-4.0` only when passed `-l`, which the PKGBUILD
  does not do. Built with `makepkg` from AUR commit `bb81799`, installed with
  `pkexec pacman -U`; 108 variants in `/usr/share/themes/Fluent*`.
- Needed `sassc` 3.6.2-5 (extra, installed `--asdeps`) to build the rounded
  variants. The PKGBUILD doesn't list it, and without it `install.sh` would
  try `sudo pacman -S sassc` mid-build.
- Selected **Fluent-round-Dark** (Windows 11 rounded corners). Omarchy resets
  `gtk-theme` to `Adwaita-dark` on every theme change, so a theme-set hook,
  `hooks/fluent-gtk.sh` (deleted; in git history), installed with
  `omarchy hook install theme-set …` to
  `~/.config/omarchy/hooks/theme-set.d/fluent-gtk.sh`, sets it again
  (Fluent-round-Light for light themes). It also links Fluent's GTK4
  stylesheet into `~/.config/gtk-4.0/`, because libadwaita apps such as
  Nautilus ignore `gtk-theme`.
- Verified: after `omarchy theme set vantablack`, `gtk-theme` is
  `Fluent-round-Dark` and the three `~/.config/gtk-4.0` links exist; Nautilus
  opened with Fluent styling (screenshot).
- Trade-off: Fluent Dark uses dark greys like Windows 11, not true black, so
  GTK apps are grey on the OLED. Qt/KDE apps (Dolphin, Kate, Gwenview) are
  not affected.
- Undo: `rm ~/.config/omarchy/hooks/theme-set.d/fluent-gtk.sh
  ~/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}`, then
  `omarchy theme set vantablack` and `sudo pacman -Rns fluent-gtk-theme sassc`.

## Interface font (Selawik) — removed

**Reverted the same day.** Josh saw red/blue fringing on Selawik's thin
strokes on the OLED and asked for JetBrains Mono everywhere, as in the
terminal, for consistency. Subpixel antialiasing was already off (GTK
`font-antialiasing` = grayscale, no fontconfig `rgba`), so the fringing is
likely the OLED subpixel layout with thin strokes. Now: GTK/Qt `font-name`
= `JetBrainsMono Nerd Font 9` (terminal size); `60-selawik.conf` removed
(`sans-serif` back to Liberation Sans for web pages); desktop labels back to
the shell font; `pacman -Rns ttf-selawik`. What had been done:

Third postponed idea. Selawik is Microsoft's open-source stand-in for Segoe
UI, the Windows interface font.

- Package: AUR `ttf-selawik` 1-5 (maintainer travisghansen, 16 votes, last
  updated 2020). The PKGBUILD downloads a pinned commit of Microsoft's
  `winjs/bootstrap-winjs` repo, checks it with MD5 (a weak checksum), and
  only copies `.ttf` files and the licence; no install hooks. Built with
  `makepkg` from AUR commit `5144e32`, installed with `pkexec pacman -U`.
  Installs regular, light, semilight, semibold, and bold weights plus
  `winjs-symbols.ttf`.
- `omarchy font set` only changes the **monospace** font (terminals, bar), so
  Selawik is applied separately:
  - GTK and Qt apps: `gsettings set org.gnome.desktop.interface font-name
    'Selawik 11'` (was `Adwaita Sans 11`). Qt apps follow it through
    `QT_QPA_PLATFORMTHEME=gtk3`; `kdeglobals` sets no font of its own.
  - Everything that asks fontconfig for a generic font:
    `fonts/60-selawik.conf` (deleted; in git history), copied to
    `~/.config/fontconfig/conf.d/`. Omarchy's
    `/etc/fonts/conf.d/50-omarchy.conf` runs first and rewrites
    `sans-serif`, `system-ui`, `-apple-system`, and `BlinkMacSystemFont` to
    Liberation Sans, so the rule matches patterns whose first family is
    Liberation Sans. It also maps `system-ui`, `Segoe UI`, and
    `Segoe UI Variable` to Selawik.
  - Unchanged on purpose: Arial stays Liberation Sans (metric-compatible, as
    Windows shows Arial), serif stays Liberation Serif, monospace stays
    JetBrainsMono Nerd Font. Side effect: an explicit request for
    "Liberation Sans" also gets Selawik.
  - `omarchy font set` rewrites `~/.config/fontconfig/fonts.conf`, not
    `conf.d/`, so it does not undo this.
- Verified: `fc-match` gives Selawik for `sans-serif`, `system-ui`,
  `-apple-system`, `BlinkMacSystemFont`, and `Segoe UI` (escape hyphens when
  testing, e.g. `fc-match 'system\-ui'`, or fc-match reads them as a size);
  a freshly opened Kate rendered its menus in Selawik (screenshot). Apps
  already running pick it up when restarted.
- Josh saw no problem in Chrome or Dolphin after restarting them but found the
  change hard to spot. A side-by-side render showed the real "before" was
  Liberation Sans (Arial-like): the old GTK font, `Adwaita Sans`, was never
  installed, so it fell back to sans-serif. Kept for now as the Windows look.
- Undo: `rm ~/.config/fontconfig/conf.d/60-selawik.conf && fc-cache -f`,
  `gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11'`,
  `sudo pacman -Rns ttf-selawik`.

## Consistent sizes (2026-09-22)

Josh: terminals looked right at 160%, but Chrome looked zoomed in, desktop
icons and some Dolphin icons were too big, and the taskbar a little small.

Findings: Chrome is Wayland-native with default zoom (100%) and 16px text, so
nothing was mis-scaled; it simply renders at the full 1.6 factor while the
terminals use a 9pt font. The interface font was 11pt (GNOME's default;
Windows uses about 9pt). Desktop icons were hard-coded at 72px in 144×162
cells; Dolphin's icon/preview size was 96px (set in Codex's Plasma setup);
the Omarchy bar was 26px (Windows 11's taskbar is 48px).

| Item | Before | After | Where |
| --- | --- | --- | --- |
| Interface font (GTK/Qt: Chrome UI, Dolphin, Kate) | Selawik 11 | Selawik 10, then **JetBrainsMono Nerd Font 9** | `gsettings … font-name` |
| Taskbar height | 26px | **34px** | [`shell.toml`](shell.toml) → `~/.config/omarchy/shell.toml` `[bar] size-horizontal` |
| Desktop icons | 72px, 144×162 cells, 18px JetBrains Mono labels | **48px, 96×104 cells, 13px labels** (shell font) | [`desktop-icons-sizes.patch`](desktop-icons-sizes.patch) on `henri.desktop-icons/Service.qml` |
| Dolphin icons view | 96px | **48px** (Windows "medium icons"; 64px first) | `~/.config/dolphinrc` `[IconsMode] IconSize/PreviewSize` |
| Chrome page content | 100% | **90%** | `~/.config/chromium/Default/Preferences` `partition.default_zoom_level.x = log(0.9)/log(1.2)` (≈ −0.578), set with Chrome closed; relaunched with `--restore-last-session` (tabs came back); Chrome kept the value after rewriting its prefs. Backup `Preferences.bak.<epoch>` |
| Dolphin details and compact views | 64px (Dolphin default) | **16px**, then details **22px** for a little more row space (Dolphin has no row-padding setting; row height follows icon size) | `~/.config/dolphinrc` `[DetailsMode]`, `[CompactMode]` |

- Follow-up after Josh's screenshot request: the desktop icons were still
  large because the running shell had not reloaded the plugin (`omarchy
  restart shell` fixed it) and the icons were held at positions saved for
  the old 162px grid. `~/.config/omarchy/desktop-icon-positions.json` was
  moved to `.bak.1790117800` and regenerated on the 104px grid. Dolphin was
  in Details view, which has its own icon size (set to 16px above), and
  reopened old tabs because of `RememberOpenedTabs` (now `false`, like
  Explorer, which starts fresh).
- Apps pick up the font and Dolphin size when reopened. Verified: bar
  reserved space is 34px; the desktop plugin reloaded with the new sizes.
- The desktop-icons plugin also carries Codex's local OLED pixel-shift edits
  (see `setup/oled-desktop-icons/`), so only the four size lines were
  changed; the pre-change file was saved in Claude's scratchpad.
- Undo: `gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 9'`
  (the current font; Selawik has since been uninstalled);
  delete `~/.config/omarchy/shell.toml`; set the four plugin values back
  (72 / 144 / 162 / 18); `kwriteconfig6 --file dolphinrc --group IconsMode
  --key PreviewSize 96` (and `IconSize`).

## Window borders

> **Superseded:** the colours below were later changed. Live values in
> `windows_style.lua` are `active_border = rgb(253040)` (the slate title-bar
> colour) and `inactive_border = rgb(1c1c1c)`. Width is still 1px.

Josh: the app below the title bar had a thick 2–3px border; make it slimmer,
drop the top edge if possible, and colour it like the title bar.

- `windows_style.lua` sets `general.border_size = 1` (Omarchy: 2) and
  `col.active_border = rgb(005fb8)`, `col.inactive_border = rgb(1b2838)`,
  the same colours as Grabbar's focused/unfocused strip. It loads after the
  theme, so it also overrides the theme's border colours.
- Hyprland cannot remove a single edge; with matching colours the top edge
  merges into the title bar. Verified by screenshot (focused window: thin
  blue outline continuous with the blue title bar).
