#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root (use sudo)."
   exit 1
fi

USERNAME="ca"

# Create the user with a home directory and bash shell
useradd -m -s /bin/bash "$USERNAME"

# Set password for the user
echo "Set password for user $USERNAME:"
passwd "$USERNAME"

# Add the user to the sudo group
usermod -aG sudo "$USERNAME"

echo "User $USERNAME created and granted sudo privileges."
