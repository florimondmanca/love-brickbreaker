local Entity = require 'core.Entity'

local Border = Entity:extend()

local init = Border.init
function Border:init(t)
    init(self, t)
    assert(type(t.x) == 'number', 'Brick requires number x')
    assert(type(t.y) == 'number', 'Brick requires number y')
    assert(type(t.width) == 'number', 'Brick requires number width')
    assert(type(t.height) == 'number', 'Brick requires number height')
    assert(type(t.color) == 'table', 'Brick requires table color')
    self.x = t.x
    self.y = t.y
    self.scale = t.scale or 1
    self.width = t.width
    self.height = t.height
    self.color = t.color
end

function Border:draw()
    love.graphics.setColor(unpack(self.color))
    love.graphics.push()
    love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
    love.graphics.scale(self.scale)
    love.graphics.rectangle('fill', -self.width/2, -self.height/2, self.width, self.height)
    love.graphics.pop()
end

return Border
