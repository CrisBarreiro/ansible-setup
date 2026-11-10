#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
    echo "Powerlevel10k post-setup is only required on macOS."
    exit 0
fi

if [ "${TERM_PROGRAM:-}" != "iTerm.app" ]; then
    echo "Open a new iTerm2 window, then run ./post-setup.sh from that window."
    exit 1
fi

if [ -f "$HOME/.p10k.zsh" ]; then
    echo "Powerlevel10k is already configured."
    exit 0
fi

echo "Starting the Powerlevel10k configuration wizard."
echo "Meslo fonts were installed during setup; the wizard will configure the prompt."
zsh -ic 'p10k configure'
