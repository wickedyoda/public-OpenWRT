#!/bin/sh
# Sync public-OpenWRT repo locally
# Works on OpenWrt/GL.iNet

set -e

# Require root (sudo usually isn't present on OpenWrt)
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Ensure Git is installed (try to install via opkg if available)
if ! command -v git >/dev/null 2>&1; then
  if command -v opkg >/dev/null 2>&1; then
    echo "Git not found; installing via opkg…"
    opkg update && opkg install git || {
      echo "Error: Failed to install git via opkg."; exit 1;
    }
  else
    echo "Error: Git is not installed. Please install it and re-run."; exit 1
  fi
fi

# Remote repo and local dir
REMOTE_REPO="https://github.com/wickedyoda/public-OpenWRT.git"
LOCAL_DIR="./public-OpenWRT"

# If local dir exists and not empty, remove it
if [ -d "$LOCAL_DIR" ] && [ -n "$(ls -A "$LOCAL_DIR" 2>/dev/null || true)" ]; then
  echo "Existing directory detected. Deleting $LOCAL_DIR..."
  rm -rf "$LOCAL_DIR"
fi

# Clone fresh
echo "Cloning repository from $REMOTE_REPO to $LOCAL_DIR..."
git clone "$REMOTE_REPO" "$LOCAL_DIR"

# Set sane permissions
echo "Setting permissions for $LOCAL_DIR..."
chmod -R 755 "$LOCAL_DIR"

echo "Done."