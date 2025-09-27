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
install_with_yay() {
    info "Installing packages with yay: $@"
    yay -S --noconfirm --needed "$@" || error "Failed to install packages with yay: $@"
}

# Function to install packages with flatpak
install_with_flatpak() {
    info "Installing packages with flatpak: $@"
    flatpak install -y flathub "$@" || error "Failed to install packages with flatpak: $@"
}

# 1. Update system
#info "Updating system..."
#sudo pacman -Syu --noconfirm || error "Failed to update system"

# 2. Install yay if not already installed
if ! command -v yay &> /dev/null; then
    info "Installing yay..."
    # Install dependencies
    # install_with_pacman base-devel git
    # Clone and build yay
    # sudo rm /tmp/yay -rf
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

# 4. Remove cachy-browser and alacritty if installed
info "Removing CachyOS browser and Alacritty if installed..."
sudo pacman -Rns --noconfirm cachy-browser alacritty 2>/dev/null || true

# 5. Install Hyprland
info "Installing Hyprland..."
install_with_pacman hyprland

# 6. Install necessary packages for the environment
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

# 7. Install SDDM and enable it
info "Installing and enabling SDDM..."
install_with_pacman sddm
sudo systemctl enable sddm.service

# 8. Install CachyOS SDDM themes
info "Installing CachyOS SDDM themes..."
if is_in_official_repos cachyos-themes-sddm; then
    install_with_pacman cachyos-themes-sddm
else
    install_with_yay cachyos-themes-sddm
fi

# 9. Install packages mentioned in the Hyprland config
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

# 10. Setup font
info "Setting up Comic Sans MS font as a system font..."
# Create font directory if it doesn't exist
sudo mkdir -p /usr/share/fonts/TTF/
# Copy font to system fonts directory
if [ -f ~/.config/fonts/Comic\ Sans\ MS.ttf ]; then
    sudo cp ~/.config/fonts/Comic\ Sans\ MS.ttf /usr/share/fonts/TTF/
    # Update font cache
    sudo fc-cache -f
    info "Font installed successfully"
else
    error "Font file not found at ~/.config/fonts/Comic Sans MS.ttf"
fi

# 11. Install additional requested packages
info "Installing additional requested packages..."
additional_packages=(
    telegram-desktop
    blueman
    bluez
    brightnessctl
    wl-clipboard
    waterfox-bin
    zenbrowser-bin
    discord
    libreoffice-fresh
    grim
    slurp
    networkmanager
    network-manager-applet
    steam
    nekoray-bin
    hyprpolkitagent
)

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

# 12. Install development tools
info "Installing development tools..."
dev_packages=(
    qtcreator
    postgresql
    micro
    vim
    tmux
    meld
)

for pkg in "${dev_packages[@]}"; do
    if is_in_official_repos "$pkg"; then
        install_with_pacman "$pkg"
    else
        install_with_yay "$pkg"
    fi
done

# 13. Install virtualization tools
info "Installing virtualization tools..."
virtualization_packages=(
    docker
    virtualbox
    virtualbox-host-dkms
    virt-manager
    virt-viewer
)

for pkg in "${virtualization_packages[@]}"; do
    if is_in_official_repos "$pkg"; then
        install_with_pacman "$pkg"
    else
        install_with_yay "$pkg"
    fi
done

# 14. Install multimedia tools
info "Installing multimedia tools..."
media_packages=(
    inkscape
    vlc-plugins-all
    swappy
    swayimg
)

for pkg in "${media_packages[@]}"; do
    if is_in_official_repos "$pkg"; then
        install_with_pacman "$pkg"
    else
        install_with_yay "$pkg"
    fi
done

# 15. Install additional Hyprland tools
info "Installing additional Hyprland tools..."
hypr_additional=(
    hyprpicker
    hyprshot
    hyprsunset
    swww-git
)

for pkg in "${hypr_additional[@]}"; do
    if is_in_official_repos "$pkg"; then
        install_with_pacman "$pkg"
    else
        install_with_yay "$pkg"
    fi
done

# 16. Install system utilities
info "Installing system utilities..."
system_tools=(
    paru
    octopi
    pavucontrol
    rsync
)

for pkg in "${system_tools[@]}"; do
    if is_in_official_repos "$pkg"; then
        install_with_pacman "$pkg"
    else
        install_with_yay "$pkg"
    fi
done

# Enable Bluetooth service
info "Enabling Bluetooth service..."
sudo systemctl enable bluetooth.service

# Enable NetworkManager service
info "Enabling NetworkManager service..."
sudo systemctl enable NetworkManager.service

# Enable Docker service
info "Enabling Docker service..."
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

info "Setup completed successfully!"
info "You may need to reboot your system for all changes to take effect."
info "After reboot, you may need to log out and log back in to use Docker without sudo."
