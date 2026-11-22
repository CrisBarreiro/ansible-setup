# Workstation setup

Ansible setup for Ubuntu and macOS workstations. Ubuntu uses apt, Linuxbrew and snaps for the Linux desktop setup; macOS uses Homebrew and skips Linux-only desktop tasks.

## Requirements

- On macOS, install Xcode Command Line Tools first (`xcode-select --install`).

## Run

1. Run `./setup.sh`.
2. When prompted, choose whether to manage dotfiles. If enabled, enter a Homeshick repository URL and make sure the machine can authenticate to it.
3. On macOS, open a new iTerm2 window and run `./post-setup.sh` to configure Powerlevel10k when prompted. Setup installs the required Meslo font before this step.

The script installs Ansible when it is missing (apt on Ubuntu, Homebrew on macOS), installs the required `community.general` Ansible collection, and installs Homebrew on macOS if needed. It asks for the sudo password for package setup and to set zsh as the default shell.

The shared Homebrew packages and mise setup run on both platforms. mise installs Java 17 and is activated in zsh and bash. Dotfile management is opt-in; when enabled, the Homeshick setup configures Antigen to load Powerlevel10k and removes the old Powerlevel9k config and bundle, preserving the existing prompt settings. On macOS, setup installs the Meslo font used by Powerlevel10k; run `post-setup.sh` from a new iTerm2 window afterward to start the interactive `p10k configure` wizard. The setup also adds an iTerm2 dropdown profile toggled by F12, and creates `~/.linuxbrew` as a compatibility symlink to Homebrew for existing dotfiles that use `LINUXBREW_PATH`. The setup installs zsh and sets it as the current user's default shell. Snaps, Ubuntu packages, Plasma packages and JetBrains Toolbox desktop integration are Ubuntu-only; JetBrains Toolbox is installed on macOS through Homebrew Cask.

Edit `workstation_shared_packages` in `roles/workstation-setup/defaults/main.yml` to choose Homebrew formulae installed on both Ubuntu (through Linuxbrew) and macOS. Maestro is installed separately from the `mobile-dev-inc/tap` repository, with trust limited to its formula. Ubuntu desktop applications are managed through snaps.

Set `workstation_macos_casks` in the same defaults file to choose macOS-only GUI applications installed through Homebrew Cask. The checked-in macOS application list is the author's personal, opinionated list; edit it to remove applications you do not want or add your own. Each entry needs a Homebrew cask `name` and the corresponding installed `app_path`, for example:

```yaml
workstation_macos_casks:
  - name: firefox
    app_path: /Applications/Firefox.app
```

The default macOS applications installed through Homebrew Cask are the applications listed in `roles/workstation-setup/defaults/main.yml`, including iTerm2, Visual Studio Code, JetBrains Toolbox, Raycast, Telegram, Claude, Shottr and WhatsApp.
