#!/bin/sh
# update-tailscale.sh
# Generic Tailscale updater for OpenWrt/GL.iNet
# - Uses existing opkg feeds
# - Backs up /etc/tailscale
# - Force-reinstalls tailscale package
# - Restarts and shows version/IPs

set -eu

log() { printf "%s\n" "$*" >&2; }

need_root() { [ "$(id -u)" -eq 0 ] || { log "Run as root."; exit 1; } }
svc() { [ -x /etc/init.d/tailscale ] && /etc/init.d/tailscale "$@" || true; }

need_root

log "==> Detecting system…"
ubus call system board 2>/dev/null || true
ARCH="$(opkg print-architecture | awk '/priority 10/ {print $2}' || true)"
log "Architecture: ${ARCH:-unknown}"

# 1) Stop service & backup state (non-fatal)
log "==> Stopping tailscale…"
svc stop || true

STATE_DIR="/etc/tailscale"
BACKUP="/root/tailscale-$(date +%Y%m%d-%H%M%S).tgz"
if [ -d "$STATE_DIR" ]; then
  log "==> Backing up ${STATE_DIR} to ${BACKUP}"
  tar czf "$BACKUP" "$STATE_DIR" 2>/dev/null || true
else
  log "==> No ${STATE_DIR} to backup."
fi

# 2) Update package lists
log "==> opkg update…"
opkg update

# 3) Reinstall tailscale (and tailscaled if split package exists)
#    Some builds only have 'tailscale'; others also ship 'tailscaled'.
PKGS=""
if opkg list tailscale >/dev/null 2>&1; then
  PKGS="$PKGS tailscale"
fi
if opkg list tailscaled >/dev/null 2>&1; then
  PKGS="$PKGS tailscaled"
fi

if [ -z "$PKGS" ]; then
  log "!! No 'tailscale' package found in your current feeds."
  log "   Add an appropriate feed or update your distfeeds.conf, then rerun."
  exit 2
fi

log "==> Installing (force-reinstall):${PKGS}"
# --force-reinstall will upgrade if newer exists, or reinstall current
opkg install --force-reinstall $PKGS

# 4) Ensure enabled, start, and show version
log "==> Enabling & starting tailscale…"
svc enable
svc start

# 5) Show version and IPs
if command -v tailscale >/dev/null 2>&1; then
  log "==> tailscale version:"
  tailscale version || true
  log "==> tailscale IPs:"
  tailscale ip -4 || true
  tailscale ip -6 || true
else
  log "!! tailscale binary not found in PATH after install."
  exit 3
fi

log "Done."