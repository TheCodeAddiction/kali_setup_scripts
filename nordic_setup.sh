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


echo -e "${GREEN}==> Nordic theme, icons, wallpaper, and terminal font applied successfully!${NC}"

