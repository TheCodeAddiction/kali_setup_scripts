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

echo -e "\n${RED}==> Mapping neo4j's repo...${NC}"
curl -fsSL https://debian.neo4j.com/neotechnology.gpg.key |sudo gpg --dearmor -o /usr/share/keyrings/neo4j.gpg
echo "deb [signed-by=/usr/share/keyrings/neo4j.gpg] https://debian.neo4j.com stable 4.1" | sudo tee -a /etc/apt/sources.list.d/neo4j.list

echo -e "\n${RED}==> Updating and Upgrading Packages...${NC}"
sudo apt update && sudo apt upgrade -y


echo -e "\n${RED}==> Installing required packages...${NC}"
sudo apt install -y python3-venv python3-pip gedit openssh-client neo4j openjdk-11-jdk bloodhound.py bloodhound krb5-user dirsearch smb4k keepass2 docker.io python3-wsgidav

sudo systemctl enable neo4j.service
sudo systemctl enable docker --now

echo -e "\n${RED}==> Setting up workspaces...${NC}"
xfconf-query -c xfwm4 -p /general/workspace_names -t string -s "Infra" -t string -s "Recon" -t string -s "Exploit" -t string -s "Misc" --create

echo -e "\n${RED}==> Setting keyboard layout to Norwegian...${NC}"
sudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="no"/' /etc/default/keyboard || echo 'XKBLAYOUT="no"' | sudo tee -a /etc/default/keyboard
sudo dpkg-reconfigure -f noninteractive keyboard-configuration
sudo systemctl restart keyboard-setup.service


echo -e "\n${RED}==> apache will start on boot...${NC}"
sudo systemctl enable apache2

echo -e "\n${RED}==> Adding alias for fast CD movement...${NC}"
echo "alias cg='cd ~ && cd git'" >> ~/.zshrc
echo "alias cw='cd /var/www/html'" >> ~/.zshrc


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
mkdir -p ~/.pentest-venv
python3 -m venv ~/.pentest-venv
source ~/.pentest-venv/bin/activate
if ! grep -q 'pentestenv' ~/.zshrc; then
    echo 'alias pentestenv="source ~/.pentest-venv/bin/activate"' >> ~/.zshrc
    echo 'pentestenv' >> ~/.zshrc
    echo -e "${GREEN}Added virtualenv alias to ~/.zshrc${NC}"
fi



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
    git clone git@github.com:TheCodeAddiction/html.git "$TEMP_DIR"

    echo -e "\n${RED}==> Replacing /var/www/html with cloned Git repo...${NC}"
    sudo rm -rf /var/www/html
    sudo mv "$TEMP_DIR" /var/www/html

    echo -e "\n${RED}==> Fixing permissions on /var/www/html...${NC}"
    sudo chown -R "$USER":"$USER" /var/www/html
    sudo chmod -R 755 /var/www/html
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

#if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
#    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
#fi

#grep -qxF 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' ~/.zshrc || \
#    echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
#grep -qxF 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ~/.zshrc || \
#    echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc


echo -e "\n${GREEN}==> Setup complete. Enjoy your environment!${NC}\n"

