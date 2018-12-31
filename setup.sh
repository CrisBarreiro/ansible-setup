#!/usr/bin/env bash
set -euo pipefail

# test if SSH key is present
if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
    echo "SSH Public Key not found"
    echo "For this setup to work, you need to add a SSH PK and set it up with GitHub"
    echo "Here's a command to create it:"
    echo "    ssh-keygen -t rsa -b 4096 -C \"your_email@example.com\""
    exit 1
fi

# get sudo pass
read -sp "SUDO password: " SUDO_PASS
# check if password is correct
echo $SUDO_PASS | sudo -S echo > /dev/null 2>&1 || ( echo "\nSUDO password incorrect" && exit 1 )
echo

# run playbook
ansible-playbook playbook.yml -e "ansible_become_pass=$SUDO_PASS"

# sudo cp -r /path/to/ubuntu-setup-ansible/ ansetup && sudo chown -R user:user ansetup && cd ansetup && sudo -K