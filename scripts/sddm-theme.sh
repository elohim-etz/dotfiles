#!/usr/bin/env bash
set -euo pipefail

info() {
    echo "ℹ️ $1"
}

warn() {
    echo "⚠️ $1" >&2
}

error() {
    echo "❌ $1" >&2
    exit 1
}

# Check if SDDM is installed
if ! command -v sddm &>/dev/null; then
    info "SDDM is not installed. Installing now..."
    if ! sudo pacman -S --noconfirm sddm; then
        error "Failed to install SDDM"
    fi
fi

# Configure SDDM
info "Configuring SDDM as the display manager..."

# Enable SDDM service
if ! sudo systemctl enable sddm --now; then
    error "Failed to enable SDDM service"
fi

# Create SDDM config directory
sudo mkdir -p /etc/sddm.conf.d

# Check if theme config already exists with correct settings
THEME_CONFIG="/etc/sddm.conf.d/theme.conf"
if [ -f "$THEME_CONFIG" ]; then
    if grep -q "Current=sugar-candy" "$THEME_CONFIG"; then
        info "Sugar Candy theme already configured. Skipping configuration."
    else
        info "Updating SDDM theme configuration..."
        sudo tee "$THEME_CONFIG" >/dev/null <<EOF
[Theme]
Current=Sugar-Candy
EOF
    fi
else
    info "Setting Sugar Candy theme..."
    sudo tee "$THEME_CONFIG" >/dev/null <<EOF
[Theme]
Current=Sugar-Candy
EOF
fi

# Check if Sugar Candy theme is installed
if pacman -Qi sddm-theme-sugar-candy &>/dev/null; then
    info "Sugar Candy theme already installed."
else
    info "Installing Sugar Candy theme..."

    # Check if paru is available
    if ! command -v paru &>/dev/null; then
        warn "paru not found. Cannot install AUR package sddm-theme-sugar-candy."
        warn "You can install it manually later with: paru -S sddm-theme-sugar-candy"
    else
        if paru -S --noconfirm sddm-theme-sugar-candy; then
            info "Sugar Candy theme installed successfully."
        else
            warn "Could not install Sugar Candy theme. SDDM will use the default theme."
        fi
    fi
fi

# Verify theme directory exists
SUGAR_CANDY_DIR="/usr/share/sddm/themes/Sugar-Candy"
if [ -d "$SUGAR_CANDY_DIR" ]; then
    info "Sugar Candy theme directory found at $SUGAR_CANDY_DIR"
else
    warn "Sugar Candy theme directory not found. Theme may not work properly."
fi

if [ -d "$SUGAR_CANDY_DIR" ]; then
    THEME_CONF="$SUGAR_CANDY_DIR/theme.conf"
    SOURCE_BG="$HOME/dotfiles/assets/hk4.png"
    THEME_BG_DIR="$SUGAR_CANDY_DIR/Backgrounds"
    DEST_BG="$THEME_BG_DIR/hk4.png"

    if [ -f "$SOURCE_BG" ]; then
        # Ensure Backgrounds directory exists
        sudo mkdir -p "$THEME_BG_DIR"

        # Copy the image
        sudo cp "$SOURCE_BG" "$DEST_BG"
        sudo chmod 644 "$DEST_BG"

        # Only proceed if theme.conf exists
        if [ -f "$THEME_CONF" ]; then
            # Check if 'Background=' already exists under [General]
            if sudo grep -q "^\s*Background\s*=" "$THEME_CONF"; then
                # Replace existing Background= line (handles spaces, tabs, quotes)
                sudo sed -i "s|^\s*Background\s*=.*|Background=Backgrounds/hk4.png|" "$THEME_CONF"
                info "Updated existing Background in theme.conf."
            else
                # Append Background= under [General] section if it exists
                if sudo grep -q "^\[General\]" "$THEME_CONF"; then
                    # Insert after [General] line
                    sudo sed -i "/^\[General\]/a Background=Backgrounds/hk4.png" "$THEME_CONF"
                    info "Added Background to [General] section in theme.conf."
                else
                    # No [General] section? Create minimal one at the end
                    echo -e "\n[General]\nBackground=Backgrounds/hk4.png" | sudo tee -a "$THEME_CONF" >/dev/null
                    info "Added [General] section with Background to theme.conf."
                fi
            fi
        else
            warn "theme.conf not found in Sugar Candy directory. Skipping background update."
        fi
    else
        warn "Source background not found at $SOURCE_BG. Skipping custom background setup."
    fi
fi

info "SDDM configured successfully."
