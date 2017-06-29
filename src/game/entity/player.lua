local lume = require 'lib.lume'
local Entity = require 'core.Entity'


local controls = {
    keyboard = {name = 'keyboard', control = function(self)
        if love.keyboard.isDown('left') then self.x = self.x - 10 end
        if love.keyboard.isDown('right') then self.x = self.x + 10 end
    end},
    mouse = {name = 'mouse', control = function(self)
        self.x = love.mouse.getX() - self.width/2
    end},
}


local Player = Entity:extend()

Player:set{
    controls = {
        value = controls.keyboard,
        set = function(self, name)
            if controls[name] then return controls[name]
            else error('Unknown controls: ' .. tostring(name)) end
        end,
    },
}

local init = Player.init
function Player:init(t)
    init(self, t)
    assert(type(t.x) == 'number', 'Player requires number x')
    assert(type(t.y) == 'number', 'Player requires number y')
    assert(type(t.width) == 'number', 'Player requires number width')
    assert(type(t.height) == 'number', 'Player requires number height')
    assert(type(t.minx) == 'number', 'Player requires number minx')
    assert(type(t.maxx) == 'number', 'Player requires number maxx')
    assert(type(t.color) == 'table', 'Player requires table color')
    self.x = t.x - t.width/2
    self.y = t.y
    self.minx = t.minx
    self.maxx = t.maxx
    self.width = t.width
    self.height = t.height
    self.color = t.color
    self.controls = t.controls or self.controls.name
end

function Player:update()
    self.controls.control(self)
    self.x = lume.clamp(self.x, self.minx, self.maxx - self.width)
end

function Player:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Player
