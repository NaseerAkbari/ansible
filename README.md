# Ansible
- A simple command, just for pinging all nodes: `ansible all -m ping`
- A simple command to update and after upgrade the packages in the nodes: `ansible all -m shell -a 'apt update && apt upgrade -y'` `-m` specifies the name of the module and the `-a` specifies the Argument.
- Reading more about documentation of any module, just type `ansible-doc *module name*`, for example `ansible-doc service`, we can search all the docs as well, like `ansible-doc -l`, this shows all modules, but we can grep or filter it too. 


