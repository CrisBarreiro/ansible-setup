#!/usr/bin/env bash
set -euo pipefail

# test if SSH key is present
if [ ! -f $HOME/.ssh/id_rsa.pub ] && [ ! -f $HOME/.ssh/id_ecdsa.pub ]; then
    echo "SSH Public Key not found"
    echo "For this setup to work, you need to add a SSH PK and set it up with the homeshick master repo host"
    echo "Here's a command to create it:"
    echo "    ssh-keygen -t rsa -b 4096 -C \"your_email@example.com\""
    exit 1
fi

# run playbook
ansible-playbook playbook.yml


# sudo cp -r /path/to/ubuntu-setup-ansible/ ansetup && sudo chown -R user:user ansetup && cd ansetup && sudo -K