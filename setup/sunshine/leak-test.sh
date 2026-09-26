#!/bin/bash
# Sunshine leak test: log capture memory unlocked vs locked during a stream.
log=$1; start=$(date '+%Y-%m-%d %H:%M:%S')
sample() {
  awk -v p="$1" -v t="$(date +%T)" -v l="$(omarchy-shell lock isLocked 2>/dev/null)" \
    '/^Shmem:/{s=$2} /^GPUActive:/{g=$2} /^GPUReclaim:/{r=$2} /^MemAvailable:/{a=$2} /^SwapFree:/{f=$2}
     END{printf "%s %-8s locked=%-5s shmem=%6d gpu=%6d reclaim=%6d avail=%6d swapfree=%6d MB\n", t, p, l, s/1024, g/1024, r/1024, a/1024, f/1024}' /proc/meminfo >> "$log"
}
echo "waiting for Moonlight since $start" >> "$log"
for _ in $(seq 1 480); do   # up to 40 min
  journalctl --user -u app-dev.lizardbyte.app.Sunshine --since "$start" -o cat -q | grep -q "CLIENT CONNECTED" && break
  sleep 5
done
journalctl --user -u app-dev.lizardbyte.app.Sunshine --since "$start" -o cat -q | grep -q "CLIENT CONNECTED" || { echo "no client connected" >> "$log"; exit 1; }
sleep 5
for _ in $(seq 36); do sample unlocked; sleep 5; done
omarchy-system-lock >/dev/null 2>&1 & sleep 3
for _ in $(seq 36); do sample locked; sleep 5; done
echo "done" >> "$log"
journalctl --user -u sunshine-memguard --since "$start" -o cat -q >> "$log"
