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

install_plugin() {
  echo "==> Installing mango-layouts plugin…"
  command -v noctalia &>/dev/null && \
    noctalia plugin add Collalaoo/mango-layouts 2>/dev/null || \
    echo "   (install later: noctalia plugin add Collalaoo/mango-layouts)"
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
    foot brightnessctl playerctl wl-clipboard polkit-gnome kdeconnect
  if ! command -v mangowm &>/dev/null; then
    echo "   Building MangoWM from source…"
    sudo emerge --noreplace --oneshot --quiet \
      cargo rust wayland libinput pixman libxkbcommon wayland-protocols
    git clone https://github.com/mangowm/mangowm.git /tmp/mangowm
    (cd /tmp/mangowm && cargo build --release && sudo install -m755 target/release/mangowm /usr/local/bin/)
  fi
  if ! command -v noctalia &>/dev/null; then
    echo "   Building Noctalia from source…"
    echo "   NOTE: if packages are masked, add to /etc/portage/package.accept_keywords:"
    echo "     dev-libs/wayland ~amd64"
    echo "     media-libs/mesa ~amd64"
    sudo emerge --noreplace --oneshot --quiet \
      cargo rust pipewire systemd libxkbcommon wayland wayland-protocols dbus openssl
    git clone https://github.com/noctalia-dev/shell.git /tmp/noctalia
    (cd /tmp/noctalia && cargo build --release && sudo install -m755 target/release/noctalia /usr/local/bin/)
  fi
}

# ── NixOS ─────────────────────────────────────────────────────────────────────
nixos() {
  echo "============================================================="
  echo " NixOS: add this to your configuration.nix / flake:"
  echo ""
  echo "  { pkgs, ... }: {"
  echo "    programs.noctalia.enable = true;"
  echo "    environment.systemPackages = with pkgs; ["
  echo "      mangowm foot brightnessctl playerctl"
  echo "      wl-clipboard polkit-gnome kdeconnect"
  echo "    ];"
  echo "  }"
  echo ""
  echo " Then copy the configs manually:"
  echo "   curl -fsSL $BASE/mango/Keybinds.conf \\"
  echo "     -o /etc/nixos/dotfiles/mango/Keybinds.conf"
  echo "   # … etc for each file"
  echo "============================================================="
}

# ── run ───────────────────────────────────────────────────────────────────────
if [ "${1:-}" = "--config-only" ]; then
  deploy_configs
  install_plugin
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
install_plugin
echo "Done! Log out and select MangoWM."
