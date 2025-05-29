#!/bin/bash

# -----------------------------
# Nordic Theme + Terminal Font + Wallpaper Setup for XFCE (Kali Linux)
# -----------------------------

set -e  # Exit on error

echo "[+] Installing Nordic GTK Theme..."

# Create themes directory if missing
mkdir -p ~/.themes

# Clone the official Nordic theme
if [ ! -d "$HOME/.themes/Nordic" ]; then
    git clone https://github.com/EliverLara/Nordic.git ~/.themes/Nordic
else
    echo "[!] Nordic theme already exists in ~/.themes. Skipping clone."
fi

# Apply GTK theme
echo "[+] Applying Nordic GTK theme..."
xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic"

# Apply window manager theme
echo "[+] Applying Nordic Window Manager theme..."
xfconf-query -c xfwm4 -p /theme -n -t string -s "Nordic"

# Install and apply Papirus icon theme
echo "[+] Installing and applying Papirus-Dark icon theme..."
sudo apt install -y papirus-icon-theme
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"

# Restart window manager
echo "[+] Restarting XFCE Window Manager..."
xfwm4 --replace & disown

# -----------------------------
# Set Wallpaper
# -----------------------------
echo "[+] Setting Nordic wallpaper..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_PATH="${SCRIPT_DIR}/Nordic-mountain-wallpaper.jpeg"

WALLPAPER_KEYS=$(xfconf-query -c xfce4-desktop -l | grep last-image)

for KEY in $WALLPAPER_KEYS; do
    echo "  -> Setting $KEY to $WALLPAPER_PATH"
    xfconf-query -c xfce4-desktop -p "$KEY" -s "$WALLPAPER_PATH"
done

xfdesktop --reload

echo "[✓] Nordic theme, icons, wallpaper, and terminal font applied successfully!"

