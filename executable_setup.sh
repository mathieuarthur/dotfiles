#!/usr/bin/env bash
# Exit immediately on errors and treat unset variables as errors
set -euo pipefail

echo "=== Updating system ==="
sudo pacman -Syu --noconfirm

echo "=== Installing essential packages from official repos ==="
sudo pacman -S --needed --noconfirm \
  git curl base-devel zsh neovim vim alacritty \
  hyprland hypridle hyprlock btop cava rofi fastfetch

echo "=== Installing AUR helper (paru) ==="
if ! command -v paru &>/dev/null; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/paru
fi

echo "=== Installing AUR packages ==="
paru -S --needed --noconfirm matugen-bin nerd-fonts-symbols

echo "=== Installing fonts ==="
mkdir -p ~/.local/share/fonts
POWERLEVEL10K_FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
curl -Lo ~/.local/share/fonts/MesloLGS\ NF\ Regular.ttf "$POWERLEVEL10K_FONT_URL"
fc-cache -fv

echo "=== Installing Oh-My-Zsh and Powerlevel10k ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

echo "=== Setting default shell to Zsh ==="
chsh -s "$(which zsh)"

echo "=== Setting French keyboard layout ==="
localectl set-keymap fr
localectl set-x11-keymap fr

echo "=== Installing chezmoi and applying dotfiles ==="
if ! command -v chezmoi &>/dev/null; then
    sh -c "$(curl -fsLS https://chezmoi.io/get)"
fi
chezmoi init git@github.com:mathieuarthur/dotfiles.git
chezmoi apply

echo "=== Installing Zsh plugins from .zshrc ==="
if [ -f "$HOME/.zshrc" ]; then
    plugins_line=$(grep "^plugins=" "$HOME/.zshrc" || true)
    plugins=$(echo "$plugins_line" | sed -E 's/plugins=\((.*)\)/\1/' | tr -d '"' | tr ' ' '\n')
    for plugin in $plugins; do
        plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
        if [ ! -d "$plugin_dir" ]; then
            echo "Installing Zsh plugin: $plugin"
            git clone --depth=1 "https://github.com/ohmyzsh/$plugin" "$plugin_dir" || \
            echo "Plugin $plugin not found in standard repo, skipping."
        fi
    done
fi

echo "=== Setup complete! ==="
# Prompt user to reboot with default yes
read -rp "Do you want to reboot now? [Y/n]: " reboot_choice
reboot_choice=${reboot_choice:-Y}  # default to yes
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    sudo reboot
else
    echo "Reboot skipped. You may need to reboot later for all changes to take effect."
fi

