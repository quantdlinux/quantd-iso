#!/bin/sh
# config/includes.chroot/usr/local/sbin/create-persistence.sh
# One-shot helper executed at first boot by systemd. Creates a loopback persistence file
# named "persistence" in the live medium root if none exists and there is enough free space.

set -e

MEDIUM="/lib/live/mount/medium"
PERSISTENCE_FILE="$MEDIUM/persistence"
LABEL="persistence"
DEFAULT_MB=2048   # default file size in MiB (2GB); will try bigger if space allows
MAX_MB=8192       # don't create bigger than 8GB by default

log() { logger -t create-persistence -- "$@"; }

if [ "$(id -u)" -ne 0 ]; then
  log "must run as root"
  exit 1
fi

# Wait until medium is mounted (give it a few seconds)
for i in 1 2 3 4 5; do
  if [ -d "$MEDIUM" ]; then break; fi
  sleep 1
done

if [ ! -d "$MEDIUM" ]; then
  log "live medium not mounted at $MEDIUM; exiting"
  exit 0
fi

# If a persistence entity already exists (partition or file), quit
if blkid -L "$LABEL" >/dev/null 2>&1 || [ -f "$PERSISTENCE_FILE" ]; then
  log "persistence already exists; nothing to do"
  exit 0
fi

# Check available space on the medium (in KiB)
avail_kib=$(df --output=avail -k "$MEDIUM" | tail -n1 | tr -d ' ')
# require at least ~200MB overhead + requested file
min_required_kib=$(( (DEFAULT_MB + 50) * 1024 ))

if [ -z "$avail_kib" ] || [ "$avail_kib" -lt "$min_required_kib" ]; then
  log "not enough free space on medium ($avail_kib KiB); skipping persistence creation"
  exit 0
fi

# pick size: min(MAX_MB, available - 100MB)
avail_mb=$(( (avail_kib / 1024) - 100 ))
size_mb=$DEFAULT_MB
if [ "$avail_mb" -gt "$DEFAULT_MB" ]; then
  if [ "$avail_mb" -gt "$MAX_MB" ]; then
    size_mb=$MAX_MB
  else
    size_mb=$avail_mb
  fi
fi

log "creating persistence file ($size_mb MiB) at $PERSISTENCE_FILE"

# Create the sparse file (dd or fallocate). Use dd for portability.
dd if=/dev/zero of="$PERSISTENCE_FILE" bs=1M count=0 seek="$size_mb" status=none || {
  log "dd failed to create file"
  rm -f "$PERSISTENCE_FILE"
  exit 1
}

# Make ext4 filesystem inside loop file and set label
/sbin/mkfs.ext4 -F -L "$LABEL" "$PERSISTENCE_FILE" >/dev/null 2>&1 || {
  log "mkfs.ext4 failed"
  rm -f "$PERSISTENCE_FILE"
  exit 1
}

# Mount, create persistence.conf inside the new FS then unmount
TMPMNT=$(mktemp -d)
if mount -o loop "$PERSISTENCE_FILE" "$TMPMNT"; then
  echo "/ union" > "$TMPMNT/persistence.conf"
  umount "$TMPMNT"
  rmdir "$TMPMNT"
  log "persistence file created and configured"
else
  log "failed to mount newly created persistence image; removing"
  rm -f "$PERSISTENCE_FILE"
  rmdir "$TMPMNT" || true
  exit 1
fi

# Disable this service on next boots: remove the service symlink (exists under
# /etc/systemd/system/multi-user.target.wants/ when we enable it at build time).
if [ -L /etc/systemd/system/multi-user.target.wants/create-persistence.service ]; then
  rm -f /etc/systemd/system/multi-user.target.wants/create-persistence.service || true
fi

# Trigger a reboot so persistence is used in the next boot automatically
log "rebooting so persistence is picked up"
/sbin/reboot

