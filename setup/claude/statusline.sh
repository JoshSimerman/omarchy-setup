#!/usr/bin/env bash
# Claude Code status line.
# Format: [<model display name>] <N>% ctx
# Falls back to just "[<model display name>]" if context-window usage info
# is not present in the JSON payload passed on stdin.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')

# Prefer the pre-calculated percentage field.
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

# Fall back to computing it from the raw token counts if the pre-calculated
# field is absent (e.g. no messages sent yet).
if [ -z "$used" ]; then
  total=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // empty')
  size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // empty')
  if [ -n "$total" ] && [ -n "$size" ] && [ "$size" != "0" ]; then
    used=$(awk -v t="$total" -v s="$size" 'BEGIN { printf "%.6f", (t / s) * 100 }')
  fi
fi

if [ -n "$used" ]; then
  pct=$(awk -v u="$used" 'BEGIN { printf "%.0f", u }')
  printf '[%s] %s%% ctx' "$model" "$pct"
else
  printf '[%s]' "$model"
fi
