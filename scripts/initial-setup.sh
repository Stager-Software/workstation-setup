#!/bin/bash

set -euo pipefail

function info()  { echo -e "\e[1;34m[INFO]\e[0m $*"; }
function warn()  { echo -e "\e[1;33m[WARN]\e[0m $*"; }
function error() { echo -e "\e[1;31m[ERROR]\e[0m $*"; }

# We install our openSUSE_Tumbleweed devices using a Ventoy bootable USB.
# For some reason, openSUSE_Tumbleweed handles the bootable USB as a repository during then
# installation process without cleaning it up afterwards. This leads to troubles updating
# afterwards, as the repository can no longer be found (as the USB is removed...)
# The below command cleans this up.
info "Removing intstallation repository"
sudo zypper rr hd:/?device=/dev/disk/by-id/dm-name-ventoy || {
    warn "Repository may already have been removed, or still exists under a different path..."
}

# Refresh to fail early
info "Refreshing repositories (after removing installation repo)..."
sudo zypper refresh

# Add the packman repository
info "Adding Packman repository..."
sudo zypper addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman || {
	warn "Packman repo may already exist. Continuing..."
}

# Refresh to fail early
info "Refreshing repositories (after adding Packman repo)..."
sudo zypper refresh

# Install multimedia codecs from Packman
info "Installing multimedia codecs from Packman..."
sudo zypper install --allow-vendor-change --from packman \
	ffmpeg \
	lame \
	gstreamer-plugins-good \
	gstreamer-plugins-bad \
	gstreamer-plugins-ugly \
	gstreamer-plugins-libav \
	libavcodec \
	vlc \
	vlc-codecs

# Install some other stuff
info "Installing other stuff..."
sudo zypper install \
	gearlever \
	google-noto-fonts \
	google-noto-sans-cjk-fonts \
	chromium

# Disable KWallet if we have a KDE session running
if [[ "${XDG_CURRENT_DESKTOP:-}" == *"KDE"* || -n "${KDE_FULL_SESSION:-}" ]]; then
	info "KDE session detected - disabling KWallet..."
	cat > ~/.config/kwalletrc <<- 'EOF'
	[Wallet]
	Enabled=false
	First Use=false
EOF
fi

# All done, yay!
info "Setup complete!"
