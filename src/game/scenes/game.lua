-- local gamestate = require 'lib.gamestate'
local lume = require 'lib.lume'
local collisions = require 'core.collisions'
local Brick = require 'entity.Brick'
local Ball = require 'entity.Ball'
local Border = require 'entity.Border'
local SceneBuilder = require 'core.SceneBuilder'

local w, h = love.graphics.getDimensions()

local COLORS = {
    background = {lume.color('#594F3D', 255)},
    borders = {lume.color('#DBB36D', 255)},
    bricks = {lume.color('#DBB36D', 255)},
    player = {lume.color('#DBB36D', 255)},
    ball = {lume.color('#DBB36D', 255)},
    ballParticles = {lume.color('#F2EFEA', 255)},
}

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
    local c = COLORS.borders
    group:add(Border{
        x = 0, y = 0, width = w, height = 10, color = c
    })
    group:add(Border{
        x = w - 10, y = 10, width = 10, height = h-10, color = c
    })
    group:add(Border{
        x = 0, y = 10, width = 10, height = h-10, color = c
    })
    group:add(Border{
        x = 10, y = h - 10, width = w-20, height = 10, color = c
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
            color = COLORS.bricks,
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
        height = 15,
        color = COLORS.player,
        controls = 'mouse',
    }
})

S:addGroup('balls', {z = -1, init = function(group, scene)
    group:add(Ball{
        x = scene.objects.player.x,
        y = scene.objects.player.y - 20,
        speed = 300,
        angle = -math.pi/2 + math.pi/4 * lume.random(-1, 1),
        radius = 6,
        color = COLORS.ball,
        particleColor = COLORS.ballParticles,
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
        scene.objects.timer:tween(.3, brick, {opacity=0}, 'in-quad')
        scene.objects.timer:tween(.1, brick, {scale=1.2}, 'out-quad',
        function()
            scene.objects.timer:tween(.2, brick, {scale=0}, 'in-quad',
            function() brick:kill() end)
        end)
        scene.objects.timer:tween(.3, brick, {rotation=lume.random(-.1, .1) * math.pi}, 'in-quad')
    end,
    collider = collisions.rectangleToCircle,
}

S:onCollisionBetween{
    object = 'player',
    group = 'balls',
    resolve = function(player, ball, scene)
        local res = collisions.resolveRectangleToMovingCircle(player, ball)
        ball.x = res.x
        ball.vy = res.vy
        -- juicy player bar!
        scene.objects.timer:tween(.08, player, {scaleX = 1.2}, 'in-quad',
        function()
            scene.objects.timer:tween(.14, player, {scaleX = 1}, 'out-quad')
        end)
        local y = player.y
        scene.objects.timer:tween(.06, player, {y = y + 5}, 'in-quad',
        function()
            scene.objects.timer:tween(.1, player, {y=y}, 'in-out-quad')
        end
        )
    end,
    collider = collisions.rectangleToCircle,
}

S:onCollisionBetween{
    groupA = 'borders',
    groupB = 'balls',
    resolve = function(border, ball, scene)
        local res = collisions.resolveRectangleToMovingCircle(border, ball)
        ball.x = res.x
        ball.y = res.y
        ball.vx = res.vx
        ball.vy = res.vy
        scene.objects.timer:tween(.08, border, {scale = 1.5}, 'out-quad',
        function()
            scene.objects.timer:tween(.14, border, {scale = 1}, 'out-quad')
        end)
    end,
    collider = collisions.rectangleToCircle,
}

S:addUpdateAction(function(scene)
    for _, ball in scene:group('balls'):each() do
        if ball.y > h then ball:kill() end
    end
end)

S:addCallback('enter', function(scene)
    love.graphics.setBackgroundColor(unpack(COLORS.background))

    for _, brick in scene:group('bricks'):each() do
        local y = brick.y
        brick.y = y - h
        scene.objects.timer:tween(lume.random(.4, .8), brick, {y = y}, 'out-quad', function()
            brick.y = y
        end)
    end
end)

return S
