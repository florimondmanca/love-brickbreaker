-- main.lua

local class = require 'lib.class'
local lume = require 'lib.lume'
local actions = require 'actions'
local asserts = require 'lib.asserts'


local colors = {
    background = {lume.color('rgb(50, 55, 75)', 256)},
    star = {
        center = {lume.color('rgb(250, 250, 240)', 256)},
        halo = {lume.color('rgb(100, 110, 150)', 256)},
        edge = {lume.color('rgb(100, 110, 150)', 256)},
    },
}

love.graphics.setBackgroundColor(colors.background)

-- constants
local w, h = love.graphics.getDimensions()

---------------
-- Utilities --
---------------


-------------
-- Objects --
-------------

local function Player()
    local player = {
        x = w/2,
        y = h-40,
        width = 100,
        height = 20
    }

    function player:update(dt)
        -- move with keyboard
        if love.keyboard.isDown('left') then self.x = self.x - 10 end
        if love.keyboard.isDown('right') then self.x = self.x + 10 end
    end

    function player:draw()
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end

    return player
end

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
    player = Player()
    lume.push(objects, player)
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
