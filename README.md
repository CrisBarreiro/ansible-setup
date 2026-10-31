# Workstation setup

Ansible setup for Ubuntu and macOS workstations. Ubuntu uses apt, Linuxbrew and snaps for the Linux desktop setup; macOS uses Homebrew and skips Linux-only desktop tasks.

## Requirements

- Ansible installed on the machine being configured.
- An SSH public key available in `~/.ssh` because the configured Homeshick castle is cloned over SSH.
- Access to the repository configured by `homesick_repo` in `roles/workstation-setup/defaults/main.yml`.
- On macOS, install Xcode Command Line Tools first (`xcode-select --install`).

## Run

1. Set `homesick_repo` and `homesick_castle_name` in `roles/workstation-setup/defaults/main.yml`.
2. Run `./setup.sh`.

The script asks for the sudo password for system package setup and to set zsh as the default shell. macOS installs Homebrew when it is missing.

The shared Homebrew packages, Homeshick and mise setup run on both platforms. mise installs Java 17 and is activated in zsh and bash. The Homeshick setup configures Antigen to load Powerlevel10k and removes the old Powerlevel9k config and bundle, preserving the existing prompt settings. When `setup.sh` is run in iTerm2 and no `~/.p10k.zsh` exists, it runs the interactive `p10k configure` wizard after Ansible completes. On macOS, setup also adds an iTerm2 dropdown profile toggled by F12, and creates `~/.linuxbrew` as a compatibility symlink to Homebrew for existing dotfiles that use `LINUXBREW_PATH`. The setup installs zsh and sets it as the current user's default shell. Snaps, Ubuntu packages, Plasma packages and JetBrains Toolbox desktop integration are Ubuntu-only; JetBrains Toolbox is installed on macOS through Homebrew Cask.

Edit `workstation_shared_packages` in `roles/workstation-setup/defaults/main.yml` to choose Homebrew formulae installed on both Ubuntu (through Linuxbrew) and macOS. Ubuntu desktop applications are managed through snaps.

Set `workstation_macos_casks` in the same defaults file to choose macOS-only GUI applications installed through Homebrew Cask.
