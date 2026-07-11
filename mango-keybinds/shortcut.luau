--!nonstrict
-- Control Center [[shortcut]]: open keybind browser.

shortcut.setLabel("Keybinds")
shortcut.setIcon("keyboard")
shortcut.setActive(false)
shortcut.setEnabled(true)

function onClick()
  noctalia.togglePanel("Collalaoo/mango-keybinds:browser")
end
