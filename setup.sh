#!/usr/bin/env bash
# ===============================================
#  Arch Linux Post-Install Script for Hyprland Rice
#  Author: mathieuarthur
#  Description: Installs all dependencies, shell tools,
#  and applies chezmoi-managed dotfiles.
# ===============================================

set -e  # Stop if any command fails

# ------------------------------
# 🧠 Helper Functions
# ------------------------------

function install_if_missing() {
    if ! command -v "$1" &>/dev/null; then
        echo "Installing $1..."
        sudo pacman -S --needed --noconfirm "$1"
    else
        echo "$1 is already installed."
    fi
}

# ------------------------------
# 🌍 Locale & Keyboard
# ------------------------------

echo "=== Setting French keyboard layout ==="
localectl set-keymap fr           # Console keymap
localectl set-x11-keymap fr       # X11 / graphical keymap

# ------------------------------
# 📦 System Essentials
# ------------------------------

echo "=== Installing essential packages ==="
sudo pacman -Syu --noconfirm

for pkg in git curl base-devel zsh neovim vim alacritty btop cava rofi fastfetch; do
    install_if_missing "$pkg"
done

# ------------------------------
# 🧰 Install paru (AUR helper)
# ------------------------------

if ! command -v paru &>/dev/null; then
    echo "Installing paru (AUR helper)..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    rm -rf /tmp/paru
else
    echo "paru is already installed."
fi

# ------------------------------
# 🖥️ Optional: Hyprland Installation
# ------------------------------

read -rp "Do you want to install Hyprland and its tools (hyprland, hyprlock, hypridle)? [Y/n]: " hypr_choice
hypr_choice=${hypr_choice:-Y}

if [[ "$hypr_choice" =~ ^[Yy]$ ]]; then
    echo "Installing Hyprland and related packages..."
    sudo pacman -S --needed --noconfirm hyprland hyprlock hypridle
else
    echo "Skipping Hyprland installation."
fi

# ------------------------------
# 🎨 Fonts
# ------------------------------

echo "=== Installing fonts ==="
paru -S --needed --noconfirm ttf-meslo-nerd ttf-nerd-fonts-symbols

# ------------------------------
# 💀 Oh My Zsh + Powerlevel10k
# ------------------------------

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh already installed."
fi

# Install Powerlevel10k if missing
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
else
    echo "Powerlevel10k already installed."
fi

# ------------------------------
# 🔌 Zsh Plugins (auto-install from .zshrc)
# ------------------------------

if [ -f "$HOME/.zshrc" ]; then
    echo "Checking for plugins in .zshrc..."
    plugins=$(grep -Eo 'plugins=\([^)]*\)' "$HOME/.zshrc" | sed 's/plugins=(//; s/)//; s/ /\n/g')
    for plugin in $plugins; do
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]; then
            echo "Installing plugin: $plugin"
            git clone "https://github.com/ohmyzsh/$plugin.git" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" || echo "Could not install $plugin"
        else
            echo "Plugin $plugin already exists."
        fi
    done
else
    echo "No .zshrc found, skipping plugin install."
fi

# ------------------------------
# 🏠 Chezmoi Dotfiles Setup
# ------------------------------

if ! command -v chezmoi &>/dev/null; then
    echo "Installing chezmoi..."
    install_if_missing chezmoi
fi

echo "=== Applying chezmoi dotfiles ==="
chezmoi init --apply mathieuarthur

# ------------------------------
# 🔁 Reboot Prompt
# ------------------------------

read -rp "Setup complete! Would you like to reboot now? [Y/n]: " reboot_choice
reboot_choice=${reboot_choice:-Y}

if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    sudo reboot
else
    echo "You can reboot manually later with 'sudo reboot'."
fi

