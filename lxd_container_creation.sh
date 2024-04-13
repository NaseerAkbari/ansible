#!/bin/bash


baseName="LXD-Container"
numContainers=$1
baseIP="10.10.10." 
startIP=101 
publicKeyPath="/root/.ssh/id_rsa.pub"
inventoryPath="/root/ansible/inventory"
# Loop for creation and configure each container
for i in $(seq 1 $numContainers); 
do
    containerName="${baseName}-${i}"
    ipSuffix=$((startIP + i - 1)) # Calculate IP suffix for each container
    containerIP="${baseIP}${ipSuffix}" # Full IP address for the container

    echo "Creating $containerName with IP $containerIP"
    
    # Create the container with the specified OS
    lxc launch ubuntu:22.04 $containerName
    
    # Wait a bit for the container to fully start
    sleep 10
    
    # Now, configure a static IP for the container
    lxc stop $containerName # Stop the container to change its network configuration
    lxc network attach lxdbr0 $containerName eth0 eth0 # Ensure the container's NIC is attached to the bridge
    lxc config device set $containerName eth0 ipv4.address $containerIP # Assign the static IP
    lxc start $containerName # Start the container again

    lxc exec $containerName -- mkdir -p /root/.ssh
    lxc exec $containerName -- chmod 700 /root/.ssh
    lxc file push "$publicKeyPath" "$containerName/root/.ssh/authorized_keys"
    lxc exec $containerName -- chmod 600 /root/.ssh/authorized_keys
    awk '/^\[containers\]$/ {print; print '$containerIP'; next} 1' /root/ansible/inventory > /root/ansible/temp_inventory && mv /root/ansible/temp_inventory "$inventoryPath"


done
rm ~/.ssh/known_host* >>/dev/null