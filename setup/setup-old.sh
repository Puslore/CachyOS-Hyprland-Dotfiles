#!/bin/bash

# Скрипт для установки Hyprland на CachyOS

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Без цвета

# Функции для вывода информации
print_info() {
    echo -e "${BLUE}[ИНФО]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[УСПЕХ]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ВНИМАНИЕ]${NC} $1"
}

print_error() {
    echo -e "${RED}[ОШИБКА]${NC} $1"
}

# Функция для проверки наличия команды
command_exists() {
    command -v "$1" &> /dev/null
}

# Функция для проверки установленных пакетов
package_installed() {
    pacman -Q "$1" &> /dev/null
}

# Проверка на запуск от root
if [ "$EUID" -eq 0 ]; then
    print_error "Пожалуйста, не запускайте этот скрипт от имени root или с sudo"
    exit 1
fi

print_info "Начинаем установку Hyprland на CachyOS..."

# Обновление системы
print_info "Обновление пакетов системы..."
sudo pacman -Syu --noconfirm || {
    print_error "Не удалось обновить пакеты системы"
    exit 1
}
print_success "Система успешно обновлена"

# Установка yay, если не установлен
if ! command_exists yay; then
    print_info "Установка yay..."
    
    # Устанавливаем git и base-devel, если нужно
    sudo pacman -S --noconfirm --needed git base-devel || {
        print_error "Не удалось установить git и base-devel"
        exit 1
    }
    
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm || {
        print_error "Не удалось установить yay"
        exit 1
    }
    cd ~
    print_success "yay успешно установлен"
fi

# Установка flatpak, если не установлен
if ! command_exists flatpak; then
    print_info "Установка flatpak..."
    sudo pacman -S --noconfirm flatpak || {
        print_error "Не удалось установить flatpak"
        exit 1
    }
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || {
        print_warning "Не удалось добавить репозиторий flathub"
    }
    print_success "flatpak успешно установлен"
fi

# Установка Hyprland
print_info "Установка Hyprland и необходимых компонентов..."
sudo pacman -S --noconfirm --needed hyprland xdg-desktop-portal-hyprland || {
    print_error "Не удалось установить Hyprland"
    exit 1
}

# Установка дополнительных зависимостей для Hyprland
sudo pacman -S --noconfirm --needed polkit-kde-agent || {
    print_warning "Не удалось установить polkit-kde-agent"
}

print_success "Hyprland успешно установлен"

# Установка указанных пакетов через pacman
print_info "Установка пакетов через pacman..."
PACMAN_PACKAGES="waybar mako hyprpaper rofi kitty telegram-desktop steam"
sudo pacman -S --noconfirm --needed $PACMAN_PACKAGES || {
    print_warning "Некоторые пакеты не удалось установить через pacman, попробуем альтернативные методы"
}

# Проверка и установка hyprlock и hypridle
if ! package_installed hyprlock; then
    print_info "Установка hyprlock через yay..."
    yay -S --noconfirm hyprlock || {
        print_warning "Не удалось установить hyprlock"
    }
fi

if ! package_installed hypridle; then
    print_info "Установка hypridle через yay..."
    yay -S --noconfirm hypridle || {
        print_warning "Не удалось установить hypridle"
    }
fi

# Установка vscode (именно vscode, не code)
if ! package_installed visual-studio-code-bin; then
    print_info "Установка vscode через yay..."
    yay -S --noconfirm visual-studio-code-bin || {
        print_warning "Не удалось установить vscode через yay, пробуем flatpak..."
        flatpak install -y flathub com.visualstudio.code || {
            print_error "Не удалось установить vscode"
        }
    }
fi

# Установка Heroic Games Launcher
if ! package_installed heroic-games-launcher-bin; then
    print_info "Установка Heroic Games Launcher через yay..."
    yay -S --noconfirm heroic-games-launcher-bin || {
        print_warning "Не удалось установить Heroic Games Launcher через yay, пробуем flatpak..."
        flatpak install -y flathub com.heroicgameslauncher.hgl || {
            print_error "Не удалось установить Heroic Games Launcher"
        }
    }
fi

# Установка Spotify
if ! package_installed spotify; then
    print_info "Установка Spotify через yay..."
    yay -S --noconfirm spotify || {
        print_warning "Не удалось установить Spotify через yay, пробуем flatpak..."
        flatpak install -y flathub com.spotify.Client || {
            print_error "Не удалось установить Spotify"
        }
    }
fi

# Настройка автозапуска Hyprland
print_info "Настройка автозапуска Hyprland..."

# Создание файла сессии для display manager, если необходимо
if [ -d "/usr/share/wayland-sessions" ]; then
    print_info "Создание файла сессии для display manager..."
    cat > /tmp/hyprland.desktop << 'EOL'
[Desktop Entry]
Name=Hyprland
Comment=Тайлинговый Wayland композитор
Exec=Hyprland
Type=Application
EOL
    sudo mv /tmp/hyprland.desktop /usr/share/wayland-sessions/hyprland.desktop
fi

print_success "Установка завершена! Вы можете запустить Hyprland, выйдя из системы и выбрав Hyprland в своем display manager, или выполнив команду 'Hyprland' в TTY."
print_info "Если у вас возникнут проблемы, посетите вики Hyprland: https://wiki.hyprland.org/"