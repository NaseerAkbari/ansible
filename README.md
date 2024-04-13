# Ansible
- A simple command, just for pinging all nodes: `ansible all -m ping`
- A simple command to update and after upgrade the packages in the nodes: `ansible all -m shell -a 'apt update && apt upgrade -y'` `-m` specifies the name of the module and the `-a` specifies the Argument.
- Reading more about documentation of any module, just type `ansible-doc *module name*`, for example `ansible-doc service`, we can search all the docs as well, like `ansible-doc -l`, this shows all modules, but we can grep or filter it too. 
- Viewing All Facts Associated with a Server: `ansible ubuntu -m setup`, this has a very long output, but the `filter program` can filter it easily. like: `ansible all -m setup -a 'filter=ansible_all_ipv6_addresses'` and the output will be: 
    ```
    10.10.10.106 | SUCCESS => {
        "ansible_facts": {
            "ansible_all_ipv6_addresses": [
                "fe80::216:3eff:fee3:16a7"
            ],
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false
    }
    10.10.10.102 | SUCCESS => {
        "ansible_facts": {
            "ansible_all_ipv6_addresses": [
                "fe80::216:3eff:fe29:2467"
            ],
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false
    }
    ```



