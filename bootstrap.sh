#!/usr/bin/env bash
# MangoWM + Noctalia dotfiles bootstrap
# Detects your distro and installs everything.
set -euo pipefail

REPO="Collalaoo/mango-noctalia-dotfiles"
BRANCH="main"
BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# ── detect distro ────────────────────────────────────────────────────────────
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  elif command -v lsb_release &>/dev/null; then
    lsb_release -is | tr '[:upper:]' '[:lower:]'
  else
    echo "unknown"
  fi
}

distro=$(detect_distro)

# ── helpers ───────────────────────────────────────────────────────────────────
deploy_configs() {
  echo "==> Deploying config files…"
  fetch_dir() {
    local dir="$1" target="$CONFIG_HOME/$dir"
    local tmp; tmp=$(mktemp -d)
    echo "   Fetching $dir/ …"
    case "$dir" in
      mango)
        for f in Animations.conf Autostart.conf Blur.conf Dwindle_layout.conf \
                 Environments.conf General.conf Keybinds.conf Master-Stack.conf \
                 Monitors.conf Rules.conf Scroller_layout.conf Shadows.conf \
                 Tagrules.conf config.conf; do
          curl -fsSL "$BASE/$dir/$f" -o "$tmp/$f" 2>/dev/null || true
        done ;;
      noctalia)
        curl -fsSL "$BASE/$dir/config.toml" -o "$tmp/config.toml" 2>/dev/null || true ;;
    esac
    if [ -d "$target" ]; then
      local backup="${target}.bak.$(date +%s)"
      echo "   Backing up $target → $backup"
      mv "$target" "$backup"
    fi
    mkdir -p "$(dirname "$target")"
    cp -r "$tmp" "$target"
    rm -rf "$tmp"
    echo "   $target"
  }
  fetch_dir mango
  fetch_dir noctalia
}

install_plugins() {
  echo "==> Installing plugins…"
  if command -v noctalia &>/dev/null; then
    noctalia plugin add Collalaoo/mango-layouts 2>/dev/null || \
      echo "   (install later: noctalia plugin add Collalaoo/mango-layouts)"
    noctalia plugin add Collalaoo/mango-keybinds 2>/dev/null || \
      echo "   (install later: noctalia plugin add Collalaoo/mango-keybinds)"
  else
    echo "   noctalia not found — install plugins later:"
    echo "     noctalia plugin add Collalaoo/mango-layouts"
    echo "     noctalia plugin add Collalaoo/mango-keybinds"
  fi
}

# ── Arch Linux ────────────────────────────────────────────────────────────────
arch() {
  sudo pacman -S --needed --noconfirm \
    foot brightnessctl playerctl wl-clipboard polkit-gnome kdeconnect
  if command -v paru &>/dev/null; then
    paru -S --needed --noconfirm mangowm-git noctalia
  elif command -v yay &>/dev/null; then
    yay -S --needed --noconfirm mangowm-git noctalia
  else
    echo "Select AUR helper:"
    echo "  1) paru-bin  (pre-compiled, recommended)"
    echo "  2) paru      (builds from source)"
    read -rp "Choice [1/2]: " aur_choice
    case "${aur_choice:-1}" in
      2) url="https://aur.archlinux.org/paru.git" ;;
      *) url="https://aur.archlinux.org/paru-bin.git" ;;
    esac
    sudo pacman -S --needed --noconfirm base-devel git
    git clone "$url" /tmp/paru-setup
    (cd /tmp/paru-setup && makepkg -si --noconfirm)
    rm -rf /tmp/paru-setup
    paru -S --needed --noconfirm mangowm-git noctalia
  fi
}

# ── Fedora ────────────────────────────────────────────────────────────────────
fedora() {
  sudo dnf install -y foot brightnessctl playerctl wl-clipboard polkit-gnome kdeconnect
  if ! command -v mangowm &>/dev/null; then
    echo "   MangoWM not in repos. Building from source…"
    sudo dnf install -y cargo rust meson wayland-devel libinput-devel \
      pixman-devel libxkbcommon-devel wayland-protocols-devel
    git clone https://github.com/mangowm/mangowm.git /tmp/mangowm
    (cd /tmp/mangowm && cargo build --release && sudo install -m755 target/release/mangowm /usr/local/bin/)
  fi
  if ! command -v noctalia &>/dev/null; then
    echo "   Noctalia not in repos. Building from source…"
    sudo dnf install -y cargo rust pipewire-devel systemd-libs-devel \
      libxkbcommon-devel wayland-devel wayland-protocols-devel \
      dbus-devel openssl-devel
    git clone https://github.com/noctalia-dev/shell.git /tmp/noctalia
    (cd /tmp/noctalia && cargo build --release && sudo install -m755 target/release/noctalia /usr/local/bin/)
  fi
}

# ── openSUSE ──────────────────────────────────────────────────────────────────
opensuse() {
  sudo zypper install -y foot brightnessctl playerctl wl-clipboard polkit-gnome kdeconnect
  # MangoWM / Noctalia: build from source (not in OBS yet)
  if ! command -v mangowm &>/dev/null; then
    echo "   Building MangoWM from source…"
    sudo zypper install -y rust cargo meson wayland-devel libinput-devel \
      pixman-devel libxkbcommon-devel wayland-protocols-devel
    git clone https://github.com/mangowm/mangowm.git /tmp/mangowm
    (cd /tmp/mangowm && cargo build --release && sudo install -m755 target/release/mangowm /usr/local/bin/)
  fi
  if ! command -v noctalia &>/dev/null; then
    echo "   Building Noctalia from source…"
    sudo zypper install -y rust cargo pipewire-devel systemd-devel \
      libxkbcommon-devel wayland-devel wayland-protocols-devel \
      dbus-1-devel libopenssl-devel
    git clone https://github.com/noctalia-dev/shell.git /tmp/noctalia
    (cd /tmp/noctalia && cargo build --release && sudo install -m755 target/release/noctalia /usr/local/bin/)
  fi
}

# ── Ubuntu / Debian ───────────────────────────────────────────────────────────
ubuntu() {
  sudo apt update
  sudo apt install -y foot brightnessctl playerctl wl-clipboard \
    policykit-1-gnome kdeconnect

  # MangoWM: build from source
  if ! command -v mangowm &>/dev/null; then
    echo "   Building MangoWM from source…"
    sudo apt install -y cargo rustc meson libwayland-dev libinput-dev \
      libpixman-1-dev libxkbcommon-dev wayland-protocols-extra
    git clone https://github.com/mangowm/mangowm.git /tmp/mangowm
    (cd /tmp/mangowm && cargo build --release && sudo install -m755 target/release/mangowm /usr/local/bin/)
  fi

  # Noctalia: build from source
  if ! command -v noctalia &>/dev/null; then
    echo "   Building Noctalia from source…"
    sudo apt install -y cargo rustc libpipewire-0.3-dev libsystemd-dev \
      libxkbcommon-dev libwayland-dev wayland-protocols-extra \
      libdbus-1-dev libssl-dev
    git clone https://github.com/noctalia-dev/shell.git /tmp/noctalia
    (cd /tmp/noctalia && cargo build --release && sudo install -m755 target/release/noctalia /usr/local/bin/)
  fi
}

# ── Void Linux ────────────────────────────────────────────────────────────────
void() {
  sudo xbps-install -Syu foot brightnessctl playerctl wl-clipboard \
    polkit-gnome kdeconnect
  # Build from source if not in repos
  if ! command -v mangowm &>/dev/null; then
    echo "   Building MangoWM from source…"
    sudo xbps-install -S rust cargo wayland-devel libinput-devel \
      pixman-devel libxkbcommon-devel wayland-protocols
    git clone https://github.com/mangowm/mangowm.git /tmp/mangowm
    (cd /tmp/mangowm && cargo build --release && sudo install -m755 target/release/mangowm /usr/local/bin/)
  fi
  if ! command -v noctalia &>/dev/null; then
    echo "   Building Noctalia from source…"
    sudo xbps-install -S rust cargo pipewire-devel systemd-devel \
      libxkbcommon-devel wayland-devel wayland-protocols dbus-devel openssl-devel
    git clone https://github.com/noctalia-dev/shell.git /tmp/noctalia
    (cd /tmp/noctalia && cargo build --release && sudo install -m755 target/release/noctalia /usr/local/bin/)
  fi
}

# ── Gentoo ────────────────────────────────────────────────────────────────────
gentoo() {
  sudo emerge --noreplace --oneshot --quiet \
    gui-apps/foot sys-power/brightnessctl media-sound/playerctl \
    gui-apps/wl-clipboard gnome-extra/polkit-gnome kde-apps/kdeconnect
  if ! command -v mangowm &>/dev/null; then
    echo "   Building MangoWM from source…"
    sudo emerge --noreplace --oneshot --quiet \
      dev-lang/rust dev-util/cargo dev-util/meson \
      dev-libs/wayland dev-libs/libinput x11-libs/pixman \
      x11-libs/libxkbcommon dev-libs/wayland-protocols
    git clone https://github.com/mangowm/mangowm.git /tmp/mangowm
    (cd /tmp/mangowm && cargo build --release && sudo install -m755 target/release/mangowm /usr/local/bin/)
  fi
  if ! command -v noctalia &>/dev/null; then
    echo "   Building Noctalia from source…"
    echo "   NOTE: if packages are masked, add to /etc/portage/package.accept_keywords:"
    echo "     dev-libs/wayland ~amd64"
    echo "     media-libs/mesa ~amd64"
    sudo emerge --noreplace --oneshot --quiet \
      dev-lang/rust dev-util/cargo media-libs/pipewire sys-apps/systemd \
      x11-libs/libxkbcommon dev-libs/wayland dev-libs/wayland-protocols \
      sys-libs/dbus dev-libs/openssl
    git clone https://github.com/noctalia-dev/shell.git /tmp/noctalia
    (cd /tmp/noctalia && cargo build --release && sudo install -m755 target/release/noctalia /usr/local/bin/)
  fi
}

# ── NixOS ─────────────────────────────────────────────────────────────────────
nixos() {
  echo "==> NixOS detected"

  local nixos_dir="/etc/nixos"
  local dotfiles_dir="$nixos_dir/dotfiles"
  local flake="$nixos_dir/flake.nix"

  if [ ! -d "$nixos_dir" ] || [ ! -w "$nixos_dir" ]; then
    echo "   $nixos_dir not writable — printing instructions instead."
    nixos_instructions
    return
  fi

  # ── deploy configs into /etc/nixos/dotfiles/ ──────────────────────────────
  echo "   Deploying dotfiles to $dotfiles_dir …"
  sudo mkdir -p "$dotfiles_dir/mango" "$dotfiles_dir/noctalia"
  for f in Animations.conf Autostart.conf Blur.conf Dwindle_layout.conf \
           Environments.conf General.conf Keybinds.conf Master-Stack.conf \
           Monitors.conf Rules.conf Scroller_layout.conf Shadows.conf \
           Tagrules.conf config.conf; do
    sudo curl -fsSL "$BASE/mango/$f" -o "$dotfiles_dir/mango/$f" 2>/dev/null || true
  done
  sudo curl -fsSL "$BASE/noctalia/config.toml" -o "$dotfiles_dir/noctalia/config.toml"

  # ── generate flake if missing ──────────────────────────────────────────────
  local flake_generated=false
  if [ ! -f "$flake" ]; then
    echo "   No flake.nix found — generating one at $flake …"
    sudo tee "$flake" > /dev/null << 'FLAKE_EOF'
{
  description = "NixOS + MangoWM + Noctalia v5";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, noctalia, home-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        noctalia.nixosModules.default
        home-manager.nixosModules.default
      ];
    };
  };
}
FLAKE_EOF
    flake_generated=true
  fi

  # ── print what to add to configuration.nix ───────────────────────────────
  echo ""
  echo "============================================================="
  echo " Dotfiles deployed to $dotfiles_dir/"
  if $flake_generated; then
    echo ""
    echo " Flake generated at $flake"
    echo "   Review and rebuild:"
    echo "     sudo nixos-rebuild switch --flake $nixos_dir/#nixos"
  fi
  echo ""
  echo " Add this to your configuration.nix:"
  echo ""
  echo "  { inputs, ... }: {"
  echo "    imports = [ inputs.noctalia.nixosModules.default ];"
  echo ""
  echo "    programs.noctalia.enable = true;"
  echo "    programs.noctalia.recommendedServices.enable = true;"
  echo "    programs.noctalia.configPath = \"$dotfiles_dir/noctalia/config.toml\";"
  echo ""
  echo "    environment.systemPackages = with pkgs; ["
  echo "      mangowm foot brightnessctl playerctl wl-clipboard polkit-gnome"
  echo "    ];"
  echo "    environment.sessionVariables.NIXOS_OZONE_WL = \"1\";"
  echo "  }"
  echo ""
  echo " Then symlink mango configs:"
  echo "   mkdir -p ~/.config/mango"
  echo "   ln -sf $dotfiles_dir/mango/*.conf ~/.config/mango/"
  echo "   ln -sf $dotfiles_dir/mango/config.conf ~/.config/mango/"
  echo ""
  echo " When ready, rebuild:"
  echo "   sudo nixos-rebuild switch --flake $nixos_dir/#nixos"
  echo "============================================================="
  echo "==> Done."
}

# ── NixOS instructions (fallback, no write access) ────────────────────────────
nixos_instructions() {
  echo ""
  echo "============================================================="
  echo " NixOS setup instructions:"
  echo ""
  echo "  1. Add Noctalia flake to your flake.nix:"
  echo ""
  echo "     inputs = {"
  echo "       nixpkgs.url = \"github:nixos/nixpkgs/nixos-unstable\";"
  echo "       noctalia = {"
  echo "         url = \"github:noctalia-dev/noctalia/cachix\";"
  echo "         inputs.nixpkgs.follows = \"nixpkgs\";"
  echo "       };"
  echo "     };"
  echo ""
  echo "     outputs = { nixpkgs, noctalia, ... }: {"
  echo "       nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {"
  echo "         specialArgs = { inherit inputs; };"
  echo "         modules = [ ./configuration.nix noctalia.nixosModules.default ];"
  echo "       };"
  echo "     };"
  echo ""
  echo "  2. Enable Noctalia in configuration.nix:"
  echo ""
  echo "     { inputs, ... }: {"
  echo "       imports = [ inputs.noctalia.nixosModules.default ];"
  echo "       programs.noctalia.enable = true;"
  echo "       programs.noctalia.recommendedServices.enable = true;"
  echo "       environment.systemPackages = with pkgs; [ mangowm foot ];"
  echo "     }"
  echo ""
  echo "  3. Deploy configs:"
  echo "     sudo mkdir -p /etc/nixos/dotfiles"
  echo "     git clone https://github.com/$REPO /etc/nixos/dotfiles"
  echo "     ln -sf /etc/nixos/dotfiles/mango/*.conf ~/.config/mango/"
  echo ""
  echo "  4. Rebuild:"
  echo "     sudo nixos-rebuild switch --flake /etc/nixos/#nixos"
  echo "============================================================="
}

# ── run ───────────────────────────────────────────────────────────────────────
if [ "${1:-}" = "--config-only" ]; then
  deploy_configs
  install_plugins
  echo "Done!"
  exit 0
fi

echo "Detected distro: $distro"
case "$distro" in
  arch|endeavouros|artix|manjaro)   arch ;;
  fedora)                           fedora ;;
  opensuse|opensuse-tumbleweed)     opensuse ;;
  ubuntu|debian|pop|linuxmint|elementary|zorin) ubuntu ;;
  void)                             void ;;
  gentoo)                           gentoo ;;
  nixos)                            nixos ;;
  *)
    echo "Unsupported distro: $distro"
    echo "Please install MangoWM and Noctalia manually, then run:"
    echo "  curl -fsSL $BASE/bootstrap.sh | bash -s -- --config-only"
    exit 1
    ;;
esac

deploy_configs
install_plugins
echo "Done! Log out and select MangoWM."
