local Entity = require 'core.Entity'

local Border = Entity:extend()

local init = Border.init
function Border:init(t)
    init(self, t)
    assert(type(t.x) == 'number', 'Brick requires number x')
    assert(type(t.y) == 'number', 'Brick requires number y')
    assert(type(t.width) == 'number', 'Brick requires number width')
    assert(type(t.height) == 'number', 'Brick requires number height')
    self.x = t.x
    self.y = t.y
    self.scale = t.scale or 1
    self.width = t.width
    self.height = t.height
end

return Border
