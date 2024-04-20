#!/bin/bash

# Check if an argument was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [keyword]"
    exit 1
fi

keyword=$1

# Fetch the list of running containers that match the keyword
running_containers=$(lxc list -c ns --format csv | grep RUNNING | cut -d',' -f1 | grep $keyword)

if [ -z "$running_containers" ]; then
    echo "No running containers matching '$keyword' to stop."
else
    for container in $running_containers; do
        echo "Stopping $container..."
        lxc stop $container
    done
fi

# Fetch the list of all containers that match the keyword
all_containers=$(lxc list -c n --format csv | grep $keyword)

if [ -z "$all_containers" ]; then
    echo "No containers matching '$keyword' to delete."
else
    for container in $all_containers; do
        echo "Deleting $container..."
        lxc delete $container --force
    done
fi

systemctl restart snap.lxd.daemon

# Update the Ansible inventory
awk '/^\[containers\]$/ {print; inRange=1; next} /^\[all:vars\]$/ {inRange=0} !inRange' /root/ansible/inventory > /root/ansible/temp_inventory && mv /root/ansible/temp_inventory /root/ansible/inventory

echo "All applicable containers matching '$keyword' have been stopped and deleted."
