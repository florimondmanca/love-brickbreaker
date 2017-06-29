local lume = require 'lib.lume'
local Entity = require 'core.Entity'

local Brick = Entity:extend()

--- Arguments
-- x : number
-- y : number
-- width : number
-- height : number
-- color : 3-table or 4-table
-- scale : number (optional, default is 1)
local init = Brick.init
function Brick:init(t)
    init(self, t)
    assert(type(t.x) == 'number', 'Brick requires number x')
    assert(type(t.y) == 'number', 'Brick requires number y')
    assert(type(t.width) == 'number', 'Brick requires number width')
    assert(type(t.height) == 'number', 'Brick requires number height')
    assert(type(t.color) == 'table', 'Brick requires table color')
    self.x = t.x
    self.y = t.y
    self.width = t.width
    self.height = t.height
    self.color = t.color
    self:set{
        scale = {
            value = t.scale or 1,
            get = function(self, value) return value end,
            set = function(self, new) return new or 1 end,
        }
    }
end

function Brick:draw()
    love.graphics.push()
    love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
    love.graphics.scale(self.scale)
    love.graphics.setColor(unpack(self.color))
    love.graphics.rectangle('fill', -self.width/2, -self.height/2, self.width, self.height)
    love.graphics.pop()
end

return Brick
