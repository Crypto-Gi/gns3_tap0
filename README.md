# gns3_tap0


This repository contains a script that automates the configuration of a network bridge on GNS3 VM. The script sets up a bridge interface (`br0`) connected to `eth1` and a tap interface (`tap0`). It uses systemd to ensure that the configuration is applied at every boot.

## Getting Started


### Tested 
- This script has been tested on Gns3 VM version 2 and about which used base ubuntu 20.0.4 linux version.
  
### Prerequisites

- GNS3 VM version > 2.0 
- Root or sudo access
- Addional Network Adapter added to GNS3 VM

### Scripts

- install_tap0_network_service.sh
- uninstall_tap0_network_service.sh


### Installation and Execution

1. **Clone the repository:**
    ```bash
    git clone https://github.com/Crypto-Gi/gns3_tap0.git
    ```

2. **Navigate to the repository directory:**
    ```bash
    cd gns3_tap0
    ```

3. **Make the script executable:**
    ```bash
    chmod +x install_tap0_network_service.sh
    ```

4. **Run the script:**
    ```bash
    sudo ./install_tap0_network_service.sh
    ```

### What the Script Does

- Checks if the `setup_network.sh` script already exists. If not, it creates it and makes it executable.
- Checks if the `setup_network.service` systemd service file already exists. If not, it creates it and enables the service.
- Executes `setup_network.sh` immediately, so you don't have to reboot your machine.

### Revert Changes

- To revert back the changes simply run 'uninstall_tap0_network_service.sh'

### Author

- **CryptoGi** - [Your GitHub Profile](https://github.com/your_username)

---

## Script Contents 

### (`install_tap0_network_service.sh`)

```bash
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

# Function to execute the network setup script
execute_setup_network() {
    echo -e "${YELLOW}→ ${WHITE}Executing network setup script... ${RED}[100%]${NC}"
    if ! sudo bash $script_path; then
        echo -e "${RED}Error executing network setup script. ${PURPLE}Continuing...${NC}"
    fi
}

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
    return $?
}

echo -e "${WHITE}Initiating Network Setup - ...${NC}"

# Step 1: Check for required packages
echo -e "${RED}→ ${WHITE}Step 1/4 ${YELLOW}Checking for required packages... ${RED}[25%]${NC}"
if ! is_package_installed "uml-utilities" || ! is_package_installed "bridge-utils"; then
    echo -e "${PURPLE}Installing required packages... ${PURPLE}[50%]${NC}"
    sudo apt update -y &> /dev/null
    sudo apt install -y uml-utilities bridge-utils &> /dev/null
else
    echo -e "${PURPLE}Required packages are already installed. ${RED}[50%]${NC}"
fi

# Step 2: Check if the network setup script already exists
echo -e "${RED}→ ${WHITE}Step 2/4 ${YELLOW}Setting up network script... ${RED}[75%]${NC}"
if [ ! -f $script_path ]; then
    echo -e "${PURPLE}Creating network setup script... ${RED}[100%]${NC}"

    # Create the script file with your network setup logic here
    cat > $script_path << 'EOF'
#!/bin/bash

# Create and configure the network interfaces
sudo tunctl -t tap0
sudo ifconfig tap0 0.0.0.0 promisc up
sudo ifconfig eth1 0.0.0.0 promisc up

# Create the bridge and add interfaces to it
sudo brctl addbr br0
sudo brctl addif br0 tap0
sudo brctl addif br0 eth1

# Bring up the bridge and tap interfaces
sudo ifconfig br0 up
sudo ifconfig tap0 up
EOF

    chmod +x $script_path
else
    echo -e "${YELLOW}Network setup script already exists. ${RED}[100%]${NC}"
fi

# Step 3: Check if the systemd service file already exists
echo -e "${RED}→ ${WHITE}Step 3/4 ${YELLOW}Setting up systemd service... ${RED}[100%]${NC}"
if [ ! -f $service_path ]; then
    echo -e "${PURPLE}Creating systemd service file... ${RED}[100%]${NC}"
    cat > $service_path << 'EOF'
[Unit]
Description=Network Setup Script

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup_network.sh

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable the service
    systemctl daemon-reload
    systemctl enable setup_network.service
else
    echo -e "${PURPLE}Systemd service file already exists. ${RED}[100%]${NC}"
fi

# Step 4: Execute the network setup script
echo -e "${RED}→ ${WHITE}Step 4/4 ${YELLOW}Executing network setup script... ${RED}[100%]${NC}"
execute_setup_network

```
### (`uninstall_tap0_network_service.sh`)

```bash
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

```

