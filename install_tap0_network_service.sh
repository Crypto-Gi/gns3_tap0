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
