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

### mango-keybinds

Opens a searchable panel with every keybind grouped by category (Noctalia shell,
applications, layouts, navigation, tags, windows, media, system…).

```sh
noctalia plugin add Collalaoo/mango-keybinds
```

Then add `"keybinds"` to `bar.main.end` in `noctalia/config.toml`:
```toml
end = ["media", "tray", "volume", "notifications", "keybinds", "session"]
```

### mango-layouts

Adds a layout switcher — bar widget, preview panel, and control center shortcut.

```sh
noctalia plugin add Collalaoo/mango-layouts
```

Then add `"layout"` to `bar.main.start` in `noctalia/config.toml`.

#### How it works

The plugin has four components, each in its own `.luau` file:

**`service.luau`** — background service. Connects to MangoWM via `mmsg` IPC:
- `mmsg -g -l` — fetches current layout on start
- `mmsg -w` — subscribes to layout change notifications (stream)
- Normalizes the value (e.g. `"1:T"` → `"tile"`, `"DW"` → `"dwindle"`) and publishes via `noctalia.state.set("layout", id)`
- If `mmsg` is unavailable — sets `layout = "tile"` without polling

**`widget.luau`** — bar widget. Shows icon + current layout name. Watches `noctalia.state.watch("layout", ...)`. On click:
- If `cycle_on_click = true` — cycles to next layout
- If `false` — opens the selection panel

**`panel.luau`** — panel with visual grid of all layouts (3 columns). Each card:
- Shows a mini layout preview (colored boxes using `primary_container`, `secondary_container`, `tertiary_container`)
- Active layout has a border + pulsing animation (opacity via `math.sin` every frame)
- Click → `mmsg -s -l <id>` — switches layout instantly

**`shortcut.luau`** — Control Center button. Shows current layout name, opens the same panel on click.

**Data flow:**
```
MangoWM ──mmsg IPC──→ service.luau ──state.set("layout")──→ widget.luau
                                                          ─→ panel.luau
                                                          ─→ shortcut.luau
Widget click ──→ mmsg -s -l <name> ──→ MangoWM ──→ mmsg -w callback ──→ all .watch updated
```

## Credits

Based on [hobbyist-dotfiles](https://github.com/BlackSparkz/hobbyist-dotfiles) by BlackSparkz.
