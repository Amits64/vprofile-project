#!/bin/bash

# Install Java and wget
sudo apt-get update
sudo apt-get install openjdk-8-jdk wget -y

# Create necessary directories
sudo mkdir -p /opt/nexus/
sudo mkdir -p /tmp/nexus/
cd /tmp/nexus/

# Download Nexus
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz
sleep 10

# Extract Nexus
EXTOUT=$(tar xzvf nexus.tar.gz)
NEXUSDIR=$(echo $EXTOUT | cut -d '/' -f1)
sleep 5

# Clean up
rm -rf /tmp/nexus/nexus.tar.gz
sudo cp -r /tmp/nexus/* /opt/nexus/

sleep 5

# Create nexus user
sudo useradd nexus
sudo chown -R nexus:nexus /opt/nexus
sudo chmod -R 755 /opt/nexus
sudo systemctl restart nexus

# Create systemd service file
sudo bash -c 'cat <<EOT > /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/'$NEXUSDIR'/bin/nexus start
ExecStop=/opt/nexus/'$NEXUSDIR'/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT'

# Configure Nexus to run as nexus user
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/$NEXUSDIR/bin/nexus.rc

# Reload systemd and start Nexus
sudo systemctl daemon-reload
sudo systemctl start nexus
sudo systemctl enable nexus
