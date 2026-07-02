#!/usr/bin/env bash
# MangoWM + Noctalia dotfiles bootstrap
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/Collalaoo/mango-noctalia-dotfiles/main/bootstrap.sh)
set -euo pipefail

REPO="Collalaoo/mango-noctalia-dotfiles"
BRANCH="main"
BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "==> Installing packages…"
sudo pacman -S --needed --noconfirm foot brightnessctl playerctl wl-clipboard polkit-gnome kdeconnect
paru -S --needed --noconfirm mangowm-git noctalia

echo "==> Deploying config files…"
fetch_dir() {
  local dir="$1" target="$CONFIG_HOME/$dir"
  local tmp; tmp=$(mktemp -d)
  echo "   Fetching $dir/ …"
  for f in Animations.conf Autostart.conf Blur.conf Dwindle_layout.conf \
           Environments.conf General.conf Keybinds.conf Master-Stack.conf \
           Monitors.conf Rules.conf Scroller_layout.conf Shadows.conf \
           Tagrules.conf config.conf; do
    curl -fsSL "$BASE/$dir/$f" -o "$tmp/$f" 2>/dev/null || true
  done
  for f in config.toml; do
    curl -fsSL "$BASE/$dir/$f" -o "$tmp/$f" 2>/dev/null || true
  done
  rm -rf "$target" 2>/dev/null
  mkdir -p "$(dirname "$target")"
  cp -r "$tmp" "$target"
  rm -rf "$tmp"
  echo "   $target"
}

fetch_dir mango
fetch_dir noctalia

echo "==> Installing mango-layouts plugin…"
noctalia plugin add Collalaoo/mango-layouts 2>/dev/null || echo "   (do later: noctalia plugin add Collalaoo/mango-layouts)"

echo ""
echo "Done! Log out and select MangoWM."
