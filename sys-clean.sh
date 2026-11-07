#!/bin/bash
# Automated cleanup script for Arch Linux (100% automatic)

echo "=== SYSTEM CLEANUP START: $(date) ==="

before=$(df / --output=avail | tail -1)

# 1. Clean pacman cache
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

# 3. Clean YAY cache
echo "[*] Cleaning yay cache..."
yay -Sc --noconfirm > /dev/null 2>&1

# 4. Clean Python UV cache
echo "[*] Cleaning uv cache..."
export UV_CACHE_DIR="/home/kersonik/.cache/uv"
uv cache clean > /dev/null 2>&1

# 5. Remove unused Flatpak runtimes
echo "[*] Cleaning flatpak cache..."
flatpak uninstall --unused -y > /dev/null 2>&1

# 6. Limit system logs
echo "[*] Limiting system logs to max 1 week..."
sudo journalctl --vacuum-time=1weeks > /dev/null 2>&1

# 7. Clear thumbnail cache
echo "[*] Cleaning thumbnail cache..."
rm -rf /home/kersonik/.cache/thumbnails/* > /dev/null 2>&1

# 8. Clean VS Code & Brave browser caches
echo "[*] Cleaning editor and browser caches..."
rm -rf /home/kersonik/.config/Code/Cache/* \
       /home/kersonik/.config/Code/CachedData/* \
       /home/kersonik/.config/Code/Crashpad/* \
       /home/kersonik/.config/BraveSoftware/Brave-Browser/Default/Cache/* \
       /home/kersonik/.config/BraveSoftware/Brave-Browser/Default/Code\ Cache/* \
       /home/kersonik/.config/BraveSoftware/Brave-Browser/GrShaderCache/* \
       /home/kersonik/.config/BraveSoftware/Brave-Browser/ShaderCache/* > /dev/null 2>&1

after=$(df / --output=avail | tail -1)
freed=$(( (after - before) / 1024 ))

echo "=== CLEANUP COMPLETE ==="
echo "Freed: ${freed}M"
