#!/usr/bin/env bash
set -euo pipefail
case ":${XDG_CURRENT_DESKTOP:-}:" in
  *:KDE:*) ;;
  *) exit 0 ;;
esac
setup_state="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy-setup"
setup_data="${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-setup/plasma"
mkdir -p "$setup_state"
[[ -f "$setup_state/plasma-panel-ready" ]] && exit 0
exec >>"$setup_state/plasma-first-login.log" 2>&1
for _ in {1..30}; do
  if result=$(qdbus6 org.kde.plasmashell /PlasmaShell \
      org.kde.PlasmaShell.evaluateScript "$(cat "$setup_data/panel.js")" 2>&1) &&
      [[ "$result" == *omarchy-setup-panel-ready* ]]; then
    printf '%s\n' "$result"
    touch "$setup_state/plasma-panel-ready"
    exit 0
  fi
  sleep 2
done
printf 'Panel setup did not complete: %s\n' "$result"
exit 1
