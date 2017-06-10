-- main.lua

local lume = require 'lib.lume'
local objectsP = require 'objects'
local utils = require 'lib.utils'


local colors = {
    background = {lume.color('rgb(50, 55, 75)', 256)},
    star = {
        center = {lume.color('rgb(250, 250, 240)', 256)},
        halo = {lume.color('rgb(100, 110, 150)', 256)},
        edge = {lume.color('rgb(100, 110, 150)', 256)},
    },
}

love.graphics.setBackgroundColor(colors.background)

---------------
-- Main loop --
---------------


local objects = {}
local player

--- calls a function on each object (if it has such function)
local function forEachObject(fname, ...)
    for _, object in ipairs(objects) do
        if object[fname] then object[fname](object, ...) end
    end
end

function love.load()
    player = objectsP.Player()
    lume.push(objects, player)
    for _, coords in ipairs(utils.makeBarGrid(10, 3, 40, 20)) do
        lume.push(objects, objectsP.Brick(coords.x, coords.y, coords.width, coords.height))
    end
end

function love.update(dt)
    forEachObject('update', dt)
end

function love.draw()
    forEachObject('draw')
end

function love.keypressed(key)
    forEachObject('keypressed', key)
end

function love.mousepressed(x, y, button)
    forEachObject('mousepressed', x, y, button)
end

function love.mousereleased(x, y, button)
    forEachObject('mousereleased', x, y, button)
end
