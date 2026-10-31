#!/bin/sh
# Install the Island SDDM theme system-wide and select it. Run with sudo:
#   sudo ~/.local/share/sddm-island/install.sh [wallpaper]
# SDDM runs as its own user and can't read your home directory, so the theme
# and a downsized copy of the wallpaper go into /usr/share/sddm/themes/island.
set -eu
src=$(dirname "$(readlink -f "$0")")
wallpaper=${1:-$(eval echo ~"${SUDO_USER:-$USER}")/Pictures/Wallpapers/y4cxvsb8hbk71.png}
dest=/usr/share/sddm/themes/island

install -d "$dest"
install -m 644 "$src/Main.qml" "$src/metadata.desktop" "$src/theme.conf" "$dest/"
magick "$wallpaper" -resize '3440x1440^' -quality 90 "$dest/background.jpg"
chmod 644 "$dest/background.jpg"

install -d /etc/sddm.conf.d
printf '[Theme]\nCurrent=island\n' > /etc/sddm.conf.d/theme.conf
# /etc/sddm.conf wins over conf.d, so switch its theme line too if it has one
[ -f /etc/sddm.conf ] && sed -i 's/^\(\s*Current\s*=\s*\).*/\1island/' /etc/sddm.conf
echo "Installed to $dest and selected it"
