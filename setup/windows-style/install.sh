#!/bin/bash
# Repeat the Windows-style desktop setup on another Omarchy machine.
# Read README.md first.
#
# Safe to run again: every step checks the current state first and does
# nothing when it is already done, so a second run changes nothing.
#
# Backups: before this script edits a file in your home directory, or runs an
# Omarchy command that rewrites one (shell.json, monitors.lua, hyprland.lua,
# ~/.bash_profile, dolphinrc, mimeapps.list, ...), it copies that file to
# <file>.bak.<epoch>, once per run. Plugin sources are git checkouts; their
# local patches are reversed with `git apply -R`. `omarchy theme set` (only run
# when the icon overlay changes) is Omarchy's own theme switch.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
plugins="$HOME/.config/omarchy/plugins"
shell_json="$HOME/.config/omarchy/shell.json"
hypr_lua="$HOME/.config/hypr/hyprland.lua"
ts=$(date +%s)
restart_shell=false
reload_hyprland=false

# --- helpers -----------------------------------------------------------------

declare -A backed_up=()
# Copy a file to <file>.bak.<epoch> the first time this run is about to change it.
backup() {
  local file=$1
  [[ -e $file && -z ${backed_up[$file]:-} ]] || return 0
  cp -a -- "$file" "$file.bak.$ts"
  backed_up[$file]=1
  echo "backup: $file.bak.$ts"
}

# Install packages that are not installed yet (official repos, or AUR with --aur).
pkg_add() {
  local aur=false missing=() p
  if [[ $1 == --aur ]]; then aur=true; shift; fi
  for p in "$@"; do pacman -Qq "$p" >/dev/null 2>&1 || missing+=("$p"); done
  ((${#missing[@]})) || return 0
  if $aur; then omarchy pkg aur add "${missing[@]}"; else omarchy pkg add "${missing[@]}"; fi
}

# Apply a patch to a plugin checkout unless it is already applied.
apply_patch() {
  local dir=$1 patch=$2
  if git -C "$dir" apply --check --reverse "$patch" 2>/dev/null; then
    return 0 # already applied
  fi
  git -C "$dir" apply "$patch"
  echo "patched: $dir ($(basename "$patch"))"
  restart_shell=true
}

# Copy a file into place (optionally with a mode) if it differs; back up the old one.
put() {
  local src=$1 dst=$2 mode=${3:-644}
  if [[ -f $dst ]] && cmp -s "$src" "$dst"; then
    [[ $(stat -c %a "$dst") == "$mode" ]] || chmod "$mode" "$dst"
    return 1 # unchanged
  fi
  mkdir -p "$(dirname "$dst")"
  backup "$dst"
  install -m "$mode" "$src" "$dst"
  echo "installed: $dst"
}

# Is a widget/plugin placed in the bar layout?
in_bar() {
  jq -e --arg id "$1" 'any(.bar.layout[][]; .id == $id)' "$shell_json" >/dev/null
}

# Set a Dolphin (KDE) config value only if it differs.
kset() {
  local file=$1 group=$2 key=$3 value=$4 type=${5:-}
  [[ $(kreadconfig6 --file "$file" --group "$group" --key "$key") == "$value" ]] && return 0
  backup "$HOME/.config/$file"
  if [[ -n $type ]]; then
    kwriteconfig6 --file "$file" --group "$group" --key "$key" --type "$type" "$value"
  else
    kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value"
  fi
}

# Make an app the default for MIME types whose default differs.
mime_default() {
  local app=$1 type; shift
  for type in "$@"; do
    [[ $(xdg-mime query default "$type") == "$app" ]] && continue
    backup "$HOME/.config/mimeapps.list"
    xdg-mime default "$app" "$type"
  done
}

# --- packages and plugins ------------------------------------------------------

# Notepad, Photos and archive support for Dolphin.
pkg_add kate gwenview ark

# Plugins, checked out at the reviewed commits instead of the latest upstream.
grep -v -e '^#' -e '^$' "$here/plugins.txt" | while read -r id url commit; do
  [[ -d $plugins/$id ]] || omarchy plugin add "$url" --yes
  if [[ $(git -C "$plugins/$id" rev-parse HEAD) != "$commit" ]]; then
    git -C "$plugins/$id" fetch -q origin "$commit"
    git -C "$plugins/$id" -c advice.detachedHead=false checkout -q "$commit"
  fi
done

# Start menu is the App Launcher (coloured app grid); Simple Start Menu stays
# installed but disabled. The Start button replaces the Omarchy menu button
# (Super+Space still opens the Omarchy menu).
apply_patch "$plugins/tyrsolution.app-launcher" "$here/app-launcher-local.patch"
# Launch before closing the menu, or web apps like WhatsApp never open (Codex fix).
apply_patch "$plugins/tyrsolution.app-launcher" "$here/../start-menu-launch-fix/launch-before-dismiss.patch"
if ! in_bar tyrsolution.app-launcher; then
  backup "$shell_json"
  omarchy plugin enable io.github.librael-the-culprit.simple-start-menu --section left --before omarchy.menu
  omarchy plugin enable tyrsolution.app-launcher --section left --before io.github.librael-the-culprit.simple-start-menu
  omarchy plugin disable io.github.librael-the-culprit.simple-start-menu
fi
if in_bar omarchy.menu; then
  backup "$shell_json"
  jq '.bar.layout.left |= map(select(.id != "omarchy.menu"))' "$shell_json" >"$shell_json.tmp"
  mv "$shell_json.tmp" "$shell_json"
fi
# Alt+Tab, Task View, desktop icons, and title bars are not bar widgets;
# enabling an already enabled plugin changes nothing.
for id in io.github.pablo-merino.altswitch se.mindfulstack.omascape henri.desktop-icons tech.greyforge.grabbar; do
  omarchy plugin enable "$id"
done
# Quick Settings button just before the clock; hover corners off, tiles repointed.
apply_patch "$plugins/aryal.control-center" "$here/quick-settings-local.patch"
if ! in_bar aryal.control-center; then
  backup "$shell_json"
  omarchy plugin enable aryal.control-center --section right --before omarchy.clock
fi
# Action Center bell at the far right (after the clock).
if ! in_bar jankeesvw.notification-center; then
  backup "$shell_json"
  omarchy plugin enable jankeesvw.notification-center --section right --after omarchy.clock
fi

# OmaPanel (installed separately, see ../omapanel/README.md): grey dash under
# open-but-inactive apps, and app-name tooltips on closed pins (like Windows).
if [[ -d $plugins/atagulalan.omapanel ]]; then
  apply_patch "$plugins/atagulalan.omapanel" "$here/omapanel-running-dash.patch"
  apply_patch "$plugins/atagulalan.omapanel" "$here/omapanel-tooltips.patch"
else
  echo "NOTE: OmaPanel is not installed; skipped its patches (see ../omapanel/README.md)." >&2
fi
# Title-bar colours and the restore-host (minimize) fix.
apply_patch "$plugins/tech.greyforge.grabbar" "$here/grabbar-local.patch"
# Desktop icons, in this order: Dolphin instead of Nautilus, OLED shift (Codex;
# see ../oled-desktop-icons/README.md), sizes, keyboard focus, double-click.
icons="$plugins/henri.desktop-icons"
apply_patch "$icons" "$here/desktop-icons-dolphin.patch"
apply_patch "$icons" "$here/../oled-desktop-icons/desktop-icons-oled.patch"
apply_patch "$icons" "$here/desktop-icons-sizes.patch"
apply_patch "$icons" "$here/desktop-icons-keyboard.patch"
apply_patch "$icons" "$here/desktop-icons-doubleclick.patch"

# Grabbar's title bars are a native Hyprland plugin built against the local
# headers; make does nothing when the build is up to date.
make -s -C "$plugins/tech.greyforge.grabbar/native/grabbar" CXX=g++

# --- Hyprland ------------------------------------------------------------------

# Behaviour and keybindings.
put "$here/windows_style.lua" "$HOME/.config/hypr/windows_style.lua" && reload_hyprland=true
if ! grep -q 'require("hypr.windows_style")' "$hypr_lua"; then
  backup "$hypr_lua"
  printf '\n-- Windows-style behaviour: floating windows, Win-key shortcuts, snapping.\nrequire("hypr.windows_style")\n' >>"$hypr_lua"
  reload_hyprland=true
fi
# Load Grabbar's title bars at login (guarded loader appended to hyprland.lua).
if ! grep -q 'BEGIN tech.greyforge.grabbar autoload' "$hypr_lua"; then
  backup "$hypr_lua"
  "$plugins/tech.greyforge.grabbar/bin/grabbar" autoload enable
  reload_hyprland=true
fi

# --- OLED bar shift -------------------------------------------------------------

# OLED (Codex): taskbar content shifts a few pixels every three minutes, via a
# patched copy of Omarchy's bar. Only onto the bar version the patch was made
# for; otherwise rebase it first. See ../oled-bar-proposal/README.md.
oled="$here/../oled-bar-proposal"
if [[ $(sha256sum /usr/share/omarchy/shell/plugins/bar/Bar.qml | cut -d' ' -f1) == "$(cut -d' ' -f1 "$oled/base-sha256.txt")" ]]; then
  if [[ ! -d $plugins/$USER.bar ]]; then
    backup "$shell_json"
    omarchy plugin clone omarchy.bar
  fi
  apply_patch "$plugins/$USER.bar" "$oled/bar-pixel-shift.patch"
  omarchy plugin validate "$plugins/$USER.bar"
  if ! jq -e '.bar.oledShiftEnabled == true and .bar.oledShiftIntervalSeconds == 180' "$shell_json" >/dev/null; then
    backup "$shell_json"
    jq '.bar.oledShiftEnabled = true | .bar.oledShiftIntervalSeconds = 180' "$shell_json" >"$shell_json.tmp"
    mv "$shell_json.tmp" "$shell_json"
  fi
else
  echo "WARNING: Omarchy's Bar.qml differs from the OLED patch base; bar shifting NOT applied." >&2
fi

# --- Look -------------------------------------------------------------------------

# Display: 160% scaling on the 2880x1800 OLED.
monitors="$HOME/.config/hypr/monitors.lua"
if ! grep -q 'omarchy_monitor_scale = 1.6' "$monitors" 2>/dev/null; then
  backup "$monitors"
  omarchy hyprland monitor scaling 1.6
fi
# True-black Vantablack theme. It names the missing Yaru-gray icon theme; a
# theme overlay selects Fluent icons instead. `omarchy theme set` also moves
# to the next wallpaper, so it only runs when the overlay changes.
pkg_add --aur fluent-icon-theme
theme_changed=false
if put "$here/theme-overlay/vantablack/icons.theme" "$HOME/.config/omarchy/themes/vantablack/icons.theme"; then
  omarchy theme set vantablack
  theme_changed=true
  restart_shell=true
fi

# Interface font: JetBrains Mono 9pt, the same as the terminals and the bar.
font="'JetBrainsMono Nerd Font 9'"
[[ $(gsettings get org.gnome.desktop.interface font-name) == "$font" ]] ||
  gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 9'

# Taskbar size and colour.
put "$here/shell.toml" "$HOME/.config/omarchy/shell.toml" && restart_shell=true

# Dolphin: 48px icons, 16px compact, 22px details, no tab restore, separate
# windows, and the near-black colour scheme.
kset dolphinrc IconsMode IconSize 48
kset dolphinrc IconsMode PreviewSize 48
kset dolphinrc CompactMode IconSize 16
kset dolphinrc CompactMode PreviewSize 16
kset dolphinrc DetailsMode IconSize 22
kset dolphinrc DetailsMode PreviewSize 22
kset dolphinrc General RememberOpenedTabs false bool
kset dolphinrc General OpenExternallyCalledFolderInNewTab false bool
kset dolphinrc UiSettings ColorScheme OmarchyDark

# Qt palette (near-black, subtle alternating rows) and Dolphin colour scheme.
put "$here/colors/qt-gtk-palette.json" "$HOME/.config/omarchy/qt-gtk-palette.json" || true
put "$here/colors/OmarchyDark.colors" "$HOME/.local/share/color-schemes/OmarchyDark.colors" || true

# Wallpaper (Dark Waters) and a clock with the date below the time.
if put /usr/share/omarchy/themes/matte-black/backgrounds/1-dark-waters.jpg \
  "$HOME/.config/omarchy/backgrounds/vantablack/0-dark-waters.jpg" || $theme_changed; then
  omarchy theme bg set "$HOME/.config/omarchy/backgrounds/vantablack/0-dark-waters.jpg"
fi
clock_format=$'h:mm AP\nM/d/yyyy'
if [[ $(jq -r '[.bar.layout[][] | select(.id == "omarchy.clock") | .format][0] // ""' "$shell_json") != "$clock_format" ]]; then
  backup "$shell_json"
  omarchy bar set omarchy.clock format '"h:mm AP\nM/d/yyyy"' --json
fi

# Drifting-nebula screensaver (render the video as in DESKTOP.md first).
put "$here/screensaver/omarchy-launch-screensaver" "$HOME/.local/lib/omarchy-overrides/bin/omarchy-launch-screensaver" 755 || true
put "$here/screensaver/screensaver-mpv-input.conf" "$HOME/.config/omarchy/screensaver-mpv-input.conf" || true
if ! grep -qs omarchy-overrides "$HOME/.bash_profile"; then
  backup "$HOME/.bash_profile"
  cat "$here/screensaver/bash_profile-snippet.sh" >>"$HOME/.bash_profile"
fi

# Electron apps on Hyprland need the keyring named explicitly.
[[ -f $HOME/.config/claude-desktop-flags.conf ]] ||
  put "$here/apps/claude-desktop-flags.conf" "$HOME/.config/claude-desktop-flags.conf" || true

# --- Default apps and the file manager -------------------------------------------

mime_default org.kde.kate.desktop text/plain text/markdown application/x-shellscript
# Images open in Loupe (2026-09-22; Gwenview stays installed). See ../apps/README.md.
pkg_add loupe
mime_default org.gnome.Loupe.desktop image/png image/jpeg image/gif image/webp image/bmp image/svg+xml

# Dolphin is the only file manager: LocalSend and Transcode right-click
# actions, archives in Ark, then remove Nautilus (keep xdg-user-dirs).
put "$here/dolphin/localsend.desktop" "$HOME/.local/share/kio/servicemenus/localsend.desktop" 755 || true
put "$here/dolphin/transcode.desktop" "$HOME/.local/share/kio/servicemenus/transcode.desktop" 755 || true
put "$here/dolphin/dolphin-transcode" "$HOME/.local/bin/dolphin-transcode" 755 || true
mime_default org.kde.dolphin.desktop inode/directory
mime_default org.kde.ark.desktop application/zip application/x-7z-compressed application/x-tar \
  application/gzip application/x-compressed-tar application/x-bzip2 application/x-bzip2-compressed-tar \
  application/x-xz application/x-xz-compressed-tar application/zstd application/x-zstd-compressed-tar \
  application/vnd.rar application/x-cpio
pacman -Qqe xdg-user-dirs >/dev/null 2>&1 || sudo pacman -D --asexplicit xdg-user-dirs
installed=()
for p in nautilus nautilus-python; do pacman -Qq "$p" >/dev/null 2>&1 && installed+=("$p"); done
((${#installed[@]} == 0)) || sudo pacman -Rs --noconfirm "${installed[@]}"

# --- Apply --------------------------------------------------------------------------

if $reload_hyprland; then
  hyprctl reload
  hyprctl configerrors
fi
if $restart_shell; then
  omarchy restart shell
fi

echo "Done."
