#!/bin/bash

# -----------------------------
# Color definitions
# -----------------------------
GREEN='\033[1;32m'   # Green for success/info
RED='\033[1;31m'     # Red for section headers
YELLOW='\033[1;33m'  # Yellow for warnings
CYAN='\033[1;36m'    # Cyan for prompts
NC='\033[0m'         # No Color

set -e  # Exit immediately if a command exits with a non-zero status

# -----------------------------
# System setup
# -----------------------------
echo -e "\n${RED}==> Updating and Upgrading Packages...${NC}"
sudo apt update && sudo apt upgrade -y


echo -e "\n${RED}==> Installing required packages...${NC}"
sudo apt install -y python3-venv python3-pip gedit openssh-client


echo -e "\n${RED}==> Setting up workspaces...${NC}"
xfconf-query -c xfwm4 -p /general/workspace_names -t string -s "Infra" -t string -s "Recon" -t string -s "Exploit" -t string -s "Misc" --create

echo -e "\n${RED}==> Setting keyboard layout to Norwegian...${NC}"
sudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="no"/' /etc/default/keyboard || echo 'XKBLAYOUT="no"' | sudo tee -a /etc/default/keyboard
sudo dpkg-reconfigure -f noninteractive keyboard-configuration
sudo systemctl restart keyboard-setup.service


echo -e "\n${RED}==> Adjusting permissions on /var/www/html...${NC}"
sudo chown -R "$USER":"$USER" /var/www/html
sudo chmod -R 755 /var/www/html

echo -e "\n${RED}==> Starting apache webserver...${NC}"
sudo service apache2 start


echo -e "\n${RED}==> Creating Git directory...${NC}"
if [ ! -d "$HOME/git" ]; then
    mkdir "$HOME/git"
    echo -e "${GREEN}Created ~/git${NC}"
else
    echo -e "${YELLOW}~/git already exists. Skipping.${NC}"
fi


echo -e "\n${RED}==> Configuring Git...${NC}"
git config --global user.email "londal.martin@gmail.com"
git config --global user.name "Code Addict"
echo -e "${GREEN}Git configured with user 'Code Addict'.${NC}"



echo -e "\n${RED}==> Creating Python virtual environment...${NC}"
mkdir -p ~/.🐍
python3 -m venv ~/.🐍
source ~/.🐍/bin/activate

# Avoid default virtualenv prompt
if ! grep -q 'VIRTUAL_ENV_DISABLE_PROMPT=1' ~/.zshrc; then
    echo 'export VIRTUAL_ENV_DISABLE_PROMPT=1' >> ~/.zshrc
fi

# Add alias and custom prompt
if ! grep -q 'alias pentestenv=' ~/.zshrc; then
    echo 'alias pentestenv="source ~/.🐍/bin/activate"' >> ~/.zshrc
    echo 'pentestenv' >> ~/.zshrc
    echo -e "${GREEN}Added virtualenv alias and auto-activation to ~/.zshrc${NC}"
fi

# Add custom prompt if not present
if ! grep -q 'PROMPT=' ~/.zshrc; then
    echo 'PROMPT="%F{green}🐍 %f%~ %# "' >> ~/.zshrc
fi

echo -e "\n${RED}==> Installing impacket...${NC}"
python3 -m pip install impacket



# -----------------------------
# GitHub-based webserver setup
# -----------------------------
echo -e "\n${RED}==> Webserver GitHub Setup${NC}"
read -p "$(echo -e "${CYAN}Do you want to set up the webserver with standard files from GitHub? (y/n): ${NC}")" do_git
if [[ "$do_git" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Setting up webserver files...${NC}"

    echo -e "\n${RED}==> Generating SSH key if needed...${NC}"
    if [ ! -f ~/.ssh/id_rsa ]; then
        mkdir -p ~/.ssh
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    else
        echo -e "${YELLOW}SSH key already exists. Skipping.${NC}"
    fi

    echo -e "\n${CYAN}Add this SSH key to your GitHub profile:${NC}"
    echo -e "${GREEN}$(cat ~/.ssh/id_rsa.pub)${NC}"
    read -p "Press Enter once the key has been added to GitHub..."

    TEMP_DIR=$(mktemp -d)
    git clone git@github.com:TheCodeAddiction/Apache-OCS-Bins.git "$TEMP_DIR"

    rm -rf "$TEMP_DIR/.git"
    sudo cp -r "$TEMP_DIR/"* /var/www/html/
    sudo cp -r "$TEMP_DIR/".* /var/www/html/ 2>/dev/null || true
    rm -rf "$TEMP_DIR"
else
    echo -e "${YELLOW}Skipping webserver setup.${NC}"
fi


# -----------------------------
# Zsh / oh-my-zsh / Powerlevel10k setup
# -----------------------------
echo -e "\n${RED}==> Installing Zsh plugins and Powerlevel10k...${NC}"
sudo apt install -y zsh-syntax-highlighting zsh-autosuggestions

if [ ! -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
    echo -e "${GREEN}Installing oh-my-zsh...${NC}"
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Update .zshrc
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
fi

grep -qxF 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' ~/.zshrc || \
    echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
grep -qxF 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ~/.zshrc || \
    echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc


echo -e "\n${GREEN}==> Setup complete. Enjoy your environment!${NC}\n"

