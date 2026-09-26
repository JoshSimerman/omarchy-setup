#!/bin/bash
# Sunshine: allow Moonlight from the home LAN and over Tailscale only.
# Usage: pkexec env LAN_CIDR=<your-lan>/24 ./ufw-rules.sh
# The ports are Sunshine's defaults.
set -e
: "${LAN_CIDR:?set LAN_CIDR to the home LAN subnet, e.g. 192.0.2.0/24}"
for src in "from $LAN_CIDR" "in on tailscale0"; do
  ufw allow $src to any port 47984,47989,47990,48010 proto tcp comment sunshine
  ufw allow $src to any port 47998:48000,48002,48010 proto udp comment sunshine
done
ufw status verbose
