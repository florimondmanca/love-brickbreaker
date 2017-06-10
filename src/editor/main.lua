local lume = require 'lib.lume'

love.graphics.setBackgroundColor(200, 200, 200)

local widgets = {}
lume.push(widgets, require 'canvas', require 'textbox', require 'singletoast')

for _, fname in ipairs({
    'load', 'update', 'draw', 'mousepressed', 'mousereleased', 'mousemoved',
    'keypressed', 'keyreleased', 'textinput',
}) do
    love[fname] = function(...)
        for _, widget in ipairs(widgets) do
            if widget[fname] then widget[fname](widget, ...) end
        end
    end
end
