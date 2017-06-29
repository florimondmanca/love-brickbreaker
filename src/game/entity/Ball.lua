local Entity = require 'core.Entity'

local Ball = Entity:extend()

local init = Ball.init
function Ball:init(t)
    init(self, t)
    assert(type(t.radius) == 'number', 'Ball requires radius')
    assert(type(t.x) == 'number', 'Ball requires x')
    assert(type(t.y) == 'number', 'Ball requires y')
    assert(type(t.speed) == 'number', 'Ball requires speed')
    assert(type(t.angle) == 'number', 'Ball requires angle')
    assert(type(t.color) == 'table', 'Ball requires color')
    self.x = t.x
    self.y = t.y
    self.vx = t.speed * math.cos(t.angle)
    self.vy = t.speed * math.sin(t.angle)
    self.radius = t.radius
    self.color = t.color
    self:set{
        speed = {
            value = t.speed,
            get = function(self, value) return value end,
            set = function(self, speed)
                speed = speed or 0
                if speed < 0 then speed = 0 end
                if self.speed > 0 then
                    self.vx = self.vx * speed / self.speed
                    self.vy = self.vy * speed / self.speed
                end
                return speed
            end,
        },
        angle = {
            value = t.angle,
            get = function(self, value) return value end,
            set = function(self, angle)
                self.vx = self.speed * math.cos(angle)
                self.vy = self.speed * math.sin(angle)
                return angle
            end,
        }
    }
end

function Ball:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

function Ball:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.radius, 20)
end

return Ball
