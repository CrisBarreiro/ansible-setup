# Workstation setup

Ansible setup for Ubuntu and macOS workstations. Ubuntu uses apt, Linuxbrew and snaps for the Linux desktop setup; macOS uses Homebrew and skips Linux-only desktop tasks.

## Requirements

- On macOS, Xcode Command Line Tools are required. `setup.sh` starts Apple’s installer automatically if they are missing; complete the system prompt and rerun the script.
- The supported operating systems are Ubuntu and macOS. The setup has only been tested on current releases of those platforms.

## Run

1. Run `./setup.sh`.
2. When prompted, choose whether to manage dotfiles. If enabled, enter a Homeshick repository URL and make sure the machine can authenticate to it.
3. On macOS, open a new iTerm2 window and run `./post-setup.sh` to configure Powerlevel10k when prompted. Setup installs the required Meslo font before this step.

The script installs Ansible when it is missing (apt on Ubuntu, Homebrew on macOS), installs the required `community.general` Ansible collection, and installs Homebrew on macOS if needed. It asks for the sudo password for package setup and to set zsh as the default shell.

## Dotfiles and Homeshick

Homeshick, also called HSH, manages a repository of personal configuration files (“dotfiles”). This project uses it to install and link files such as `.zshrc` and the shell configuration that loads Antigen and Powerlevel10k. The Homeshick repository is separate from this project because dotfiles are normally personal and may contain machine-specific settings.

Dotfile management is optional. If you answer no, the setup skips cloning and linking a Homeshick repository, but still installs the other configured packages and tools. If you answer yes, enter a reachable Homeshick repository URL. When the default Homeshick castle or its link marker already exists, setup reuses it without asking for the URL again. The repository may use HTTPS or SSH; SSH repositories require the appropriate key and access permissions.

## What the setup changes

Running the setup can:

- install system packages, Homebrew/Linuxbrew packages, snaps, and macOS applications;
- change the current user’s default shell to zsh;
- add mise activation blocks to `.bashrc` and `.zshrc`;
- create or update shell configuration and, when enabled, link files from a Homeshick repository;
- add an iTerm2 dynamic profile on macOS.

Review the defaults before running the setup if you do not want the full package or application list. The script is intended for a personal workstation and does not provide an automatic uninstall or rollback.

The shared Homebrew packages and mise setup run on both platforms. mise installs Java 17 and is activated in zsh and bash. Dotfile management is opt-in; when enabled, the Homeshick setup configures Antigen to load Powerlevel10k and removes the old Powerlevel9k config and bundle, preserving the existing prompt settings. On macOS, setup installs the Meslo font used by Powerlevel10k; run `post-setup.sh` from a new iTerm2 window afterward to start the interactive `p10k configure` wizard. The setup also adds an iTerm2 dropdown profile toggled by F12, and creates `~/.linuxbrew` as a compatibility symlink to Homebrew for existing dotfiles that use `LINUXBREW_PATH`. The setup installs zsh and sets it as the current user's default shell. Snaps, Ubuntu packages, Plasma packages and JetBrains Toolbox desktop integration are Ubuntu-only; JetBrains Toolbox is installed on macOS through Homebrew Cask.

## What is installed

The project has a small bootstrap chain:

1. `setup.sh` installs Ansible if it is missing.
2. Ansible installs the `community.general` collection, which provides the Homebrew and Homebrew Cask modules used by the playbook.
3. macOS uses Homebrew; Ubuntu uses Linuxbrew. These package managers must exist before their Ansible modules can install formulae.
4. Ubuntu also uses `apt` and `snap` for system packages and desktop applications.

The setup installs or configures the following by default.

### Both Ubuntu and macOS

Shared Homebrew/Linuxbrew formulae:

- `gcc`, `antigen`, `diff-so-fancy`, `fzf`, `gh`, `mise`, and `scrcpy`;
- Maestro from the separately tapped and explicitly trusted `mobile-dev-inc/tap` repository;
- Java 17 through mise;
- Claude Code CLI through Anthropic's native installer (`claude`), on Ubuntu and macOS;
- Codex CLI through npm (`codex`), on Ubuntu and macOS;
- Herdr through its native installer (`herdr`), on Ubuntu and macOS;
- zsh, with the current user’s default shell changed to zsh.

### Ubuntu

- System and development packages from `roles/workstation_setup/tasks/sys_packages.yml`, including Git, Python 3, CMake, OpenSSL, SQLite, ADB, zsh, and build dependencies.
- Snap applications: Visual Studio Code, GitKraken, Telegram Desktop, Slack, and Flutter.
- Additional tools: bat, pidcat, adb-sync, and Hub.
- JetBrains Toolbox and Plasma-related packages.

### macOS

- Homebrew formulae including Android platform tools, bat, CMake, curl, Git, GnuPG, OpenSSL, pinentry, Python, SQLite, unzip, zsh, and Hub.
- The Meslo font for Powerlevel10k, if it is not already installed.
- The casks listed in `roles/workstation_setup/defaults/main.yml`: Proton Drive, Vivaldi, ChatGPT, Home Assistant, LM Studio Bionic, iTerm2, Visual Studio Code, JetBrains Toolbox, Raycast, Telegram, Claude, Shottr, and WhatsApp.

## How to change what is installed

The defaults are intentionally easy to edit:

- Add or remove shared formulae in `workstation_shared_packages` in `roles/workstation_setup/defaults/main.yml`.
- Add or remove macOS applications in `workstation_macos_casks` in the same file. Each item needs the Homebrew cask name and the expected `.app` path.
- Add or remove Ubuntu snaps in `roles/workstation_setup/tasks/snap.yml`.
- Add or remove Ubuntu system packages in `roles/workstation_setup/tasks/sys_packages.yml`.
- Change macOS-only formulae in the `Install macOS packages` task in `roles/workstation_setup/tasks/main.yml`.
- Change pinned versions and checksums for bat, Hub, and JetBrains Toolbox in `roles/workstation_setup/defaults/main.yml`.

After editing the files, rerun `./setup.sh`. Ansible is idempotent, so already-installed items remain unchanged and newly added items are installed.

## Repository layout

```text
setup.sh                         Bootstrap Ansible, dependencies, and the playbook
post-setup.sh                    Optional macOS Powerlevel10k wizard
playbook.yml                     Local-host playbook entry point
requirements.yml                 Ansible collection dependencies
roles/workstation_setup/
  defaults/main.yml              User-configurable packages, apps, versions, and options
  tasks/main.yml                 Platform routing and macOS-specific setup
  tasks/sys_packages.yml         Ubuntu apt packages
  tasks/snap.yml                 Ubuntu snap applications
  tasks/extra_packages.yml       Downloaded Ubuntu tools
  tasks/homeshick.yml            Optional dotfile/Homeshick setup
  tasks/*.yml                    Linuxbrew, mise, Toolbox, and package setup
  templates/                     Generated shell, desktop, and iTerm2 configuration
  handlers/                      Apt update/upgrade handler
.github/workflows/ci.yml         Bash, Ansible syntax, and ansible-lint checks
```

## Advanced usage

The normal entry point is `./setup.sh`, which bootstraps Ansible and its required collection automatically. If you run `ansible-playbook` directly instead, install the collection first:

```bash
ansible-galaxy collection install -r requirements.yml
```
