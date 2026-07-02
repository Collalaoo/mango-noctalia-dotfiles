# MangoWM + Noctalia Dotfiles

Minimal dotfiles for **[MangoWM](https://github.com/mangowm/mangowm)** with the **[Noctalia](https://noctalia.dev/)** shell (v5).

## What's included

| Directory | Description |
|-----------|-------------|
| `mango/` | MangoWM compositor config — keybinds, animations, blur, shadows, window rules, autostart |
| `noctalia/` | Noctalia shell config — bar, notifications, OSD, lock screen, idle, session menu |

## Requirements

- [MangoWM](https://github.com/mangowm/mangowm) — tiling Wayland compositor
- [Noctalia v5](https://docs.noctalia.dev/v5/getting-started/installation/) — shell environment
- A wallpaper directory at `~/Wallpapers/` (or edit the autostart script)

## Installation

One script handles all distros — it detects your package manager and installs
MangoWM + Noctalia (building from source when no package is available).

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Collalaoo/mango-noctalia-dotfiles/main/bootstrap.sh)
```

Supported: Arch, Fedora, openSUSE, Ubuntu/Debian, Void, Gentoo, NixOS¹.

¹ NixOS prints the config snippet instead (declarative flakes).

### Manual (any distro)

```sh
git clone https://github.com/Collalaoo/mango-noctalia-dotfiles.git ~/.dotfiles
ln -sf ~/.dotfiles/mango ~/.config/mango
ln -sf ~/.dotfiles/noctalia ~/.config/noctalia
```

### Config only (if MangoWM + Noctalia are already installed)

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Collalaoo/mango-noctalia-dotfiles/main/bootstrap.sh) --config-only
```

## Keybinds

All keybinds follow the original [hobbyist-dotfiles](https://github.com/BlackSparkz/hobbyist-dotfiles) layout. Notable changes:

- **`Super + Space`** — open launcher (Noctalia)
- **`Super + C`** — clipboard panel (Noctalia)
- **`Super + R`** — control center (Noctalia)
- **`Super + P`** — session panel (Noctalia)
- **`Super + Tab`** — switch MangoWM layout
- **`Super + W`** — wallpaper browser (Noctalia)
- **`Alt + L`** — lock screen (Noctalia)
- **`Alt + O/R/S`** — power off / reboot / suspend (Noctalia IPC)

## Plugins

### mango-layouts

Adds a layout indicator widget to the bar:

```sh
noctalia plugin add Collalaoo/mango-layouts
```

Then add `"layout"` to `bar.main.start` in `noctalia/config.toml`.

## Credits

Based on [hobbyist-dotfiles](https://github.com/BlackSparkz/hobbyist-dotfiles) by BlackSparkz.
