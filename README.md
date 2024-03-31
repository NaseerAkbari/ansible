# Ansible
A simple command, just for pinging all nodes
- `ansible all -m ping`

A simple command to update and after upgrade the packages in the nodes.
- `ansible all -m shell -a 'apt update && apt upgrade -y'`
