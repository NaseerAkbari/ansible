#!/bin/bash

# Check if the correct number of arguments is given
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 [container-name-base] [num-containers] [OS type]"
    exit 1
fi

baseName="LXD-Container-$1"
numContainers=$2
osType=$3
baseIP="10.10.10."
startIP=101 # Default starting IP suffix
publicKeyPath="/root/.ssh/id_rsa.pub"
inventoryPath="/root/ansible/inventory"

# Fetch existing container IPs and determine the next start IP
existingIPs=$(lxc list -c n,4 | grep -oP '10\.10\.10\.\K\d+' | sort -n)
if [ ! -z "$existingIPs" ]; then
    highestIP=$(echo "$existingIPs" | tail -n 1)
    if [ "$highestIP" -ge "$startIP" ]; then
        startIP=$(($highestIP + 1))
    fi
fi

# Loop for creation and configure each container
for i in $(seq 1 $numContainers); 
do
    containerName="${baseName}-${i}"
    ipSuffix=$((startIP + i - 1)) # Calculate IP suffix for each container
    containerIP="${baseIP}${ipSuffix}" # Full IP address for the container

    echo "Creating $containerName with IP $containerIP"

    # Determine the correct OS image to use
    # Determine the correct OS image to use
    case $osType in
        Ubuntu)
            image="ubuntu:22.04"
            ;;
        Alma)
            image="images:almalinux/9/arm64"
            ;;
        *)
            echo "Unsupported OS type: $osType"
            exit 2
            ;;
    esac

    # Create the container with the specified OS
    lxc launch $image $containerName

    # Wait a bit for the container to fully start
    sleep 10

    # Commands specific to AlmaLinux for installing and starting SSH
    if [ "$osType" = "Alma" ]; then
        # lxc exec $containerName -- dnf install -y openssh-server >> /dev/null
        # lxc exec $containerName -- systemctl start sshd
        # lxc exec $containerName -- systemctl enable sshd
        lxc exec $containerName -- bash -c 'dnf install -y openssh-server > /dev/null 2>&1'
        lxc exec $containerName -- bash -c 'systemctl start sshd > /dev/null 2>&1'
        lxc exec $containerName -- bash -c 'systemctl enable sshd > /dev/null 2>&1'

    fi


    # Now, configure a static IP for the container
    lxc stop $containerName
    lxc network attach lxdbr0 $containerName eth0 eth0
    lxc config device set $containerName eth0 ipv4.address $containerIP
    lxc start $containerName

    lxc exec $containerName -- mkdir -p /root/.ssh
    lxc exec $containerName -- chmod 700 /root/.ssh
    lxc file push "$publicKeyPath" "$containerName/root/.ssh/authorized_keys"
    lxc exec $containerName -- chmod 600 /root/.ssh/authorized_keys
    awk '/^\[containers\]$/ {print; print "'$containerIP'"; next} 1' $inventoryPath > /root/ansible/temp_inventory && mv /root/ansible/temp_inventory $inventoryPath

done

# Clean up SSH known hosts
rm -f ~/.ssh/known_hosts*
