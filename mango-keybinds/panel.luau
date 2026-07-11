--!nonstrict
-- [[panel]]: keybind browser grouped by category.

local KEYBINDS = {
  {
    title = "Noctalia Shell",
    icon = "noctalia",
    items = {
      { keys = "Super + Space",     desc = "Launcher" },
      { keys = "Super + C",         desc = "Clipboard panel" },
      { keys = "Super + R",         desc = "Control center" },
      { keys = "Super + P",         desc = "Session panel" },
      { keys = "Super + W",         desc = "Wallpaper browser" },
      { keys = "Alt + L",           desc = "Lock screen" },
      { keys = "Alt + O",           desc = "Power off" },
      { keys = "Alt + R",           desc = "Reboot" },
      { keys = "Alt + S",           desc = "Suspend" },
      { keys = "Alt + Return",      desc = "Control center" },
    },
  },
  {
    title = "Applications",
    icon = "apps",
    items = {
      { keys = "Super + A",         desc = "Terminal (auto-detect)" },
      { keys = "Super + B",         desc = "LibreWolf" },
      { keys = "Super + D",         desc = "Thunar (toggle)" },
      { keys = "Super + E",         desc = "Bluetooth (bluetui)" },
      { keys = "Super + G",         desc = "System monitor (btop)" },
      { keys = "Super + M",         desc = "Telegram" },
      { keys = "Super + N",         desc = "File manager (yazi)" },
      { keys = "Super + S",         desc = "Helium browser (toggle)" },
      { keys = "Super + T",         desc = "Terminal (foot)" },
      { keys = "Super + X",         desc = "Music (cmus)" },
      { keys = "Super + Y",         desc = "Network (nmtui)" },
      { keys = "Super + Z",         desc = "LocalSend (toggle)" },
      { keys = "Super + Shift + A", desc = "AI chat (aichat)" },
      { keys = "Alt + W",           desc = "Browse wallpapers (yazi)" },
    },
  },
  {
    title = "Layouts",
    icon = "layout",
    items = {
      { keys = "Super + Tab",       desc = "Switch to next layout" },
      { keys = "Shift + Return",    desc = "Toggle split direction" },
    },
  },
  {
    title = "Navigation",
    icon = "arrow-move",
    items = {
      { keys = "Super + H/J/K/L",   desc = "Focus left/down/up/right" },
      { keys = "Super + Arrows",    desc = "Focus left/right" },
      { keys = "Super + Up/Down",   desc = "View prev/next tag" },
    },
  },
  {
    title = "Tags (workspaces)",
    icon = "number",
    items = {
      { keys = "Super + 1-9",       desc = "Switch to tag N" },
      { keys = "Super + Shift + 1-9", desc = "Move window to tag N" },
      { keys = "Super + Shift + H/J/K/L", desc = "Swap window" },
    },
  },
  {
    title = "Window operations",
    icon = "window",
    items = {
      { keys = "Super + Q",         desc = "Kill focused window" },
      { keys = "Super + F",         desc = "Toggle maximize" },
      { keys = "Super + V",         desc = "Toggle float" },
      { keys = "Super + O",         desc = "Toggle overview" },
      { keys = "Alt + F",           desc = "Toggle fullscreen" },
      { keys = "Alt + U/I",         desc = "Minimize / restore" },
      { keys = "Alt + Space",       desc = "Toggle scratchpad" },
    },
  },
  {
    title = "Move / resize",
    icon = "arrows-move",
    items = {
      { keys = "Super + Alt + H/J/K/L", desc = "Move floating window" },
      { keys = "Super + Ctrl + H/J/K/L", desc = "Resize floating window" },
    },
  },
  {
    title = "Mouse & gestures",
    icon = "mouse",
    items = {
      { keys = "Super + LMB",       desc = "Move window" },
      { keys = "Super + RMB",       desc = "Resize window" },
      { keys = "Middle click",      desc = "Kill window" },
      { keys = "3-finger swipe",    desc = "Focus direction" },
      { keys = "4-finger swipe",    desc = "Overview / tags" },
    },
  },
  {
    title = "Media",
    icon = "player-play",
    items = {
      { keys = "XF86AudioRaiseVol", desc = "Volume +10%" },
      { keys = "XF86AudioLowerVol", desc = "Volume -10%" },
      { keys = "XF86AudioMute",     desc = "Mute toggle" },
      { keys = "XF86MonBrightness", desc = "Brightness +/-10%" },
      { keys = "XF86AudioNext/Prev",desc = "Next/previous track" },
      { keys = "XF86AudioPlay",     desc = "Play / pause" },
      { keys = "Alt + V/C/X",      desc = "Next / play / prev track" },
    },
  },
  {
    title = "Screenshots",
    icon = "screenshot",
    items = {
      { keys = "Print",             desc = "Full screenshot" },
      { keys = "Alt + Print",       desc = "Partial screenshot" },
      { keys = "Ctrl + Print",      desc = "Screen recording" },
    },
  },
  {
    title = "System",
    icon = "settings",
    items = {
      { keys = "Super + Delete",    desc = "Clear clipboard history" },
      { keys = "Super + Ctrl + E",  desc = "Quit MangoWM" },
      { keys = "Alt + D/E/Y",      desc = "Toggle radios / BT / Wi-Fi" },
      { keys = "Alt + K",           desc = "KDE Connect (toggle)" },
      { keys = "Alt + N",           desc = "Reload config" },
    },
  },
}

local searchQuery = ""
local function matches(item, query)
  if query == "" then return true end
  local q = query:lower()
  return item.desc:lower():find(q, 1, true) ~= nil
      or item.keys:lower():find(q, 1, true) ~= nil
end

local function itemRow(item)
  return ui.row({ gap = 8, padding = { left = 8, right = 8, top = 6, bottom = 6 },
                  fill = "surface_container", radius = 8 }, {
    ui.box({ flexGrow = 1 }, {
      ui.label({ text = item.desc, fontSize = 13, color = "on_surface" }),
    }),
    ui.box({ fill = "surface_variant", radius = 6,
             padding = { left = 8, right = 8, top = 4, bottom = 4 } }, {
      ui.label({ text = item.keys, fontSize = 11, fontWeight = "bold", color = "primary" }),
    }),
  })
end

local function render()
  local sections = {}
  for _, group in ipairs(KEYBINDS) do
    local matched = {}
    for _, item in ipairs(group.items) do
      if matches(item, searchQuery) then
        table.insert(matched, item)
      end
    end
    if #matched > 0 or searchQuery == "" then
      if searchQuery ~= "" then
        -- skip group header when filtering, just show items
      else
        table.insert(sections, ui.row({ gap = 6, align = "center",
                                        padding = { top = 8, bottom = 2 } }, {
          ui.glyph({ name = group.icon, size = 14, color = "primary" }),
          ui.label({ text = group.title, fontSize = 14, fontWeight = "bold",
                     color = "on_surface" }),
        }))
      end
    end
    if #matched > 0 then
      for _, item in ipairs(matched) do
        table.insert(sections, itemRow(item))
      end
    end
  end

  if #sections == 0 then
    table.insert(sections, ui.label({ text = "  No matching keybinds", fontSize = 13,
                                      color = "on_surface_variant", padding = { top = 16 } }))
  end

  panel.render(ui.column({ gap = 4, padding = 16, flexGrow = 1 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.row({ gap = 8, align = "center" }, {
        ui.glyph({ name = "keyboard", size = 18, color = "primary" }),
        ui.label({ text = "Keybinds", fontSize = 16, fontWeight = "bold",
                   color = "on_surface" }),
      }),
      ui.button({ glyph = "close", onClick = "onClose" }),
    }),
    ui.textbox({ id = "search", placeholder = "Search binds…", flexGrow = 1,
                 onChanged = onSearch, fontSize = 13 }),
    ui.separator({ thickness = 1, color = "outline_variant", spacing = 6 }),
    ui.scroll({ flexGrow = 1, gap = 3 }, sections),
  }))
end

function onSearch(text)
  searchQuery = text
  render()
end

function onClose()
  panel.close()
end

function onOpen(_context)
  searchQuery = ""
  render()
end

local function render()
  local sections = {}
  for _, group in ipairs(KEYBINDS) do
    table.insert(sections, ui.row({ gap = 6, align = "center",
                                    padding = { top = 8, bottom = 2 } }, {
      ui.glyph({ name = group.icon, size = 14, color = "primary" }),
      ui.label({ text = group.title, fontSize = 14, fontWeight = "bold",
                 color = "on_surface" }),
    }))
    for _, item in ipairs(group.items) do
      table.insert(sections, itemRow(item))
    end
  end

  panel.render(ui.column({ gap = 4, padding = 16, flexGrow = 1 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.row({ gap = 8, align = "center" }, {
        ui.glyph({ name = "keyboard", size = 18, color = "primary" }),
        ui.label({ text = "Keybinds", fontSize = 16, fontWeight = "bold",
                   color = "on_surface" }),
      }),
      ui.button({ glyph = "close", onClick = "onClose" }),
    }),
    ui.separator({ thickness = 1, color = "outline_variant", spacing = 6 }),
    ui.scroll({ flexGrow = 1, gap = 3 }, sections),
  }))
end

function onClose()
  panel.close()
end

function onOpen(_context)
  render()
end
