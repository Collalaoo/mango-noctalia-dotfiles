--!nonstrict
-- Bar [[widget]]: open keybind browser on click.

barWidget.setGlyph("keyboard")
barWidget.setTooltip("View keybinds")

function onClick()
  noctalia.togglePanel("Collalaoo/mango-keybinds:browser")
end

-- no dynamic update needed
