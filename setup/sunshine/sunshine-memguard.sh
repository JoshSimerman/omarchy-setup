#!/bin/bash
# Restart Sunshine before leaked screen-capture buffers exhaust memory.
#
# On 2026-09-24 a stream left running on the lock screen grew shared and GPU
# memory by about one 2880x1800 frame per second until the kernel killed other
# apps; the memory came back when Sunshine died. See README.md here.
#
# Installed as ~/.local/bin/sunshine-memguard, run by sunshine-memguard.service.
set -u

unit=app-dev.lizardbyte.app.Sunshine.service
limit_gb=${SUNSHINE_MEMGUARD_LIMIT_GB:-6}  # Shmem + GPUActive; normal is under 1 GB
floor_gb=${SUNSHINE_MEMGUARD_FLOOR_GB:-3}  # MemAvailable, only once buffers exceed 2 GB

read_mem() {
  awk '/^Shmem:/ { s = $2 } /^GPUActive:/ { g = $2 } /^MemAvailable:/ { a = $2 }
       END { print s + g, a }' /proc/meminfo
}

while sleep 5; do
  systemctl --user -q is-active "$unit" || continue
  read -r held avail < <(read_mem)
  if (( held > limit_gb * 1048576 || (avail < floor_gb * 1048576 && held > 2 * 1048576) )); then
    msg="capture buffers $((held / 1024)) MB, available $((avail / 1024)) MB"
    echo "restarting Sunshine: $msg"
    # A normal stop can hang (Sunshine's own 10 s hang detector, then systemd's 90 s).
    systemctl --user kill -s KILL "$unit"
    systemctl --user restart "$unit"
    read -r held avail < <(read_mem)
    echo "after restart: capture buffers $((held / 1024)) MB, available $((avail / 1024)) MB"
    notify-send -u critical -a Sunshine "Sunshine restarted" \
      "Screen-capture memory was piling up ($msg). Reconnect from Moonlight." 2>/dev/null
    sleep 60
  fi
done
