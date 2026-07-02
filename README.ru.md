# MangoWM + Noctalia Dotfiles

Минимальные дотфайлы для **[MangoWM](https://github.com/mangowm/mangowm)** с оболочкой **[Noctalia](https://noctalia.dev/)** (v5).

## Состав

| Папка | Описание |
|-------|----------|
| `mango/` | Конфиг композитора MangoWM — хоткеи, анимации, блюр, тени, правила окон, автозапуск |
| `noctalia/` | Конфиг оболочки Noctalia — бар, уведомления, OSD, экран блокировки, idle, меню сессии |

## Требования

- [MangoWM](https://github.com/mangowm/mangowm) — тайлинговый Wayland-композитор
- [Noctalia v5](https://docs.noctalia.dev/v5/getting-started/installation/) — среда рабочего стола
- Папка с обоями `~/Wallpapers/` (или отредактируйте скрипт автозапуска)

## Установка

Один скрипт поддерживает все дистрибутивы — определяет ваш пакетный менеджер
и устанавливает MangoWM + Noctalia (собирает из исходников, если пакета нет).

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Collalaoo/mango-noctalia-dotfiles/main/bootstrap.sh)
```

Поддерживается: Arch, Fedora, openSUSE, Ubuntu/Debian, Void, Gentoo, NixOS¹.

¹ Для NixOS скрипт выводит инструкцию для добавления в configuration.nix.

### Вручну (будь-який дистрибутив)

```sh
git clone https://github.com/Collalaoo/mango-noctalia-dotfiles.git ~/.dotfiles
ln -sf ~/.dotfiles/mango ~/.config/mango
ln -sf ~/.dotfiles/noctalia ~/.config/noctalia
```

### Тільки конфіги (якщо MangoWM + Noctalia вже встановлені)

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Collalaoo/mango-noctalia-dotfiles/main/bootstrap.sh) --config-only
```

## Хоткеи

Все хоткеи соответствуют оригинальным [hobbyist-dotfiles](https://github.com/BlackSparkz/hobbyist-dotfiles). Основные изменения:

- **`Super + Space`** — лаунчер (Noctalia)
- **`Super + C`** — буфер обмена (Noctalia)
- **`Super + R`** — контрольная панель (Noctalia)
- **`Super + P`** — меню сессии (Noctalia)
- **`Super + Tab`** — смена раскладки MangoWM
- **`Super + W`** — выбор обоев (Noctalia)
- **`Alt + L`** — экран блокировки (Noctalia)
- **`Alt + O/R/S`** — выключение / перезагрузка / сон (Noctalia IPC)

## Плагины

### mango-keybinds

Открывает панель со всеми хоткеями, сгруппированными по категориям (Noctalia shell,
приложения, раскладки, навигация, теги, окна, медиа, система…).

```sh
noctalia plugin add Collalaoo/mango-keybinds
```

Добавьте `"keybinds"` в `bar.main.end` в `noctalia/config.toml`:
```toml
end = ["media", "tray", "volume", "notifications", "keybinds", "session"]
```

### mango-layouts

Добавляет индикатор раскладки в бар:

```sh
noctalia plugin add Collalaoo/mango-layouts
```

Затем добавьте `"layout"` в `bar.main.start` в `noctalia/config.toml`.

#### Как это работает

Плагин состоит из четырех компонентов:

**`service.luau`** — фоновый сервис. Общается с MangoWM через `mmsg` IPC:
- `mmsg -g -l` — получает текущий layout при старте
- `mmsg -w` — подписывается на уведомления об изменении layout
- Нормализует значение (напр. `"1:T"` → `"tile"`) и публикует в `noctalia.state.set("layout", id)`

**`widget.luau`** — бар-виджет. Показывает иконку + название. При клике переключает на следующий layout по циклу, либо открывает панель выбора.

**`panel.luau`** — панель с сеткой превью всех layout'ов (3 колонки). Активный layout подсвечен и пульсирует. Клик → `mmsg -s -l <id>`.

**`shortcut.luau`** — кнопка в Control Center, открывает ту же панель.

**Data flow:**
```
MangoWM ──mmsg IPC──→ service.luau ──state.set("layout")──→ widget / panel / shortcut
Клик ──→ mmsg -s -l <name> ──→ MangoWM ──→ mmsg -w callback ──→ все .watch обновляются
```

## Благодарности

Основано на [hobbyist-dotfiles](https://github.com/BlackSparkz/hobbyist-dotfiles) от BlackSparkz.
