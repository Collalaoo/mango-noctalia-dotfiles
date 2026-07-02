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

```sh
git clone https://github.com/YOUR_USERNAME/mango-noctalia-dotfiles.git ~/.dotfiles
ln -sf ~/.dotfiles/mango ~/.config/mango
ln -sf ~/.dotfiles/noctalia ~/.config/noctalia
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

### mango-layouts

Добавляет индикатор раскладки в бар:

```sh
noctalia plugin add Collalaoo/mango-layouts
```

Затем добавьте `"layout"` в `bar.main.start` в `noctalia/config.toml`.

## Благодарности

Основано на [hobbyist-dotfiles](https://github.com/BlackSparkz/hobbyist-dotfiles) от BlackSparkz.
