local lume = require 'lib.lume'
local class = require 'lib.class'
local asserts = require 'lib.asserts'


local Action = class('Action')

function Action:initialize(t)
    for k, v in pairs(t) do
        self[k] = v
    end
end

function Action:apply() end


local Bind = Action:subclass('Bind')

function Bind:initialize(t)
    asserts.required(t.left, 'left')
    asserts.required(t.right, 'right')
    asserts.required(t.intensity, 'intensity')
    Action.initialize(self, t)
end

function Bind:apply(graph)
    local pa, pb = graph.points[self.left], graph.points[self.right]
    local diff = pa:difference(pb)
    local f = {
        x = -self.intensity * diff.x,
        y = -self.intensity * diff.y
    }
    pa:addForce(f.x, f.y)
    pb:addForce(-f.x, -f.y)
end


local Repulse = class('Repulse')

function Repulse:initialize(t)
    asserts.required(t.radius, 'radius (repulsion action rage)')
    t.r3 = t.radius^3
    Action.initialize(self, t)
end

function Repulse:apply(graph)
    for i = 1, #graph.points do
        for j = i + 1, #graph.points do
            local pa, pb = graph.points[i], graph.points[j]
            local diff = pa:difference(pb)
            local d2 = diff.x^2 + diff.y^2
            local d3 = d2 * math.sqrt(d2)
            local f = {
                x = diff.x / (d3/self.r3),
                y = diff.y / (d3/self.r3)
            }
            pa:addForce(f.x, f.y)
            pb:addForce(-f.x, -f.y)
        end
    end
end


local Dampen = Action:subclass('Dampen')

function Dampen:initialize(t)
    asserts.required(t.index, 'index (star index in star graph)')
    asserts.required(t.intensity, 'intensity')
    Action.initialize(self, t)
end

function Dampen:apply(graph)
    local point = graph.points[self.index]
    point:addForce(-self.intensity * point.vx, -self.intensity * point.vy)
end


local Gravity = Action:subclass('Gravity')

function Gravity:initialize(t)
    asserts.required(t.g, 'g (gravity intensity)')
    asserts.required(t.radius, 'r (gravity action range)')
    Action.initialize(self, t)
end

function Gravity:apply(graph)
    local center = {
        x = lume.sum(graph.points, function(p) return p.x end) / #graph.points,
        y = lume.sum(graph.points, function(p) return p.y end) / #graph.points
    }
    for _, point in ipairs(graph.points) do
        local diff = point:difference(center)
        local d2 = diff.x^2 + diff.y^2
        local d = math.sqrt(d2)
        local fval = -self.g * math.log(1 + d2/self.radius^2) / d
        local f = {
            x = fval * diff.x,
            y = fval * diff.y
        }
        point:addForce(f.x, f.y)
    end
end

return {
    Bind = Bind,
    Repulse = Repulse,
    Dampen = Dampen,
    Gravity = Gravity
}
