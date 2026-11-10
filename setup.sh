#!/usr/bin/env bash
set -euo pipefail

# Test whether any SSH public key is present.
if ! find "$HOME/.ssh" -maxdepth 1 -type f -name '*.pub' -print -quit 2>/dev/null | grep -q .; then
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

# Run playbook. Ansible's password prompt is intentionally hidden, so explain it first.
platform="$(uname -s)"
needs_become=false
if [ "$platform" = "Linux" ]; then
    needs_become=true
elif [ "$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}')" != "/bin/zsh" ]; then
    needs_become=true
fi

if [ "$needs_become" = true ]; then
    printf '\n============================================================\n'
    printf ' Administrator password required\n'
    printf ' Enter your local sudo password at the next prompt.\n'
    if [ "$platform" = "Linux" ]; then
        printf ' It lets Ansible install system packages and configure system settings.\n'
    else
        printf ' It lets Ansible set zsh as your default login shell.\n'
    fi
    printf '============================================================\n\n'
    ansible_options=(--ask-become-pass)
else
    printf '\nZsh is already your default login shell; no administrator password is needed.\n\n'
    ansible_options=()
fi

ansible-playbook "${ansible_options[@]}" -i 'localhost,' playbook.yml

if [ "$platform" = "Darwin" ] && [ "${TERM_PROGRAM:-}" = "iTerm.app" ] && [ ! -f "$HOME/.p10k.zsh" ]; then
    zsh -ic 'p10k configure'
fi


# sudo cp -r /path/to/ubuntu-setup-ansible/ ansetup && sudo chown -R user:user ansetup && cd ansetup && sudo -K
