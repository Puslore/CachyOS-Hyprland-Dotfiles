#!/bin/bash

# Script to set up Hyprland environment on CachyOS
# Exit on error
set -e

# Function to print info messages
info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

# Function to print error messages
error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1"
    exit 1
}

# Function to check if a package is available in the official repos
is_in_official_repos() {
    pacman -Si "$1" &> /dev/null
}

# Function to install packages with pacman
install_with_pacman() {
    info "Installing packages with pacman: $@"
    sudo pacman -S --noconfirm --needed "$@" || error "Failed to install packages with pacman: $@"
}

# Function to install packages with yay
install_with_yay() {a
    info "Installing packages with yay: $@"
    yay -S --noconfirm --needed "$@" || error "Failed to install packages with yay: $@"
}

# Function to install packages with flatpak
install_with_flatpak() {
    info "Installing packages with flatpak: $@"
    flatpak install -y flathub "$@" || error "Failed to install packages with flatpak: $@"
}

# 1. Update system
info "Updating system..."
sudo pacman -Syu --noconfirm || error "Failed to update system"

# 2. Install yay if not already installed
if ! command -v yay &> /dev/null; then
    info "Installing yay..."
    # Install dependencies
    install_with_pacman base-devel git
    # Clone and build yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd - || exit
    rm -rf /tmp/yay
else
    info "yay is already installed"
fi

# 3. Install flatpak
info "Installing flatpak..."
install_with_pacman flatpak

# 4. Install Hyprland
info "Installing Hyprland..."
install_with_pacman hyprland

# 5. Install necessary packages for the environment
info "Installing necessary environment packages..."
install_with_pacman \
    wayland \
    xorg-xwayland \
    pipewire \
    pipewire-pulse \
    wireplumber \
    polkit-kde-agent \
    qt5-wayland \
    qt6-wayland \
    xdg-desktop-portal-hyprland

# 6. Install SDDM and enable it
info "Installing and enabling SDDM..."
install_with_pacman sddm
sudo systemctl enable sddm.service

# 7. Install CachyOS SDDM themes
info "Installing CachyOS SDDM themes..."
if is_in_official_repos cachyos-themes-sddm; then
    install_with_pacman cachyos-themes-sddm
else
    install_with_yay cachyos-themes-sddm
fi

# 8. Install packages mentioned in the Hyprland config
info "Installing packages mentioned in the config..."
config_packages=(
    kitty 
    dolphin 
    waybar 
    mako 
    hyprpaper 
    hypridle 
    hyprlock 
    rofi
)

for pkg in "${config_packages[@]}"; do
    if is_in_official_repos "$pkg"; then
        install_with_pacman "$pkg"
    else
        install_with_yay "$pkg"
    fi
done

# 9. Setup font
info "Setting up MS Comic Sans font as a system font..."
# Create font directory if it doesn't exist
sudo mkdir -p /usr/share/fonts/TTF/
# Copy font to system fonts directory
if [ -f ~/.config/fonts/MS\ Comic\ Sans.ttf ]; then
    sudo cp ~/.config/fonts/MS\ Comic\ Sans.ttf /usr/share/fonts/TTF/
    # Update font cache
    sudo fc-cache -f
    info "Font installed successfully"
else
    error "Font file not found at ~/.config/fonts/MS Comic Sans.ttf"
fi

# 10. Install additional requested packages
info "Installing additional requested packages..."
additional_packages=(telegram-desktop steam)

for pkg in "${additional_packages[@]}"; do
    if is_in_official_repos "$pkg"; then
        install_with_pacman "$pkg"
    else
        install_with_yay "$pkg"
    fi
done

# Visual Studio Code (vscode, not code)
info "Installing Visual Studio Code..."
if is_in_official_repos visual-studio-code; then
    install_with_pacman visual-studio-code
else
    install_with_yay visual-studio-code-bin
fi

# Heroic Games Launcher
info "Installing Heroic Games Launcher..."
if is_in_official_repos heroic-games-launcher; then
    install_with_pacman heroic-games-launcher
elif is_in_official_repos cachyos-gaming-meta; then
    # CachyOS gaming meta package includes heroic games launcher
    install_with_pacman cachyos-gaming-meta
else
    install_with_yay heroic-games-launcher-bin
fi

# Spotify
info "Installing Spotify..."
if is_in_official_repos spotify; then
    install_with_pacman spotify
else
    install_with_flatpak com.spotify.Client
fi

# Obsidian
info "Installing Obsidian..."
if is_in_official_repos obsidian; then
    install_with_pacman obsidian
else
    install_with_yay obsidian-bin
fi

info "Setup completed successfully!"
info "You may need to reboot your system for all changes to take effect."
