#!/bin/bash

# --- GENERAL CONFIG ---
set -euo pipefail
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

function info()  { echo -e "\e[1;34m[INFO]\e[0m $*"; }
function warn()  { echo -e "\e[1;33m[WARN]\e[0m $*"; }
function error() { echo -e "\e[1;31m[ERROR]\e[0m $*"; }

# --- INSTALL SOME DEFAULT PACKAGES ---
sudo apt update
sudo apt install -y git make npm curl zsh wget ca-certificates gnupg

# --- REMOVE CLASHING RMT PACKAGE ---
# Mint comes with a mega old RMT (Remove Magnetic Tape Server) package.
# This clashes with out own RMT tool. As it will never be used, we can delete it.
# It is not linked to any package manager, so we just delete it by removing the binary.
sudo rm -f /usr/sbin/rmt

# --- CONFIG ZSH & OMZ ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    warn "Oh My Zsh is already installed."
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    info "Changing your default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
    info "Shell changed. Restart the terminal session or relog after the rest of the script is completed."
else
    warn "Zsh is already your default shell."
fi
 
# --- UPDATE SWAP ---
SWAP_SIZE="32G"
SWAP_LVM_PATH="/dev/mapper/vgmint-swap_1"
ROOT_LVM_PATH="/dev/mapper/vgmint-root"
REAL_SWAP_DEV=$(readlink -f "$SWAP_LVM_PATH" || echo "")
if [[ -n "$REAL_SWAP_DEV" ]] && swapon --show --noheadings | grep -q "$REAL_SWAP_DEV"; then
    info "Disabling current LVM swap ($SWAP_LVM_PATH)..."
    sudo swapoff -a
    sudo lvremove -y "$SWAP_LVM_PATH"
else
    warn "LVM swap $SWAP_LVM_PATH (resolved as $REAL_SWAP_DEV) not found in active swap. Skipping."
fi

info "Commenting out old swap entries from /etc/fstab..."
sudo sed -i '/^\/swapfile/! { /^#/! { /swap/ s/^/# / } }' /etc/fstab

VG_NAME=$(sudo lvs --noheadings -o vg_name "$ROOT_LVM_PATH" | tr -d '[:space:]')
FREE_EXTENTS=$(sudo vgs --noheadings -o vg_free_count "$VG_NAME" | tr -d '[:space:]')
if [ "$FREE_EXTENTS" -gt 0 ]; then
    info "Free space detected ($FREE_EXTENTS extents). Extending $ROOT_LVM_PATH..."
    if sudo lvextend -l +100%FREE "$ROOT_LVM_PATH"; then
        sudo resize2fs "$ROOT_LVM_PATH"
        info "Root filesystem resized successfully."
    else
        error "Failed to extend $ROOT_LVM_PATH."
        exit 1
    fi
else
    warn "No free space left in Volume Group '$VG_NAME'. Root is likely already extended."
fi

if [ -f /swapfile ] && swapon --show | grep -q "/swapfile"; then
    warn "/swapfile is already active. Skipping creation."
else
    info "Creating new $SWAP_SIZE swapfile..."
    
    # If the file exists but isn't active, we'll remove it to be sure
    if [ -f /swapfile ]; then sudo swapoff /swapfile 2>/dev/null || true; fi
    
    sudo fallocate -l "$SWAP_SIZE" /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
fi

if ! grep -q "/swapfile" /etc/fstab; then
    info "Adding /swapfile to /etc/fstab..."
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
else
    warn "/swapfile already exists in /etc/fstab."
fi

# --- INSTALL JETBRAINS TOOLBOX ---
TOOLBOX_OPT_DIR="/opt/jetbrains-toolbox"
TOOLBOX_BINARY="$TOOLBOX_OPT_DIR/bin/jetbrains-toolbox"
TOOLBOX_URL="https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"   

if [[ -f "$TOOLBOX_BINARY" ]]; then
    info "IntelliJ Toolbox is already installed at $TOOLBOX_OPT_DIR. Skipping."
else 
    info "IntelliJ Toolbox not found. Installing to /opt..."

    sudo mkdir -p "$TOOLBOX_OPT_DIR"
    curl -sL "$TOOLBOX_URL" | sudo tar -xz -C "$TOOLBOX_OPT_DIR" --strip-components=1

    if [[ -x "$TOOLBOX_BINARY" ]]; then
        info "Initializing IntelliJ Toolbox..."
        "$TOOLBOX_BINARY" >/dev/null 2>&1 &
        disown
        
        info "IntelliJ Toolbox installed. It might open in the background to finalize setup."
    else
        error "Failed to find the IntelliJ Toolbox binary at $TOOLBOX_BINARY after extraction."
        exit 1
    fi
fi

# --- INSTALL DOCKER ENGINE & DOCKER COMPOSE ---
info "Installing Docker and Docker Compose..."

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

info "Docker and Docker Compose installed. Setting up permissions..."
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi

if ! groups "$USER" | grep -q "\bdocker\b"; then
    info "Adding $USER to the docker group..."
    sudo usermod -aG docker "$USER"
    warn "You will need to log out and back in for group changes to take effect."
fi

if docker compose version > /dev/null 2>&1; then
    info "Docker and Docker Compose installed successfully."
else
    error "Docker installation check failed."
    exit 1
fi


# -- FIN --
info "Setup done - please restart the device and validate shell as well as swap persistance"
