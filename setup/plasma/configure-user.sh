#!/usr/bin/env bash
# Run as the desktop user after installing packages. Back up each affected file.
set -euo pipefail
setup_src=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
setup_config="${XDG_CONFIG_HOME:-$HOME/.config}"
setup_data="${XDG_DATA_HOME:-$HOME/.local/share}"
setup_state="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy-setup"
setup_backup="$setup_state/plasma-backup-$(date +%Y%m%d-%H%M%S)"
command -v kwriteconfig6 >/dev/null
[[ "$EUID" != 0 ]] || { echo 'Run this as your desktop user.' >&2; exit 1; }
mkdir -p "$setup_backup"
backup() {
  local file="$1"
  if [[ -e "$file" ]]; then
    mkdir -p "$setup_backup$(dirname "$file")"
    cp -a -- "$file" "$setup_backup$file"
    printf 'EXISTED %s\n' "$file" >> "$setup_backup/manifest.txt"
  else
    printf 'NEW %s\n' "$file" >> "$setup_backup/manifest.txt"
  fi
}
setup_desktop=$(xdg-user-dir DESKTOP)
setup_desktop=${setup_desktop%/}
if [[ "$setup_desktop" == "$HOME" ]]; then
  backup "$setup_config/user-dirs.dirs"
  setup_desktop="$HOME/Desktop"
  mkdir -p "$setup_desktop"
  xdg-user-dirs-update --set DESKTOP "$setup_desktop"
fi
for file in "$setup_config/dolphinrc" "$setup_config/kdeglobals" \
    "$setup_config/kwinrc" "$setup_config/mimeapps.list" \
    "$setup_config/plasma-org.kde.plasma.desktop-appletsrc" \
    "$setup_config/autostart/omarchy-setup-plasma.desktop" \
    "$setup_data/dolphin/view_properties/global/.directory" \
    "$setup_data/omarchy-setup/plasma/first-login.sh" \
    "$setup_data/omarchy-setup/plasma/panel.js" \
    "$setup_desktop/Home.desktop" "$setup_desktop/Setup-Notes.desktop"; do
  backup "$file"
done
mkdir -p "$setup_config/autostart" "$setup_data/dolphin/view_properties/global" \
  "$setup_data/omarchy-setup/plasma" "$setup_desktop"
kwriteconfig6 --file dolphinrc --group General --key GlobalViewProps --type bool true
kwriteconfig6 --file dolphinrc --group General --key ShowToolTips --type bool true
kwriteconfig6 --file dolphinrc --group General --key OpenExternallyCalledFolderInNewTab --type bool true
kwriteconfig6 --file dolphinrc --group IconsMode --key PreviewSize 96
kwriteconfig6 --file dolphinrc --group PreviewSettings --key Plugins \
  'directorythumbnail,imagethumbnail,jpegthumbnail,svgthumbnail,rawthumbnail,gsthumbnail,ffmpegthumbs'
kwriteconfig6 --file "$setup_data/dolphin/view_properties/global/.directory" --group Dolphin --key Version 4
kwriteconfig6 --file "$setup_data/dolphin/view_properties/global/.directory" --group Dolphin --key PreviewsShown --type bool true
kwriteconfig6 --file "$setup_data/dolphin/view_properties/global/.directory" --group Dolphin --key ViewMode 0
kwriteconfig6 --file kdeglobals --group KDE --key SingleClick --type bool false
kwriteconfig6 --file kdeglobals --group General --key BrowserApplication chromium.desktop
kwriteconfig6 --file kwinrc --group Windows --key FocusPolicy ClickToFocus
kwriteconfig6 --file kwinrc --group Windows --key Placement Centered
xdg-mime default org.kde.dolphin.desktop inode/directory
install -m 755 "$setup_src/first-login.sh" "$setup_data/omarchy-setup/plasma/first-login.sh"
install -m 644 "$setup_src/panel.js" "$setup_data/omarchy-setup/plasma/panel.js"
cat > "$setup_config/autostart/omarchy-setup-plasma.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Set up the bottom taskbar
Exec="$setup_data/omarchy-setup/plasma/first-login.sh"
OnlyShowIn=KDE;
NoDisplay=true
EOF
cat > "$setup_desktop/Home.desktop" <<EOF
[Desktop Entry]
Type=Link
Name=Home
Icon=user-home
URL=file://$HOME
EOF
cat > "$setup_desktop/Setup-Notes.desktop" <<EOF
[Desktop Entry]
Type=Link
Name=Machine Setup Notes
Icon=folder-documents
URL=file://$(cd "$setup_src/../.." && pwd)
EOF
printf 'Configuration applied. Backup: %s\n' "$setup_backup"
