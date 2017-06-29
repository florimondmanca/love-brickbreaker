local lume = require 'lib.lume'
local collisions = require 'core.collisions'
local Brick = require 'entity.Brick'
local Ball = require 'entity.Ball'
local Border = require 'entity.Border'
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

S:addGroup('borders', {init = function(group)
    group:add(Border{
        x = 0, y = 0, width = w, height = 10, color = {255, 255, 255}
    })
    group:add(Border{
        x = w - 10, y = 10, width = 10, height = h-10, color = {255, 255, 255}
    })
    group:add(Border{
        x = 0, y = 10, width = 10, height = h-10, color = {255, 255, 255}
    })
end})

S:addGroup('bricks', {init = function(group)
    for _, brick in makegrid{
        width=w, height=.6*h,
        nx=10, ny=10,
        pad=15, margin=30,
    } do
        group:add(Brick{
            x = brick.x, y = brick.y,
            width = brick.width, height = brick.height,
            color = {255, 255, 255, 255},
        })
    end
end})

S:addObjectAs('player', {
    script = 'entity.Player',
    arguments = {
        x = w/2,
        y = h - 50,
        minx = 10, maxx = w - 10,
        width = 100,
        height = 20,
        color = {255, 255, 255, 255},
        controls = 'mouse',
    }
})

S:addGroup('balls', {init = function(group, scene)
    group:add(Ball{
        x = scene.objects.player.x,
        y = scene.objects.player.y - 20,
        speed = 300,
        angle = -math.pi/2 + math.pi/4 * lume.random(-.2, .2),
        radius = 6,
        color = {255, 255, 100}
    })
end})


----------------
-- Collisions --
----------------

S:onCollisionBetween{
    groupA = 'bricks',
    groupB = 'balls',
    resolve = function(brick, ball, scene)
        local res = collisions.resolveRectangleToMovingCircle(brick, ball)
        ball.x = res.x
        ball.y = res.y
        ball.vx = res.vx
        ball.vy = res.vy
        brick.dead = true
        scene.objects.timer:tween(1, brick, {scale=0}, 'out-in-quad', function()
            brick:kill()
        end)
    end,
    collider = collisions.rectangleToCircle,
}

S:onCollisionBetween{
    object = 'player',
    group = 'balls',
    resolve = function(player, ball)
        local res = collisions.resolveRectangleToMovingCircle(player, ball)
        ball.x = res.x
        ball.vy = res.vy
    end,
    collider = collisions.rectangleToCircle,
}

S:onCollisionBetween{
    groupA = 'borders',
    groupB = 'balls',
    resolve = function(border, ball)
        local res = collisions.resolveRectangleToMovingCircle(border, ball)
        ball.x = res.x
        ball.y = res.y
        ball.vx = res.vx
        ball.vy = res.vy
    end,
    collider = collisions.rectangleToCircle,
}

S:addCallback('enter', function()
    love.graphics.setBackgroundColor(255, 100, 150, 255)
end)

return S
