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

#### Як це працює / How it works

Плагін складається з чотирьох компонентів, кожен у своєму `.luau`-файлі:

**`service.luau`** — фоновий сервіс. Запускається з Noctalia і постійно тримає зв'язок із MangoWM через `mmsg` IPC:
- `mmsg -g -l` — отримує поточний леяут (один раз при старті)
- `mmsg -w` — підписується на сповіщення про зміну леяуту (stream)
- Отримане значення нормалізується (напр. `"1:T"` → `"tile"`, `"DW"` → `"dwindle"`) і публікується в `noctalia.state.set("layout", id)`
- Якщо `mmsg` недоступний — встановлює `layout = "tile"` і не робить poll

**`widget.luau`** — бар-віджет. Показує іконку + назву поточного леяуту. Стежить за `noctalia.state.watch("layout", ...)`. При кліку:
- Якщо `cycle_on_click = true` — перемикає на наступний леяут по циклу (`CYCLE_ORDER`)
- Якщо `false` — відкриває панель вибору

**`panel.luau`** — панель з візуальною сіткою всіх леяутів (3 колонки). Кожна картка:
- Показує міні-прев'ю леяуту (ui.box з кольорами `primary_container`, `secondary_container`, `tertiary_container`)
- Активний леяут має border + пульсуючу анімацію (opacity змінюється через `math.sin` щооновно)
- Клік → `mmsg -s -l <id>` — миттєво змінює леяут

**`shortcut.luau`** — кнопка в Control Center. Показує назву поточного леяуту, при кліку відкриває ту саму панель.

**Data flow:**
```
MangoWM ──mmsg IPC──→ service.luau ──state.set("layout")──→ widget.luau
                                                          ─→ panel.luau
                                                          ─→ shortcut.luau
Клік по віджету ──→ mmsg -s -l <name> ──→ MangoWM ──→ mmsg -w callback ──→ всі .watch оновлюються
```

## Credits

Based on [hobbyist-dotfiles](https://github.com/BlackSparkz/hobbyist-dotfiles) by BlackSparkz.
