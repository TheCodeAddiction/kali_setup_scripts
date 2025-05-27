#!/bin/bash

# -----------------------------
# Color definitions
# -----------------------------
GREEN='\033[1;36m'   # Bold cyan
RED='\033[1;31m'     # Red for step labels
YELLOW='\033[1;33m'  # Yellow
NC='\033[0m'         # No Color

set -e  # Exit immediately if a command exits with a non-zero status

# -----------------------------
# System setup
# -----------------------------
echo -e "${RED}==> Updating package list...${NC}"
sudo apt update

echo -e "${RED}==> Upgrading package list...${NC}"
sudo apt upgrade -y

echo -e "${RED}==> Installing required packages for Python venv and pip...${NC}"
sudo apt install -y python3-venv python3-pip gedit openssh-client

echo -e "${RED}==> Creating git folder on home ${NC}"
if [ ! -d "/home/kali/git" ]; then
    mkdir /home/kali/git
else
    echo -e "${YELLOW}/home/kali/git already exists. Skipping creation.${NC}"
fi

echo -e "${RED}==> Setting up git config ${NC}"
git config --global user.email "londal.martin@gmail.com"
git config --global user.name "Code Addict"

echo -e "${RED}==> Creating global Python virtual environment...${NC}"
mkdir -p ~/.pentest-venv
python3 -m venv ~/.pentest-venv
source ~/.pentest-venv/bin/activate
echo 'alias pentestenv="source ~/.pentest-venv/bin/activate"' >> ~/.zshrc
echo 'pentestenv' >> ~/.zshrc

echo -e "${RED}==> Setting keyboard layout to standard Norwegian...${NC}"
sudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="no"/' /etc/default/keyboard || echo 'XKBLAYOUT="no"' | sudo tee -a /etc/default/keyboard
sudo dpkg-reconfigure -f noninteractive keyboard-configuration
sudo systemctl restart keyboard-setup.service

echo -e "${RED}==> Making /var/www/html accessible to kali user...${NC}"
sudo chown -R "$USER":"$USER" /var/www/html
sudo chmod -R 755 /var/www/html

# -----------------------------
# GitHub-based webserver setup
# -----------------------------
read -p "$(echo -e "${RED}==> Do you want to set up the webserver with standard files from GitHub? (y/n): ${NC}")" do_git
if [[ "$do_git" =~ ^[Yy]$ ]]; then

    echo -e "${RED}==> Generating SSH key...${NC}"
    if [ ! -f ~/.ssh/id_rsa ]; then
        mkdir -p ~/.ssh
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    else
        echo -e "${GREEN}SSH key already exists, skipping...${NC}"
    fi

    echo ""
    echo -e "${RED}==> Please add the following SSH key to your GitHub profile:${NC}\n"
    echo -e "${GREEN}$(cat ~/.ssh/id_rsa.pub)${NC}"
    echo ""
    read -p "Press Enter after you've added the SSH key to GitHub..."

    echo -e "${RED}==> Setting up webserver with standard files...${NC}"
    TEMP_DIR=$(mktemp -d)

    git clone git@github.com:TheCodeAddiction/Apache-OCS-Bins.git "$TEMP_DIR"

    # Remove .git directory
    rm -rf "$TEMP_DIR/.git"

    # Move contents to /var/www/html
    sudo cp -r "$TEMP_DIR/"* /var/www/html/
    sudo cp -r "$TEMP_DIR/".* /var/www/html/ 2>/dev/null || true  # Handle hidden files like .htaccess

    # Clean up temp dir
    rm -rf "$TEMP_DIR"

else
    echo -e "${GREEN}Skipping GitHub webserver setup.${NC}"
fi

echo -e "${RED}==> Installing impacket${NC}\n"
python3 -m pipx install impacket


echo -e "${GREEN}==> All done!${NC}"

