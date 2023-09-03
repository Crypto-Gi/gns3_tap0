# gns3_tap0


This repository contains a script that automates the configuration of a network bridge on GNS3 VM. The script sets up a bridge interface (`br0`) connected to `eth1` and a tap interface (`tap0`). It uses systemd to ensure that the configuration is applied at every boot.

## Getting Started


### Tested 
- This script has been tested on Gns3 VM version 2 and about which used base ubuntu 20.0.4 linux version.
  
### Prerequisites

- GNS3 VM version > 2.0 
- Root or sudo access

### Installation and Execution

1. **Clone the repository:**
    ```bash
    git clone https://github.com/your_username/your_repository.git
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

### Author

- **CryptoGi** - [Your GitHub Profile](https://github.com/your_username)

---

## Script Content (`install_tap0_network_service.sh`)

```bash
#!/bin/bash

# File paths
script_path="/usr/local/bin/setup_network.sh"
service_path="/etc/systemd/system/setup_network.service"

# Function to execute the network setup script
execute_setup_network() {
    echo "Executing network setup script..."
    sudo bash $script_path
}

# Step 1: Check if the network setup script already exists
if [ ! -f $script_path ]; then
    cat > $script_path << 'EOF'
#!/bin/bash

# Update package list and install necessary packages
sudo apt update -y && \
sudo apt install uml-utilities -y && \
sudo apt install bridge-utils -y && \

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

    # Make the script executable
    chmod +x $script_path

    # Execute the network setup script
    execute_setup_network
else
    echo "Network setup script already exists. Skipping..."
fi

# Step 2: Check if the systemd service file already exists
if [ ! -f $service_path ]; then
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
    echo "Systemd service file already exists. Skipping..."
fi

echo "Setup complete. The network script will run at boot if not already configured."
