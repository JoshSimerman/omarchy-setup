#!/bin/bash
# Repeat the Windows-style desktop setup on another Omarchy machine.
# Read README.md first. Backs up every file it changes.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
plugins=~/.config/omarchy/plugins
ts=$(date +%s)

# Notepad, Photos and archive support for Dolphin.
omarchy pkg add kate gwenview ark

# Plugins, checked out at the reviewed commits instead of the latest upstream.
grep -v '^#' "$here/plugins.txt" | while read -r id url commit; do
  [[ -d $plugins/$id ]] || omarchy plugin add "$url" --yes
  git -C "$plugins/$id" fetch -q origin "$commit"
  git -C "$plugins/$id" -c advice.detachedHead=false checkout -q "$commit"
done

cp ~/.config/omarchy/shell.json ~/.config/omarchy/shell.json.bak.$ts
omarchy plugin enable io.github.librael-the-culprit.simple-start-menu --section left --before omarchy.menu
# Start menu is the App Launcher (coloured app grid); Simple Start Menu stays installed but disabled.
git -C "$plugins/tyrsolution.app-launcher" apply "$here/app-launcher-local.patch"
# Launch before closing the menu, or web apps like WhatsApp never open (Codex fix).
git -C "$plugins/tyrsolution.app-launcher" apply "$here/../start-menu-launch-fix/launch-before-dismiss.patch"
omarchy plugin enable tyrsolution.app-launcher --section left --before io.github.librael-the-culprit.simple-start-menu
omarchy plugin disable io.github.librael-the-culprit.simple-start-menu
for id in io.github.pablo-merino.altswitch se.mindfulstack.omascape henri.desktop-icons tech.greyforge.grabbar; do
  omarchy plugin enable "$id"
done
# Quick Settings button just before the clock; hover corners off, tiles repointed.
git -C "$plugins/aryal.control-center" apply "$here/quick-settings-local.patch"
omarchy plugin enable aryal.control-center --section right --before omarchy.clock
# Action Center bell at the far right (after the clock).
omarchy plugin enable jankeesvw.notification-center --section right --after omarchy.clock
# The Start button replaces the Omarchy menu button (Super+Space still opens it).
jq '.bar.layout.left |= map(select(.id != "omarchy.menu"))' ~/.config/omarchy/shell.json >~/.config/omarchy/shell.json.tmp
mv ~/.config/omarchy/shell.json.tmp ~/.config/omarchy/shell.json

# OmaPanel: grey dash under open-but-inactive apps (like Windows).
git -C "$plugins/atagulalan.omapanel" apply "$here/omapanel-running-dash.patch" || true
# OmaPanel: app-name tooltip on pinned apps that are not open (like Windows).
git -C "$plugins/atagulalan.omapanel" apply "$here/omapanel-tooltips.patch" || true
# Blue title bars even if Grabbar's shell pushes theme colours (see README).
git -C "$plugins/tech.greyforge.grabbar" apply "$here/grabbar-local.patch"  # colours + restore-host fix
# Desktop icons open Dolphin, not Nautilus, for "Show in Files" and the Trash.
git -C "$plugins/henri.desktop-icons" apply "$here/desktop-icons-dolphin.patch"
# OLED (Codex): desktop icons shift up to 2px every three minutes. Must come
# before the sizes and keyboard patches below. See ../oled-desktop-icons/README.md.
git -C "$plugins/henri.desktop-icons" apply "$here/../oled-desktop-icons/desktop-icons-oled.patch"

# Grabbar's title bars are a native Hyprland plugin built against the local headers.
make -C "$plugins/tech.greyforge.grabbar/native/grabbar" CXX=g++

# Hyprland behaviour and keybindings.
cp "$here/windows_style.lua" ~/.config/hypr/windows_style.lua
if ! grep -q 'require("hypr.windows_style")' ~/.config/hypr/hyprland.lua; then
  cp ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.bak.$ts
  printf '\n-- Windows-style behaviour: floating windows, Win-key shortcuts, snapping.\nrequire("hypr.windows_style")\n' >>~/.config/hypr/hyprland.lua
fi
hyprctl reload
hyprctl configerrors

# OLED (Codex): taskbar content shifts a few pixels every three minutes, via a
# patched copy of Omarchy's bar. Only onto the bar version the patch was made for;
# otherwise rebase it first. See ../oled-bar-proposal/README.md.
oled="$here/../oled-bar-proposal"
if [[ $(sha256sum /usr/share/omarchy/shell/plugins/bar/Bar.qml | cut -d' ' -f1) == "$(cut -d' ' -f1 "$oled/base-sha256.txt")" ]]; then
  [[ -d $plugins/$USER.bar ]] || omarchy plugin clone omarchy.bar
  git -C "$plugins/$USER.bar" apply "$oled/bar-pixel-shift.patch"
  omarchy plugin validate "$plugins/$USER.bar"
  jq '.bar.oledShiftEnabled = true | .bar.oledShiftIntervalSeconds = 180' ~/.config/omarchy/shell.json >~/.config/omarchy/shell.json.tmp
  mv ~/.config/omarchy/shell.json.tmp ~/.config/omarchy/shell.json
else
  echo "WARNING: Omarchy's Bar.qml differs from the OLED patch base; bar shifting NOT applied." >&2
fi

# Display: 160% scaling on the 2880x1800 OLED, true-black theme.
omarchy hyprland monitor scaling 1.6
# Vantablack names the missing Yaru-gray icon theme; use Fluent icons instead.
omarchy pkg aur add fluent-icon-theme
mkdir -p ~/.config/omarchy/themes/vantablack
cp "$here/theme-overlay/vantablack/icons.theme" ~/.config/omarchy/themes/vantablack/
omarchy theme set vantablack
omarchy restart shell

# Interface font: JetBrains Mono 9pt, the same as the terminals and the bar.
gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 9'

# Sizes: taller taskbar, smaller desktop and Dolphin icons.
cp "$here/shell.toml" ~/.config/omarchy/shell.toml
# Desktop icons: 48px on a 96x104 grid, 13px labels.
patch -d "$plugins/henri.desktop-icons" -p1 --forward < "$here/desktop-icons-sizes.patch"
patch -d "$plugins/henri.desktop-icons" -p1 --forward < "$here/desktop-icons-keyboard.patch"
# Desktop icons: single click selects, double-click opens (like Windows).
patch -d "$plugins/henri.desktop-icons" -p1 --forward < "$here/desktop-icons-doubleclick.patch"
kwriteconfig6 --file dolphinrc --group IconsMode --key IconSize 48
kwriteconfig6 --file dolphinrc --group IconsMode --key PreviewSize 48
for g in DetailsMode CompactMode; do
  kwriteconfig6 --file dolphinrc --group $g --key IconSize 16
  kwriteconfig6 --file dolphinrc --group $g --key PreviewSize 16
done
kwriteconfig6 --file dolphinrc --group DetailsMode --key IconSize 22
kwriteconfig6 --file dolphinrc --group DetailsMode --key PreviewSize 22
kwriteconfig6 --file dolphinrc --group General --key RememberOpenedTabs --type bool false

# Wallpaper and clock.
mkdir -p ~/.config/omarchy/backgrounds/vantablack
cp /usr/share/omarchy/themes/matte-black/backgrounds/1-dark-waters.jpg ~/.config/omarchy/backgrounds/vantablack/0-dark-waters.jpg
omarchy theme bg set ~/.config/omarchy/backgrounds/vantablack/0-dark-waters.jpg
omarchy bar set omarchy.clock format '"h:mm AP\nM/d/yyyy"' --json

# Drifting-nebula screensaver (render the video as in DESKTOP.md first).
mkdir -p ~/.local/lib/omarchy-overrides/bin
install -m755 "$here/screensaver/omarchy-launch-screensaver" ~/.local/lib/omarchy-overrides/bin/
cp "$here/screensaver/screensaver-mpv-input.conf" ~/.config/omarchy/
grep -q omarchy-overrides ~/.bash_profile || cat "$here/screensaver/bash_profile-snippet.sh" >>~/.bash_profile

# Qt palette (near-black, subtle alternating rows) and Dolphin colour scheme.
cp "$here/colors/qt-gtk-palette.json" ~/.config/omarchy/qt-gtk-palette.json
mkdir -p ~/.local/share/color-schemes
cp "$here/colors/OmarchyDark.colors" ~/.local/share/color-schemes/
kwriteconfig6 --file dolphinrc --group UiSettings --key ColorScheme OmarchyDark

# Electron apps on Hyprland need the keyring named explicitly.
[[ -f ~/.config/claude-desktop-flags.conf ]] || cp "$here/apps/claude-desktop-flags.conf" ~/.config/

# Default apps.
[[ -f ~/.config/mimeapps.list ]] && cp ~/.config/mimeapps.list ~/.config/mimeapps.list.bak.$ts
xdg-mime default org.kde.kate.desktop text/plain text/markdown application/x-shellscript
# Images open in Loupe (2026-09-22; Gwenview stays installed). See ../apps/README.md.
omarchy pkg add loupe
xdg-mime default org.gnome.Loupe.desktop image/png image/jpeg image/gif image/webp image/bmp image/svg+xml

# Dolphin is the only file manager: separate windows, LocalSend and Transcode
# right-click actions, archives in Ark, then remove Nautilus (keep xdg-user-dirs).
[[ -f ~/.config/dolphinrc ]] && cp ~/.config/dolphinrc ~/.config/dolphinrc.bak.$ts
kwriteconfig6 --file dolphinrc --group General --key OpenExternallyCalledFolderInNewTab --type bool false
mkdir -p ~/.local/share/kio/servicemenus ~/.local/bin
install -m755 "$here/dolphin/localsend.desktop" "$here/dolphin/transcode.desktop" ~/.local/share/kio/servicemenus/
install -m755 "$here/dolphin/dolphin-transcode" ~/.local/bin/
xdg-mime default org.kde.dolphin.desktop inode/directory
xdg-mime default org.kde.ark.desktop application/zip application/x-7z-compressed application/x-tar \
  application/gzip application/x-compressed-tar application/x-bzip2 application/x-bzip2-compressed-tar \
  application/x-xz application/x-xz-compressed-tar application/zstd application/x-zstd-compressed-tar \
  application/vnd.rar application/x-cpio
sudo pacman -D --asexplicit xdg-user-dirs
sudo pacman -Rs --noconfirm nautilus nautilus-python

# Load Grabbar's title bars at login (guarded loader appended to hyprland.lua).
"$plugins/tech.greyforge.grabbar/bin/grabbar" autoload enable
hyprctl reload

echo "Done."
