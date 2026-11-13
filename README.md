# 🧹 Arch Linux Automated Maintenance & System Cleaner

> A fast, safe, and fully automated maintenance script for Arch Linux that reclaims disk space by pruning package caches, safely purging orphan dependencies, managing developer caches, and truncating journal logs.

[![OS](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)](https://archlinux.org/)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Automation](https://img.shields.io/badge/Automation-Cron%20%7C%20Systemd%20Timer-orange?style=for-the-badge)](https://wiki.archlinux.org/title/Systemd/Timers)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

---

## 📌 Overview

Over time, rolling-release systems like Arch Linux accumulate gigabytes of obsolete package versions in `/var/cache/pacman/pkg`, unneeded runtime caches from browsers and editors, and lengthy systemd journal logs.

`Arch-cleaner` automates routine system hygiene in a single command. It is designed to be **safe by default**—utilizing `paccache` to preserve rollback versions of active packages while reclaiming maximum disk capacity.

---

## ✨ Cleanup Stages & Capabilities

| Stage | Target Area | Action Performed | Safety Consideration |
| :--- | :--- | :--- | :--- |
| **1. Pacman Cache** | `/var/cache/pacman/pkg` | Uses `paccache -rk2` to keep the 2 most recent versions of installed packages; purges all uninstalled packages (`-ruk0`). Falls back to `pacman -Sc` if `pacman-contrib` is not present. | Guarantees rollback capability if a bleeding-edge package breaks. |
| **2. Orphan Packages** | System packages | Detects and removes unneeded dependency packages via `pacman -Qtdq` and `pacman -Rns`. | Only removes packages no longer required by any explicitly installed software. |
| **3. AUR Helper Cache** | `~/.cache/yay` or `~/.cache/paru` | Cleans cached build artifacts and tarballs from `yay` or `paru`. | Automatically detects which helper is installed. |
| **4. Developer Caches** | `~/.cache/uv` | Prunes cached Python wheels and virtual environments managed by `uv`. | Leaves active project virtualenvs intact. |
| **5. Flatpak Runtimes** | `/var/lib/flatpak` | Uninstalls orphaned runtimes and dependencies via `flatpak uninstall --unused -y`. | Skips if Flatpak is not installed. |
| **6. Systemd Journal** | `/var/log/journal` | Vacuums journalctl logs older than 7 days (`--vacuum-time=7d`). | Retains recent logs for troubleshooting. |
| **7. User Caches** | `~/.cache/thumbnails` | Wipes desktop thumbnail caches. | Re-generated on demand by file managers. |
| **8. Browser & IDE Caches** | VS Code, Brave, Chrome, Firefox | Cleans GPU shader, crashpad, and network caches. | Preserves user preferences, extensions, bookmarks, and history. |

---

## 🛠️ Prerequisites

- **Arch Linux** (or Arch-based distributions: EndeavourOS, Manjaro, CachyOS).
- Recommended: `pacman-contrib` (provides the official `paccache` utility):
  ```bash
  sudo pacman -S --needed pacman-contrib
  ```

---

## 🚀 Usage

### 1. Manual Execution
Make the script executable and run it directly:

```bash
chmod +x sys-clean.sh
./sys-clean.sh
```

### Example Output
```text
=== SYSTEM CLEANUP START: Fri Nov 13 18:30:00 CET 2026 ===
[*] Cleaning pacman package cache...
[*] Checking for and removing orphan dependencies...
[+] No orphan packages found.
[*] Cleaning yay cache...
[*] Cleaning Python uv cache...
[*] Limiting system logs (retaining last 7 days)...
[*] Cleaning thumbnail cache...
[*] Cleaning editor and browser caches...
=== CLEANUP COMPLETE ===
Freed disk space: ~1420 MB
```

---

## ⏰ Automated Scheduling

### Option A: Systemd Timer (Recommended)
You can schedule the cleanup script to run automatically in the background (e.g., weekly):

1. Create a user service file `~/.config/systemd/user/arch-cleaner.service`:
   ```ini
   [Unit]
   Description=Automated Arch Linux Cleanup Script

   [Service]
   Type=oneshot
   ExecStart=/bin/bash %h/github/projects/Arch-cleaner/sys-clean.sh
   ```

2. Create a timer file `~/.config/systemd/user/arch-cleaner.timer`:
   ```ini
   [Unit]
   Description=Weekly Arch Linux Cleanup Timer

   [Timer]
   OnCalendar=weekly
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

3. Enable and activate the timer:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now arch-cleaner.timer
   ```

### Option B: Crontab
Alternatively, add an entry to your user crontab (`crontab -e`):

```cron
# Run cleanup every Sunday at 03:00 AM
0 3 * * 0 /bin/bash /home/kersonik/github/projects/Arch-cleaner/sys-clean.sh > /dev/null 2>&1
```

---

## 📁 Repository Structure

```
Arch-cleaner/
├── sys-clean.sh     # Core automated maintenance and cleanup script
└── README.md        # Technical documentation and automation guide
```

---

## 📄 License

Licensed under the [MIT License](LICENSE). Contributions, suggestions, and optimizations are welcome!
