#!/usr/bin/env bash
set -euo pipefail

# Install Homebrew in an interactive shell so its sudo prompt can be answered.
if [ "$(uname -s)" = "Darwin" ] && ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/c9c975046f78e6e6d662deb801bd461ebd6a54ed/install.sh)"
fi

# The Homebrew installer may not update PATH in this shell. Make the standard
# Intel and Apple Silicon locations available before using brew below.
if [ "$(uname -s)" = "Darwin" ] && ! command -v brew >/dev/null 2>&1; then
    for brew_bin in /opt/homebrew/bin /usr/local/bin; do
        if [ -x "$brew_bin/brew" ]; then
            export PATH="$brew_bin:$PATH"
            break
        fi
    done
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

# Install the collection used by the Homebrew modules.
ansible-galaxy collection install -r requirements.yml

workstation_manage_dotfiles=false
homesick_repo=""
read -r -p "Manage dotfiles with Homeshick? [y/N] " manage_dotfiles_answer
if [[ "$manage_dotfiles_answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    workstation_manage_dotfiles=true
    read -r -p "Homeshick repository URL: " homesick_repo
    if [ -z "$homesick_repo" ]; then
        echo "A Homeshick repository URL is required when dotfile management is enabled."
        exit 1
    fi
fi

platform="$(uname -s)"
needs_become=false
if [ "$platform" = "Linux" ]; then
    needs_become=true
elif [ "$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}')" != "/bin/zsh" ]; then
    needs_become=true
fi

ansible_args=(
    -i 'localhost,'
    -e "workstation_manage_dotfiles=$workstation_manage_dotfiles"
)
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
    ansible_args+=(--ask-become-pass)
else
    printf '\nZsh is already your default login shell; no administrator password is needed.\n\n'
fi
if [ -n "$homesick_repo" ]; then
    ansible_args+=( -e "homesick_repo=$homesick_repo" )
fi
ansible-playbook "${ansible_args[@]}" playbook.yml

if [ "$platform" = "Darwin" ] && [ ! -f "$HOME/.p10k.zsh" ]; then
    printf '\nSetup is complete. Open a new iTerm2 window, then run ./post-setup.sh to configure Powerlevel10k.\n'
fi
