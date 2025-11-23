#!/usr/bin/env bash
set -e

msg() { echo -e "[1;92m[+][0m $1"; }
err() { echo -e "[1;91m[!] $1[0m"; exit 1; }

if ! command -v paru &>/dev/null; then
    msg "paru not found. Installing..."
    sudo pacman -Sy --needed --noconfirm base-devel git || err "Failed to install base-devel"
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm || err "Failed to install paru"
    cd -
fi

# -------- Install Packages ---------
msg "Installing core packages..."
CORE_PKGS=$(grep -Ev '^#|^$' pkg_core.lst)
sudo pacman -S --needed --noconfirm $CORE_PKGS || err "Failed to install core packages"

msg "Installing AUR packages..."
AUR_PKGS=$(grep -Ev '^#|^$' pkg_aur.lst)
paru -S --needed --noconfirm $AUR_PKGS || err "Failed to install AUR packages"

# -------- Create Directories ---------
msg "Ensuring ~/Pictures exists for screenshots"
mkdir -p "$HOME/Pictures"

# -------- Stow Dotfiles ---------
msg "Stowing dotfiles..."

for dir in .config zsh wallpapers extras; do
    if [[ -d "$dir" ]]; then
        msg "→ Stowing $dir"
        stow -R "$dir"
    fi
done

# -------- Run Grub and sddm Theme Scripts ---------
msg "Running grub-theme.sh and sddm-theme.sh..."
bash scripts/grub-theme.sh
bash scripts/sddm-theme.sh

# -------- Change Default Shell to ZSH ---------
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    msg "Changing default shell to zsh..."
    chsh -s "$(command -v zsh)" || err "Failed to change shell"
fi

# -------- Enable System Services ---------
msg "Enabling services..."
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now systemd-resolved.service

# -------- Spicetify Setup ---------
# msg "Applying Spicetify configuration..."
# spicetify backup apply
# spicetify config extensions adblock.js
# spicetify config current_theme Default
# spicetify config inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1
# spicetify apply

# -------- Icon Theme Installation ---------
msg "Installing Tela icon theme..."
mkdir -p ~/.local/share/icons
cd ~/.local/share/icons
if [[ ! -d Tela-icon-theme ]]; then
    git clone https://github.com/vinceliuice/Tela-icon-theme.git
fi
cd Tela-icon-theme
./install.sh -c dracula -a


# -------- Apply GTK/Icon/Cursor/Theme Settings ---------
GTK_THEME='catppuccin-mocha-blue-standard+default'
ICON_THEME='Tela-circle-dracula'
CURSOR_THEME='Bibata-Modern-Ice'
FONT_NAME='Cantarell 10'
COLOR_SCHEME='prefer-dark'

GSET="gsettings set org.gnome.desktop.interface"

msg "Applying GNOME theme settings..."
$GSET gtk-theme "$GTK_THEME"
$GSET icon-theme "$ICON_THEME"
$GSET cursor-theme "$CURSOR_THEME"
$GSET font-name "$FONT_NAME"
$GSET color-scheme "$COLOR_SCHEME"

msg "All done!"
