#!/bin/bash

# ANSI escape codes for colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# File paths
script_path="/usr/local/bin/setup_network.sh"
service_path="/etc/systemd/system/setup_network.service"

# Function to execute the network setup script
execute_setup_network() {
    echo -e "${YELLOW}🚀 Falcon: Firing up the engines! Executing the network script... ${GREEN}(Step 4/5)${NC}"
    sudo bash $script_path
}

echo -e "${YELLOW}⭐ Welcome to NASA  Network Setup - Let's Reach for the Stars! ⭐${NC}"

# Step 1: Initiating script
echo -e "${YELLOW}🚀 Mission Control: The Eagle has wings! Initiating script... ${GREEN}(Step 1/5)${NC}"

# Step 2: Check if the network setup script already exists
echo -e "${YELLOW}🚀 Astronaut: Checking equipment before lift-off. Checking if network script exists... ${GREEN}(Step 2/5)${NC}"
if [ ! -f $script_path ]; then
    echo -e "${YELLOW}🚀 Mission Control: Houston, we have a solution. Creating network script... ${GREEN}(Step 3/5)${NC}"
    echo "sudo tunctl -t tap0" > $script_path
    echo "sudo ifconfig tap0 0.0.0.0 promisc up" >> $script_path
    chmod +x $script_path
    execute_setup_network
else
    echo -e "${YELLOW}🚀 Mission Control: All systems are go! Script already exists, skipping creation... ${GREEN}(Step 3/5)${NC}"
    echo -e "${YELLOW}🚀 Dragon: Ready for orbit! Just executing the network script... ${GREEN}(Step 4/5)${NC}"
    execute_setup_network
fi

# Step 5: Setting up systemd service
echo -e "${YELLOW}🚀 ISS: Welcome aboard, setting up systemd service... ${GREEN}(Step 5/5)${NC}"
if [ ! -f $service_path ]; then
    echo -e "${RED}🚀 Satellite: Initiating transmission! Creating systemd service file...${NC}"
    echo "[Unit]" > $service_path
    echo "Description=My Network Setup Service" >> $service_path
    echo "[Service]" >> $service_path
    echo "ExecStart=/usr/local/bin/setup_network.sh" >> $service_path
    echo "[Install]" >> $service_path
    echo "WantedBy=multi-user.target" >> $service_path
    sudo systemctl daemon-reload
    sudo systemctl enable setup_network.service
else
    echo -e "${RED}🚀 Mars Rover: Exploring the known territory! Systemd service file already exists, proceeding...${NC}"
fi

echo -e "${RED}⭐ Starman: To infinity and beyond! Network setup is complete! ⭐${NC}"
