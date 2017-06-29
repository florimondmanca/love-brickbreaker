local lume = require 'lib.lume'
local Brick = require 'entity.Brick'
local SceneBuilder = require 'core.SceneBuilder'

local w, h = love.graphics.getDimensions()

local function makegrid(t)
    assert(type(t.width) == 'number', 'grid() requires number width')
    assert(type(t.height) == 'number', 'grid() requires number height')
    assert(type(t.nx) == 'number', 'grid() requires number nx')
    assert(type(t.ny) == 'number', 'grid() requires number ny')
    t.padw = t.padw or t.pad or 0
    t.padh = t.padh or t.padw or 0
    t.marginw = t.marginw or t.margin or 0
    t.marginh = t.marginh or t.marginw
    local brickw = (t.width - 2*t.marginw) / t.nx - t.padw
    local brickh = (t.height - 2*t.marginh) / t.ny - t.padh
    local g = {}
    for i = 1, t.nx do
        for j = 1, t.ny do
            lume.push(g, {
                x = t.marginw + (i-1) * (brickw + t.padw),
                y = t.marginh + (j-1) * (brickh + t.padh),
                width = brickw,
                height = brickh,
            })
        end
    end
    return next, g
end

local S = SceneBuilder()

S:addGroup('bricks', {init = function(group)
    for _, brick in makegrid{
        width=w, height=.6*h,
        nx=20, ny=15,
        pad=6, margin=30,
    } do
        group:add(Brick{
            x = brick.x, y = brick.y,
            width = brick.width, height = brick.height,
            color = {255, 255, 255, 255},
        })
    end
end})

S:addCallback('enter', function()
    love.graphics.setBackgroundColor(255, 100, 150, 255)
end)

return S
