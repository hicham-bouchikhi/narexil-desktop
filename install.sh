#!/usr/bin/env bash
# narexil-desktop install script
# Installs all dependencies and symlinks configs into ~/.config
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# ── colours ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${BOLD}${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${BOLD}${YELLOW}[!]${NC} $*"; }
die()     { echo -e "${BOLD}${RED}[✗]${NC} $*" >&2; exit 1; }

# ── paru check ───────────────────────────────────────────────────────────────
ensure_paru() {
    if command -v paru &>/dev/null; then
        info "paru already installed"
        return
    fi
    warn "paru not found — installing from AUR"
    sudo pacman -S --needed base-devel git
    local tmp; tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
}

# ── packages ─────────────────────────────────────────────────────────────────
install_packages() {
    info "Installing pacman packages…"
    sudo pacman -S --needed --noconfirm \
        hyprland \
        hypridle \
        hyprlock \
        mako \
        wl-clipboard \
        ddcutil \
        playerctl \
        jq \
        curl \
        lm_sensors \
        pipewire \
        wireplumber \
        noto-fonts \
        ttf-rubik \
        kitty \
        dolphin \
        polkit-kde-agent \
        kwalletmanager \
        kwallet-pam \
        xdg-desktop-portal \
        xdg-desktop-portal-hyprland \
        xdg-desktop-portal-kde \
        easyeffects \
        bluez-utils \
        networkmanager \
        grimblast \
        wf-recorder \
        zbar \
        libnotify

    info "Installing AUR packages via paru…"
    paru -S --needed --noconfirm \
        quickshell \
        uwsm \
        awww-git \
        cliphist \
        ttf-material-symbols-variable-git

    info "Optional: NordVPN + Ollama (French text correction)"
    read -rp "  Install nordvpn-bin? [y/N] " yn
    [[ "${yn,,}" == "y" ]] && paru -S --needed --noconfirm nordvpn-bin

    read -rp "  Install ollama (for French text correction)? [y/N] " yn
    if [[ "${yn,,}" == "y" ]]; then
        paru -S --needed --noconfirm ollama
        info "Pulling mistral-nemo model (this may take a while)…"
        ollama pull mistral-nemo
    fi
}

# ── symlinks ─────────────────────────────────────────────────────────────────
# Usage: make_link <source_inside_repo> <target_in_config>
make_link() {
    local src="$REPO_DIR/$1"
    local dst="$2"
    local dst_dir; dst_dir="$(dirname "$dst")"

    if [[ ! -e "$src" ]]; then
        warn "Source not found, skipping: $src"
        return
    fi

    mkdir -p "$dst_dir"

    if [[ -L "$dst" ]]; then
        local existing; existing=$(readlink "$dst")
        if [[ "$existing" == "$src" ]]; then
            info "Already linked: $dst → $src"
            return
        fi
        warn "Replacing existing symlink: $dst → $existing"
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        local backup="${dst}.bak-$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing $dst → $backup"
        mv "$dst" "$backup"
    fi

    ln -sf "$src" "$dst"
    info "Linked: $dst → $src"
}

setup_symlinks() {
    info "Setting up ~/.config symlinks…"

    # QuickShell bar / launcher / dashboard / clipboard
    make_link "quickshell"     "$CONFIG_DIR/quickshell"

    # Mako notifications
    make_link "mako"           "$CONFIG_DIR/mako"

    # Hyprland window manager (entire config directory)
    make_link "hypr"           "$CONFIG_DIR/hypr"

    # UWSM session environment
    make_link "uwsm"           "$CONFIG_DIR/uwsm"
}

# ── scripts ──────────────────────────────────────────────────────────────────
make_scripts_executable() {
    info "Making hypr scripts executable…"
    chmod +x "$REPO_DIR/hypr/scripts/"*
}

# ── wallpaper dirs ────────────────────────────────────────────────────────────
create_wallpaper_dir() {
    if [[ ! -d "$HOME/Pictures/Wallpapers" ]]; then
        mkdir -p "$HOME/Pictures/Wallpapers"
        warn "Created ~/Pictures/Wallpapers — add berserk.png (DP-1) and summer.jpeg (HDMI-A-2)"
    else
        info "~/Pictures/Wallpapers already exists"
    fi
}

# ── ddcutil i2c group ────────────────────────────────────────────────────────
setup_ddcutil() {
    info "Adding user to i2c group for ddcutil (brightness control)…"
    sudo groupadd -f i2c
    sudo usermod -aG i2c "$USER"
    # load i2c-dev module now and on boot
    if ! lsmod | grep -q i2c_dev; then
        sudo modprobe i2c-dev
    fi
    if [[ ! -f /etc/modules-load.d/i2c-dev.conf ]]; then
        echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf > /dev/null
    fi
    warn "i2c group membership takes effect on next login"
}

# ── main ─────────────────────────────────────────────────────────────────────
main() {
    echo -e "\n${BOLD}narexil-desktop installer${NC}"
    echo    "Repo: $REPO_DIR"
    echo    "Config: $CONFIG_DIR"
    echo

    ensure_paru
    install_packages
    setup_symlinks
    make_scripts_executable
    create_wallpaper_dir
    setup_ddcutil

    echo
    info "Done! Next steps:"
    echo "  1. Log out and back in (or reboot) so i2c group membership applies"
    echo "  2. Add your wallpapers to ~/Pictures/Wallpapers/"
    echo "     berserk.png  → DP-1 (main)"
    echo "     summer.jpeg  → HDMI-A-2 (secondary)"
    echo "  3. Run 'ddcutil detect' to verify brightness control bus numbers"
    echo "     and update quickshell/services/Brightness.qml if needed"
    echo "  4. Update hypr/monitors.conf with your actual monitor names"
    echo "     (run 'hyprctl monitors' once Hyprland starts)"
    echo "  5. Start Hyprland via uwsm:"
    echo "     uwsm start hyprland"
    echo
}

main "$@"
