#!/bin/bash

# ANSI escape codes for colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# File paths
script_path="/usr/local/bin/setup_network.sh"
service_path="/etc/systemd/system/setup_network.service"

# Function to remove network setup
remove_setup_network() {
    echo -e "${RED}→ ${WHITE}Removing network setup... ${PURPLE}[50%]${NC}"

    # Check if tap0 and br0 interfaces exist, and remove them
    if ip link show tap0 &> /dev/null; then
        sudo tunctl -d tap0
    fi

    if ip link show br0 &> /dev/null; then
        sudo ifconfig br0 down
        sudo brctl delbr br0
    fi
}

# Step 1: Remove systemd service
echo -e "${RED}→ ${WHITE}Step 1/4 ${YELLOW}Removing systemd service... ${PURPLE}[25%]${NC}"
sudo systemctl disable setup_network.service &> /dev/null
sudo rm -f $service_path
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Step 2: Remove network setup script
echo -e "${RED}→ ${WHITE}Step 2/4 ${YELLOW}Removing network setup script... ${PURPLE}[50%]${NC}"
sudo rm -f $script_path

# Step 3: Removing networking setup
remove_setup_network

# Step 4: Remove installed packages
echo -e "${RED}→ ${WHITE}Step 4/4 ${YELLOW}Removing installed packages... ${PURPLE}[100%]${NC}"
sudo apt-get remove --purge -y uml-utilities bridge-utils &> /dev/null
sudo apt-get autoremove -y &> /dev/null
sudo apt-get autoclean &> /dev/null

echo -e "${GREEN}Uninstallation complete. System reverted to previous state.${NC}"
