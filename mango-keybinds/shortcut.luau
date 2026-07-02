--!nonstrict
-- Control Center [[shortcut]]: open keybind browser.

shortcut.setLabel("Keybinds")
shortcut.setIcon("keyboard")
shortcut.setActive(false)
shortcut.setEnabled(true)

function onClick()
  noctalia.togglePanel("me/mango-keybinds:browser")
end
