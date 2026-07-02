--!nonstrict
-- Bar [[widget]]: open keybind browser on click.

barWidget.setGlyph("keyboard")
barWidget.setTooltip("View keybinds")

function onClick()
  noctalia.togglePanel("me/mango-keybinds:browser")
end

function update()
  noctalia.setUpdateInterval(0)
end
