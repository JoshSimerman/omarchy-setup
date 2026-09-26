# Deliberate overrides of Omarchy commands (currently: the landscape
# screensaver launcher). Must come after ~/.bashrc, whose Omarchy bootstrap
# puts /usr/share/omarchy/bin first. The idle service runs `bash -lc`, so this
# is what makes it pick the override. Tracked in ~/omarchy-setup.
[[ -d ~/.local/lib/omarchy-overrides/bin ]] && PATH="$HOME/.local/lib/omarchy-overrides/bin:$PATH"
