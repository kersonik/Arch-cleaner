#!/usr/bin/env bash
# ==============================================================================
# Automated System Maintenance & Cleanup Script for Arch Linux
# Cleans package caches, removes orphan packages, prunes system logs and caches.
# ==============================================================================

set -uo pipefail

echo "=== SYSTEM CLEANUP START: $(date) ==="

# Record available disk space on root before cleanup (in 1K blocks)
before=$(df / --output=avail | tail -1)

# 1. Clean Pacman cache
echo "[*] Cleaning pacman package cache..."
if command -v paccache >/dev/null 2>&1; then
    # Keep last 2 installed versions for rollback safety, clean uninstalled packages completely
    sudo paccache -rk2 >/dev/null 2>&1 || true
    sudo paccache -ruk0 >/dev/null 2>&1 || true
else
    sudo pacman -Sc --noconfirm >/dev/null 2>&1 || true
fi

# 2. Remove orphan packages
echo "[*] Checking for and removing orphan dependencies..."
ORPHANS=$(pacman -Qtdq 2>/dev/null || true)
if [ -n "$ORPHANS" ]; then
    echo "[+] Removing orphan packages: $ORPHANS"
    sudo pacman -Rns --noconfirm $ORPHANS >/dev/null 2>&1 || true
else
    echo "[+] No orphan packages found."
fi

# 3. Clean AUR helper cache (yay / paru)
if command -v yay >/dev/null 2>&1; then
    echo "[*] Cleaning yay cache..."
    yay -Sc --noconfirm >/dev/null 2>&1 || true
elif command -v paru >/dev/null 2>&1; then
    echo "[*] Cleaning paru cache..."
    paru -Sc --noconfirm >/dev/null 2>&1 || true
fi

# 4. Clean Python UV cache
if command -v uv >/dev/null 2>&1; then
    echo "[*] Cleaning Python uv cache..."
    uv cache clean >/dev/null 2>&1 || true
fi

# 5. Remove unused Flatpak runtimes
if command -v flatpak >/dev/null 2>&1; then
    echo "[*] Cleaning unused Flatpak runtimes..."
    flatpak uninstall --unused -y >/dev/null 2>&1 || true
fi

# 6. Vacuum systemd journal logs to 7 days
if command -v journalctl >/dev/null 2>&1; then
    echo "[*] Limiting system logs (retaining last 7 days)..."
    sudo journalctl --vacuum-time=7d >/dev/null 2>&1 || true
fi

# 7. Clear user thumbnail cache
echo "[*] Cleaning thumbnail cache..."
rm -rf "$HOME/.cache/thumbnails"/* 2>/dev/null || true

# 8. Clean VS Code & browser caches
echo "[*] Cleaning editor and browser caches..."
rm -rf \
    "$HOME/.config/Code/Cache"/* \
    "$HOME/.config/Code/CachedData"/* \
    "$HOME/.config/Code/Crashpad"/* \
    "$HOME/.config/Code - OSS/Cache"/* \
    "$HOME/.config/Code - OSS/CachedData"/* \
    "$HOME/.config/BraveSoftware/Brave-Browser/Default/Cache"/* \
    "$HOME/.config/BraveSoftware/Brave-Browser/Default/Code Cache"/* \
    "$HOME/.config/BraveSoftware/Brave-Browser/GrShaderCache"/* \
    "$HOME/.config/BraveSoftware/Brave-Browser/ShaderCache"/* \
    "$HOME/.cache/google-chrome/Default/Cache"/* \
    "$HOME/.cache/mozilla/firefox"/*/cache2/* \
    2>/dev/null || true

# Calculate freed disk space
after=$(df / --output=avail | tail -1)
freed_mb=$(( (after - before) / 1024 ))

echo "=== CLEANUP COMPLETE ==="
if [ "$freed_mb" -gt 0 ]; then
    echo "Freed disk space: ~${freed_mb} MB"
else
    echo "Disk clean; no significant space reclaimed."
fi
