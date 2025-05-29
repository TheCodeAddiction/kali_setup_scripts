#!/bin/bash

# -----------------------------
# Color definitions
# -----------------------------
GREEN='\033[1;36m'   # Bold cyan
RED='\033[1;31m'     # Red for step labels
YELLOW='\033[1;33m'  # Yellow
NC='\033[0m'         # No Color

set -e  # Exit on error

echo -e "${RED}==> Installing Nordic GTK Theme...${NC}"

# Create themes directory if missing
mkdir -p ~/.themes

# Clone the official Nordic theme
if [ ! -d "$HOME/.themes/Nordic" ]; then
    git clone https://github.com/EliverLara/Nordic.git ~/.themes/Nordic
else
    echo -e "${YELLOW}[!] Nordic theme already exists in ~/.themes. Skipping clone.${NC}"
fi

# Apply GTK theme
echo -e "${RED}==> Applying Nordic GTK theme...${NC}"
xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic"

# Apply window manager theme
echo -e "${RED}==> Applying Nordic Window Manager theme...${NC}"
xfconf-query -c xfwm4 -p /theme -n -t string -s "Nordic"

# Install and apply Papirus icon theme
echo -e "${RED}==> Installing and applying Papirus-Dark icon theme...${NC}"
sudo apt install -y papirus-icon-theme
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"

# Restart window manager
echo -e "${RED}==> Restarting XFCE Window Manager...${NC}"
xfwm4 --replace & disown

# -----------------------------
# Set Wallpaper
# -----------------------------
echo -e "${RED}==> Setting Nordic wallpaper...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_PATH="${SCRIPT_DIR}/Nordic-mountain-wallpaper.jpeg"

WALLPAPER_KEYS=$(xfconf-query -c xfce4-desktop -l | grep last-image)

for KEY in $WALLPAPER_KEYS; do
    echo -e "${YELLOW}  -> Setting $KEY to $WALLPAPER_PATH${NC}"
    xfconf-query -c xfce4-desktop -p "$KEY" -s "$WALLPAPER_PATH"
done

xfdesktop --reload

# -----------------------------
# Terminal Font Fix
# -----------------------------
echo -e "${RED}==> Setting terminal font to FiraCode Nerd Font 12...${NC}"

TERMINAL_CONF="$HOME/.config/xfce4/terminal/terminalrc"

mkdir -p "$(dirname "$TERMINAL_CONF")"
touch "$TERMINAL_CONF"

# Clean up old settings
sed -i '/^UseSystemFont/d' "$TERMINAL_CONF"
sed -i '/^FontName/d' "$TERMINAL_CONF"

# Apply new font settings
echo "UseSystemFont=FALSE" >> "$TERMINAL_CONF"
echo "FontName=FiraCode Nerd Font 12" >> "$TERMINAL_CONF"

echo -e "${GREEN}==> Nordic theme, icons, wallpaper, and terminal font applied successfully!${NC}"

