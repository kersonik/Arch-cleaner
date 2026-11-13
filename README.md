# Arch Linux System Cleaner

A lightweight maintenance bash script for Arch Linux systems. It safely cleans package caches, removes orphaned dependencies, trims user-space application caches, and vacuums system logs without breaking rollback capabilities.

## Features

- **Pacman cache:** Uses `paccache -rk2` to keep the 2 most recent versions of installed packages for rollback safety; purges cache of uninstalled packages. Falls back to `pacman -Sc` if `pacman-contrib` is missing.
- **Orphan packages:** Automatically removes unneeded dependencies with `pacman -Rns $(pacman -Qtdq)`.
- **AUR helpers:** Cleans build cache for `yay` or `paru` if detected.
- **Developer caches:** Prunes Python `uv` package cache.
- **Flatpak runtimes:** Removes unreferenced runtimes (`flatpak uninstall --unused`).
- **Systemd journal:** Limits journal size to the last 7 days (`journalctl --vacuum-time=7d`).
- **Browser and editor caches:** Clears temporary shader, crashpad, and cache directories for VS Code, Brave, Chrome, and Firefox while keeping settings and history intact.

## Requirements

- Arch Linux (or any Arch-based distribution)
- Recommended: `pacman-contrib` (provides `paccache`)
  ```bash
  sudo pacman -S --needed pacman-contrib
  ```

## Usage

```bash
chmod +x sys-clean.sh
./sys-clean.sh
```

### Sample Output

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

## Systemd Automation

To run the cleanup automatically once a week:

1. Create `~/.config/systemd/user/arch-cleaner.service`:
   ```ini
   [Unit]
   Description=Arch Linux System Cleanup

   [Service]
   Type=oneshot
   ExecStart=/bin/bash %h/github/projects/Arch-cleaner/sys-clean.sh
   ```

2. Create `~/.config/systemd/user/arch-cleaner.timer`:
   ```ini
   [Unit]
   Description=Weekly Arch Linux Cleanup Timer

   [Timer]
   OnCalendar=weekly
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

3. Enable and start the timer:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now arch-cleaner.timer
   ```

## License

MIT
