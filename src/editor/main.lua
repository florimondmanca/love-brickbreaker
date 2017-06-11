local lume = require 'lib.lume'
local settings = require 'settings'

local w, h = love.graphics.getDimensions()

love.graphics.setBackgroundColor(settings.colors.background)

-- create widgets
local widgets = {
    -- canvas
    canvas = lume.merge(
        require 'widgets.canvas', {
            x=0, y=40, w=w, h=h-40
        }
    ),
    --- level name field
    -- label
    levelNameLabel = lume.merge(
        require 'widgets.label', {
            x=0, y=5
        }
    ):setText('Level name'),
    -- textbox
    levelNameTextBox = lume.merge(
        require 'widgets.textbox', {
            x=100, y=5, w=200, h=24
        }
    ),
}

-- add buttons
widgets.clearLevelNameTextBoxButton = lume.merge(
    require 'widgets.button', {
        x=320, y=5, h=30,
        action = function() widgets.levelNameTextBox:clear() end
    }
):setText('Clear')

widgets.exportButton = lume.merge(
    require 'widgets.button', {
        x=w-70, y=5,
        action = function() widgets.canvas:export(widgets.levelNameTextBox:getText() .. '.txt') end
    }
):setText('Export')


-- define Love2d callbacks
for _, fname in ipairs({
    'load', 'update', 'draw', 'mousepressed', 'mousereleased', 'mousemoved',
    'keypressed', 'keyreleased', 'textinput',
}) do
    love[fname] = function(...)
        for _, widget in pairs(widgets) do
            if widget[fname] then widget[fname](widget, ...) end
        end
    end
end
