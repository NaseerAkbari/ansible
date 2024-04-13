#!/bin/bash

containers=$(lxc list -c ns --format csv | grep RUNNING | cut -d',' -f1)

if [ -z "$containers" ]; then
    echo "No running containers to stop."
else

    for container in $containers; do
        echo "Stopping $container..."
        lxc stop $container
    done
fi


all_containers=$(lxc list -c n --format csv)

if [ -z "$all_containers" ]; then
    echo "No containers to delete."
else

    for container in $all_containers; do
        echo "Deleting $container..."
        lxc delete $container
    done
fi

systemctl restart snap.lxd.daemon
awk '/^\[containers\]$/ {print; inRange=1; next} /^\[all:vars\]$/ {inRange=0} !inRange' /root/ansible/inventory > /root/ansible/temp_inventory && mv /root/ansible/temp_inventory /root/ansible/inventory

echo "All applicable containers have been stopped and deleted."
