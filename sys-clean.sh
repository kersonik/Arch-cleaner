#!/bin/bash
# Automated cleanup script for Arch Linux (100% automatic)

echo "=== SYSTEM CLEANUP START: $(date) ==="

# 1. Clean pacman cache and remove stuck downloads (fixes fd 7 errors)
echo "[*] Cleaning package cache (pacman)..."
sudo pacman -Sc --noconfirm > /dev/null 2>&1

# 2. Remove orphan packages
echo "[*] Checking for and removing orphan packages..."
ORPHANS=$(pacman -Qdtq)
if [ -n "$ORPHANS" ]; then
    sudo pacman -Rns $ORPHANS --noconfirm > /dev/null 2>&1
else
    echo "[+] No orphans found."
fi

# 3. Clean YAY AUR helper cache (auto-confirms everything)
echo "[*] Cleaning yay cache..."
yay -Sc --noconfirm > /dev/null 2>&1

# 4. Clean Python UV cache (explicitly pointing to your home directory)
echo "[*] Cleaning uv cache..."
export UV_CACHE_DIR="/home/kersonik/.cache/uv"
uv cache clean > /dev/null 2>&1

# 5. Remove unused Flatpak runtimes
echo "[*] Cleaning flatpak cache..."
flatpak uninstall --unused -y > /dev/null 2>&1

# 6. Limit system logs (keeps only the last week)
echo "[*] Limiting system logs to max 1 week..."
sudo journalctl --vacuum-time=1weeks > /dev/null 2>&1

# 7. Clear user thumbnail cache
echo "[*] Cleaning thumbnail cache..."
rm -rf /home/kersonik/.cache/thumbnails/* > /dev/null 2>&1

echo "=== CLEANUP COMPLETE ==="
