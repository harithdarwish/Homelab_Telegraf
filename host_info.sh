#!/bin/sh
# Combined Telegraf exec script: Docker container info + lsblk
# Output format: InfluxDB line protocol

# Escape spaces, commas and equals signs in tag values
esc() { printf '%s' "$1" | sed 's/ /\\ /g; s/,/\\,/g; s/=/\\=/g'; }

# --- Docker: one line per container (name, image, state, published ports) ---
if command -v docker >/dev/null 2>&1; then
 USED=$(docker ps -a --format '{{.Image}}' | sort -u)
  docker images --format '{{.Repository}}|{{.Tag}}|{{.ID}}|{{.Size}}' | while IFS='|' read -r repo tag id size; do
    inuse=no
    echo "$USED" | grep -qx "$repo:$tag" && inuse=yes
    echo "docker_image_info,repository=$(esc "$repo"),tag=$(esc "$tag"),image_id=$(esc "$id"),size=$(esc "$size"),in_use=$inuse value=1i"
  done
fi

# --- lsblk: one line per block device/partition ---
if command -v lsblk >/dev/null 2>&1; then
  lsblk -b -n -r -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT | while read -r name type size fstype mount; do
    echo "lsblk_info,name=$(esc "$name"),type=$(esc "$type"),fstype=$(esc "${fstype:-none}"),mountpoint=$(esc "${mount:-none}") size_bytes=${size}i"
  done
fi
