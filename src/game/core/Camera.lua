local class = require 'lib.class'
local lume = require 'lib.lume'

local Camera = class()

function Camera:init()
    self.x = 0
    self.y = 0
    self.sx = 1
    self.sy = 1
    self.r = 0
end

function Camera:rotate(dr)
    self.r = self.r + dr
    return self
end

function Camera:move(dx, dy)
    self.x = self.x + (dx or 0)
    self.y = self.y + (dy or 0)
    return self
end

function Camera:scale(sx, sy)
    sx = sx or 1
    self.sx = self.sx * sx
    self.sy = self.sy * (sy or sx)
    return self
end

function Camera:setPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
    return self
end

function Camera:setScale(sx, sy)
    self.sx = sx or self.sx
    self.sy = sy or self.sy
    return self
end

function Camera:set()
    love.graphics.push()
    love.graphics.rotate(self.r)
    love.graphics.scale(1/self.sx, 1/self.sy)
    love.graphics.translate(self.x, self.y)
end

function Camera:unset() love.graphics.pop() end

return Camera
