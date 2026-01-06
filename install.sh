#!/bin/bash

# Dotfiles Installation Script
# This script automatically installs all dependencies and configures the dotfiles

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
BACKUP_DIR="$HOME_DIR/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Dotfiles Installation Script        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    else
        DISTRO="unknown"
    fi
    echo "$DISTRO"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup existing configurations
backup_existing() {
    echo -e "${YELLOW}[1/10] Backing up existing configurations...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    [ -f "$HOME_DIR/.zshrc" ] && cp "$HOME_DIR/.zshrc" "$BACKUP_DIR/.zshrc.bak"
    [ -d "$HOME_DIR/.config/i3" ] && cp -r "$HOME_DIR/.config/i3" "$BACKUP_DIR/i3.bak" 2>/dev/null || true
    [ -d "$HOME_DIR/.config/polybar" ] && cp -r "$HOME_DIR/.config/polybar" "$BACKUP_DIR/polybar.bak" 2>/dev/null || true
    [ -d "$HOME_DIR/.config/picom" ] && cp -r "$HOME_DIR/.config/picom" "$BACKUP_DIR/picom.bak" 2>/dev/null || true
    [ -d "$HOME_DIR/.config/kitty" ] && cp -r "$HOME_DIR/.config/kitty" "$BACKUP_DIR/kitty.bak" 2>/dev/null || true
    
    echo -e "${GREEN}✓ Backup created at: $BACKUP_DIR${NC}\n"
}

# Function to install system dependencies
install_dependencies() {
    DISTRO=$(detect_distro)
    echo -e "${YELLOW}[2/10] Installing system dependencies...${NC}"
    echo -e "${BLUE}Detected distribution: $DISTRO${NC}\n"
    
    case $DISTRO in
        ubuntu|debian)
            echo -e "${YELLOW}Installing packages (Ubuntu/Debian)...${NC}"
            sudo apt update -qq
            sudo apt install -y \
                i3 \
                polybar \
                picom \
                zsh \
                dex \
                xss-lock \
                i3lock \
                network-manager-applet \
                dmenu \
                x11-xserver-utils \
                acpi \
                jq \
                python3-dbus \
                python3-pip \
                curl \
                git \
                flameshot \
                vim \
                feh \
                kitty \
                spotify-client \
                unzip \
                wget \
                fontconfig
            
            # Try to install clipmenu (may not be in all repositories)
            if sudo apt install -y clipmenu 2>/dev/null; then
                echo -e "${GREEN}✓ clipmenu installed${NC}"
            else
                echo -e "${YELLOW}⚠ clipmenu not available in repositories${NC}"
                echo -e "${YELLOW}  Install manually: sudo apt install clipmenu${NC}"
                echo -e "${YELLOW}  Or from source: https://github.com/cdown/clipmenu${NC}"
            fi
            ;;
        arch|manjaro)
            echo -e "${YELLOW}Installing packages (Arch Linux)...${NC}"
            sudo pacman -S --needed --noconfirm \
                i3-wm \
                polybar \
                picom \
                zsh \
                dex \
                xss-lock \
                i3lock \
                network-manager-applet \
                dmenu \
                xorg-xrandr \
                acpi \
                jq \
                python-dbus \
                python-pip \
                curl \
                git \
                flameshot \
                vim \
                feh \
                clipmenu \
                kitty \
                spotify-launcher \
                unzip \
                wget \
                fontconfig
            ;;
        fedora)
            echo -e "${YELLOW}Installing packages (Fedora)...${NC}"
            sudo dnf install -y \
                i3 \
                polybar \
                picom \
                zsh \
                dex \
                xss-lock \
                i3lock \
                NetworkManager-applet \
                dmenu \
                xorg-xrandr \
                acpi \
                jq \
                python3-dbus \
                python3-pip \
                curl \
                git \
                flameshot \
                vim \
                feh \
                kitty \
                unzip \
                wget \
                fontconfig
            
            # Try to install clipmenu (may not be in all repositories)
            if sudo dnf install -y clipmenu 2>/dev/null; then
                echo -e "${GREEN}✓ clipmenu installed${NC}"
            else
                echo -e "${YELLOW}⚠ clipmenu not available in repositories${NC}"
                echo -e "${YELLOW}  Install manually or from source: https://github.com/cdown/clipmenu${NC}"
            fi
            echo -e "${YELLOW}Note: Install Spotify manually from: https://www.spotify.com/download/linux/${NC}"
            ;;
        *)
            echo -e "${RED}Unsupported distribution: $DISTRO${NC}"
            echo -e "${YELLOW}Please install dependencies manually.${NC}"
            echo -e "${YELLOW}Required packages: i3, polybar, picom, zsh, dex, xss-lock, i3lock, nm-applet, dmenu, flameshot, vim, feh, clipmenu, kitty${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}✓ System dependencies installed!${NC}\n"
}

# Function to install Oh My Zsh
install_ohmyzsh() {
    echo -e "${YELLOW}[3/10] Installing Oh My Zsh...${NC}"
    if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}✓ Oh My Zsh installed!${NC}\n"
    else
        echo -e "${GREEN}✓ Oh My Zsh already installed.${NC}\n"
    fi
}

# Function to install Zsh plugins
install_zsh_plugins() {
    echo -e "${YELLOW}[4/10] Installing Zsh plugins...${NC}"
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone --quiet https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Zsh plugins installed!${NC}\n"
}

# Function to install Python dependencies
install_python_deps() {
    echo -e "${YELLOW}[5/10] Installing Python dependencies...${NC}"
    pip3 install --user --quiet colorthief 2>/dev/null || {
        echo -e "${YELLOW}Warning: Could not install colorthief via pip.${NC}"
        echo -e "${YELLOW}Try manually: pip3 install --user colorthief${NC}"
    }
    echo -e "${GREEN}✓ Python dependencies installed!${NC}\n"
}

# Function to create directories
create_directories() {
    echo -e "${YELLOW}[6/10] Creating configuration directories...${NC}"
    mkdir -p "$HOME_DIR/.config/i3/scripts"
    mkdir -p "$HOME_DIR/.config/polybar/modules"
    mkdir -p "$HOME_DIR/.config/picom"
    mkdir -p "$HOME_DIR/.config/kitty"
    mkdir -p "$HOME_DIR/.config/wallpaper"
    echo -e "${GREEN}✓ Directories created!${NC}\n"
}

# Function to create symlinks
create_symlinks() {
    echo -e "${YELLOW}[7/10] Creating symbolic links...${NC}"
    
    # i3 configuration files
    ln -sf "$DOTFILES_DIR/i3/config" "$HOME_DIR/.config/i3/config"
    ln -sf "$DOTFILES_DIR/i3/"*.conf "$HOME_DIR/.config/i3/" 2>/dev/null || true
    ln -sf "$DOTFILES_DIR/i3/scripts/"*.sh "$HOME_DIR/.config/i3/scripts/" 2>/dev/null || true
    
    # polybar
    ln -sf "$DOTFILES_DIR/polybar/config.ini" "$HOME_DIR/.config/polybar/config.ini"
    ln -sf "$DOTFILES_DIR/polybar/launch.sh" "$HOME_DIR/.config/polybar/launch.sh"
    ln -sf "$DOTFILES_DIR/polybar/modules/"*.sh "$HOME_DIR/.config/polybar/modules/" 2>/dev/null || true
    ln -sf "$DOTFILES_DIR/polybar/modules/"*.py "$HOME_DIR/.config/polybar/modules/" 2>/dev/null || true
    
    # picom
    ln -sf "$DOTFILES_DIR/picom/picom.conf" "$HOME_DIR/.config/picom/picom.conf"
    
    # kitty
    ln -sf "$DOTFILES_DIR/kitty/kitty.conf" "$HOME_DIR/.config/kitty/kitty.conf"
    
    # zsh
    ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME_DIR/.zshrc"
    
    # wallpaper
    if [ -f "$DOTFILES_DIR/wallpaper/wallpaper.jpg" ]; then
        ln -sf "$DOTFILES_DIR/wallpaper/wallpaper.jpg" "$HOME_DIR/.config/wallpaper/wallpaper.jpg"
    elif [ -f "$DOTFILES_DIR/wallpaper/wallpaper.png" ]; then
        ln -sf "$DOTFILES_DIR/wallpaper/wallpaper.png" "$HOME_DIR/.config/wallpaper/wallpaper.jpg"
    else
        # Try to find any image file in wallpaper directory
        WALLPAPER_FILE=$(find "$DOTFILES_DIR/wallpaper" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) 2>/dev/null | head -1)
        if [ -n "$WALLPAPER_FILE" ]; then
            ln -sf "$WALLPAPER_FILE" "$HOME_DIR/.config/wallpaper/wallpaper.jpg"
        fi
    fi
    
    echo -e "${GREEN}✓ Symbolic links created!${NC}\n"
}

# Function to fix hardcoded paths
fix_hardcoded_paths() {
    echo -e "${YELLOW}[8/10] Fixing hardcoded paths...${NC}"
    
    # Fix paths in polybar config if needed
    if [ -f "$HOME_DIR/.config/polybar/config.ini" ]; then
        sed -i "s|/home/[^/]*/.config|$HOME_DIR/.config|g" "$HOME_DIR/.config/polybar/config.ini" 2>/dev/null || true
    fi
    
    # Fix paths in Python scripts
    find "$HOME_DIR/.config/polybar/modules" -name "*.py" -type f -exec sed -i "s|/home/[^/]*/.config|$HOME_DIR/.config|g" {} \; 2>/dev/null || true
    
    echo -e "${GREEN}✓ Paths fixed!${NC}\n"
}

# Function to make scripts executable
make_executable() {
    echo -e "${YELLOW}[9/10] Setting executable permissions...${NC}"
    chmod +x "$HOME_DIR/.config/polybar/launch.sh" 2>/dev/null || true
    chmod +x "$HOME_DIR/.config/polybar/modules/"*.sh 2>/dev/null || true
    chmod +x "$HOME_DIR/.config/polybar/modules/"*.py 2>/dev/null || true
    chmod +x "$HOME_DIR/.config/i3/scripts/"*.sh 2>/dev/null || true
    echo -e "${GREEN}✓ Permissions set!${NC}\n"
}

# Function to install fonts
install_fonts() {
    echo -e "${YELLOW}[10/10] Installing JetBrainsMono Nerd Font...${NC}"
    DISTRO=$(detect_distro)
    FONT_DIR="$HOME_DIR/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    
    case $DISTRO in
        arch|manjaro)
            if command_exists yay; then
                yay -S --noconfirm nerd-fonts-jetbrains-mono 2>/dev/null && \
                echo -e "${GREEN}✓ Fonts installed via yay!${NC}" || \
                download_fonts_manual
            elif command_exists paru; then
                paru -S --noconfirm nerd-fonts-jetbrains-mono 2>/dev/null && \
                echo -e "${GREEN}✓ Fonts installed via paru!${NC}" || \
                download_fonts_manual
            else
                download_fonts_manual
            fi
            ;;
        ubuntu|debian)
            if sudo apt install -y fonts-jetbrains-mono 2>/dev/null; then
                echo -e "${GREEN}✓ Fonts installed via apt!${NC}"
                download_fonts_manual  # Still download Nerd Font version
            else
                download_fonts_manual
            fi
            ;;
        *)
            download_fonts_manual
            ;;
    esac
    
    # Update font cache
    fc-cache -fv "$FONT_DIR" 2>/dev/null || true
    echo -e "${GREEN}✓ Font cache updated!${NC}\n"
}

# Function to download fonts manually
download_fonts_manual() {
    FONT_DIR="$HOME_DIR/.local/share/fonts"
    TEMP_DIR=$(mktemp -d)
    
    echo -e "${YELLOW}Downloading JetBrainsMono Nerd Font...${NC}"
    if command_exists wget; then
        wget -q --show-progress -P "$TEMP_DIR" \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" 2>/dev/null || \
        wget -q -P "$TEMP_DIR" \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    elif command_exists curl; then
        curl -L -o "$TEMP_DIR/JetBrainsMono.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" 2>/dev/null || true
    else
        echo -e "${RED}wget or curl required to download fonts.${NC}"
        echo -e "${YELLOW}Download manually from: https://www.nerdfonts.com/font-downloads${NC}"
        return 1
    fi
    
    if [ -f "$TEMP_DIR/JetBrainsMono.zip" ]; then
        unzip -q -o "$TEMP_DIR/JetBrainsMono.zip" -d "$FONT_DIR" 2>/dev/null || {
            echo -e "${YELLOW}Installing unzip...${NC}"
            case $(detect_distro) in
                ubuntu|debian) sudo apt install -y unzip ;;
                arch|manjaro) sudo pacman -S --noconfirm unzip ;;
                fedora) sudo dnf install -y unzip ;;
            esac
            unzip -q -o "$TEMP_DIR/JetBrainsMono.zip" -d "$FONT_DIR"
        }
        rm -rf "$TEMP_DIR"
        echo -e "${GREEN}✓ Fonts downloaded and installed!${NC}"
    else
        echo -e "${RED}Error downloading fonts.${NC}"
        echo -e "${YELLOW}Download manually from: https://www.nerdfonts.com/font-downloads${NC}"
        rm -rf "$TEMP_DIR"
        return 1
    fi
}

# Main function
main() {
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}Please do not run this script as root!${NC}"
        exit 1
    fi
    
    # Backup existing configurations
    backup_existing
    
    # Install system dependencies
    install_dependencies
    
    # Install Oh My Zsh
    install_ohmyzsh
    
    # Install Zsh plugins
    install_zsh_plugins
    
    # Install Python dependencies
    install_python_deps
    
    # Create directories
    create_directories
    
    # Create symlinks
    create_symlinks
    
    # Fix hardcoded paths
    fix_hardcoded_paths
    
    # Make scripts executable
    make_executable
    
    # Install fonts
    install_fonts
    
    # Change shell to zsh if not already
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo -e "${YELLOW}Changing default shell to zsh...${NC}"
        chsh -s $(which zsh) 2>/dev/null || {
            echo -e "${YELLOW}Could not change shell automatically.${NC}"
            echo -e "${YELLOW}Run manually: chsh -s $(which zsh)${NC}"
        }
    fi
    
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Installation Complete!             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Logout and login again (or restart i3: Mod+Shift+R)"
    echo -e "  2. Configure your monitors in i3/config and workspaces.conf if needed"
    echo -e "  3. Place your wallpaper in: $DOTFILES_DIR/wallpaper/wallpaper.jpg"
    echo -e "\n${YELLOW}Useful shortcuts:${NC}"
    echo -e "  • Print: Full screenshot"
    echo -e "  • Mod+Print: Interactive screenshot (flameshot)"
    echo -e "  • Mod+V: Clipboard menu (clipmenu)"
    echo -e "  • Mod+Return: Terminal"
    echo -e "  • Mod+D: Application launcher (dmenu)"
    echo -e "\n${YELLOW}Backup saved at: $BACKUP_DIR${NC}\n"
}

# Execute main function
main
