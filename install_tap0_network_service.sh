#!/bin/bash

# ANSI escape codes for colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# File paths
script_path="/usr/local/bin/setup_network.sh"
service_path="/etc/systemd/system/setup_network.service"

# Function to execute the network setup script
execute_setup_network() {
    echo -e "${GREEN}Executing network setup script... (Step 1/5)${NC}"
    sudo bash $script_path
}

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
    return $?
}

echo -e "${GREEN}Initiating Network Setup ...${NC}"

# Step 1: Check for required packages
echo -e "${GREEN}Checking for required packages... (Step 2/5)${NC}"
if ! is_package_installed "uml-utilities" || ! is_package_installed "bridge-utils"; then
    echo -e "${RED}Updating package list...${NC}"
    sudo apt update -y
else
    echo -e "${GREEN}Required packages are already installed. Skipping package list update.${NC}"
fi

# Step 2: Check if the network setup script already exists
echo -e "${GREEN}Setting up network script... (Step 3/5)${NC}"
if [ ! -f $script_path ]; then
    echo -e "${RED}Creating network setup script...${NC}"
    cat > $script_path << 'EOF'
#!/bin/bash

# Install uml-utilities if not already installed
if ! is_package_installed "uml-utilities"; then
    sudo apt install uml-utilities -y
fi

# Install bridge-utils if not already installed
if ! is_package_installed "bridge-utils"; then
    sudo apt install bridge-utils -y
fi

# Create and configure the network interfaces
sudo tunctl -t tap0 && \
sudo ifconfig tap0 0.0.0.0 promisc up && \
sudo ifconfig eth1 0.0.0.0 promisc up && \

# Create the bridge and add interfaces to it
sudo brctl addbr br0 && \
sudo brctl addif br0 tap0 && \
sudo brctl addif br0 eth1 && \

# Bring up the bridge and tap interfaces
sudo ifconfig br0 up && \
sudo ifconfig tap0 up
EOF

    echo "is_package_installed() {" >> $script_path
    echo "    dpkg -l \"\$1\" &> /dev/null" >> $script_path
    echo "    return \$?" >> $script_path
    echo "}" >> $script_path

    # Make the script executable
    chmod +x $script_path

    # Execute the network setup script
    execute_setup_network
else
    echo -e "${GREEN}Network setup script already exists. Skipping... (Step 4/5)${NC}"
fi

# Step 4: Check if the systemd service file already exists
echo -e "${GREEN}Setting up systemd service... (Step 5/5)${NC}"
if [ ! -f $service_path ]; then
    echo -e "${RED}Creating systemd service file...${NC}"
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
    echo -e "${GREEN}Systemd service file already exists. Skipping...${NC}"
fi

echo -e "${GREEN}Setup complete. The network script will run at boot if not already configured.${NC}"
