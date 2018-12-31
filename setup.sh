#!/usr/bin/env bash
set -euo pipefail

# get sudo pass
read -sp "SUDO password: " SUDO_PASS
# check if password is correct
echo $SUDO_PASS | sudo -S echo > /dev/null 2>&1
# run playbook
ansible-playbook playbook.yml --extra-vars "ansible_become_pass=$SUDO_PASS"