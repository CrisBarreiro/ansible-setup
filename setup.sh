#!/usr/bin/env bash
set -euo pipefail

# test if SSH key is present
if [ ! -f $HOME/.ssh/id_rsa.pub ] && [ ! -f $HOME/.ssh/id_ecdsa.pub ]  && [ ! -f $HOME/.ssh/id_ed25519.pub ] ; then
    echo "SSH Public Key not found"
    echo "For this setup to work, you need to add a SSH PK and set it up with the homeshick master repo host"
    echo "Here's a command to create it:"
    echo "    ssh-keygen -t rsa -b 4096 -C \"your_email@example.com\""
    exit 1
fi

# Install Homebrew in an interactive shell so its sudo prompt can be answered.
if [ "$(uname -s)" = "Darwin" ] && ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Ansible when it is not already available.
if ! command -v ansible-playbook >/dev/null 2>&1; then
    case "$(uname -s)" in
        Darwin)
            brew install ansible
            ;;
        Linux)
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update
                sudo apt-get install -y ansible
            else
                echo "Ansible is missing. Install it with your Linux distribution's package manager, then rerun this script."
                exit 1
            fi
            ;;
        *)
            echo "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
fi

# run playbook; only Linux package tasks need privilege escalation
if [ "$(uname -s)" = "Linux" ]; then
    ansible-playbook -i 'localhost,' --ask-become-pass playbook.yml
else
    ansible-playbook -i 'localhost,' --ask-become-pass playbook.yml
    if [ "${TERM_PROGRAM:-}" = "iTerm.app" ] && [ ! -f "$HOME/.p10k.zsh" ]; then
        zsh -ic 'p10k configure'
    fi
fi


# sudo cp -r /path/to/ubuntu-setup-ansible/ ansetup && sudo chown -R user:user ansetup && cd ansetup && sudo -K
