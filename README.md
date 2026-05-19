# System Cleanup Script

A silent, fully automated bash script for Arch Linux maintenance.

## Features
* **Pacman & Yay:** Clears package caches and removes orphan dependencies.
* **Flatpak:** Uninstalls unused runtimes.
* **Cache Management:** Prunes `uv` (Python) and thumbnail caches.
* **System Logs:** Limits journal logs to 1 week.
* **Silent:** Runs without user intervention (`--noconfirm`).
