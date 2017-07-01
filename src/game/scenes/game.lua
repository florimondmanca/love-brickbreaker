-- local gamestate = require 'lib.gamestate'
local lume = require 'lib.lume'
local collisions = require 'core.collisions'
local Ball = require 'entity.Ball'
local Border = require 'entity.Border'
local SceneBuilder = require 'core.SceneBuilder'

local w, h = love.graphics.getDimensions()


---------------
-- Utilities --
---------------

local COLORS = {
    background = {lume.color('#594F3D', 255)},
    borders = {lume.color('#DBB36D', 255)},
    bricks = {lume.color('#DBB36D', 255)},
    player = {lume.color('#DBB36D', 255)},
    ball = {lume.color('#DBB36D', 255)},
    ballParticles = {lume.color('#F2EFEA', 255)},
}

local function makeBall(x, y)
    return Ball{
        x = x, y = y,
        radius = 6,
        speed = 500,
        angle = -math.pi/2 + math.pi/4 * lume.random(-1, 1),
        color = COLORS.ball,
        particleColor = COLORS.ballParticles,
    }
end

--- creates a ball attached to an object
-- ball's :update() method is temporarily overridden and is restored
-- when its :detach() method is called
-- optional offsets on x and y can be given
local function makeBallAttachedTo(object, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local ball = makeBall(object.x + offsetX, object.y + offsetY)
    ball.attached = true

    local update = ball.update
    function ball:update()
        self.x = object.x + offsetX
        self.y = object.y + offsetY
    end

    function ball:detach()
        self.update = update
        self.attached = false
    end

    return ball
end

local function newPlayerAttachedBall(scene)
    scene:group('balls'):add(makeBallAttachedTo(
        scene.objects.player,
        scene.objects.player.width/2, -10
    ))
end

local function shakeScreen(scene, duration, amplitude)
    duration = duration or .4
    amplitude = amplitude or 5
    local radius = {value = 0}
    local angle = 0
    scene.objects.timer:tween(.2*duration, radius, {value = amplitude}, 'in-quad', function()
        scene.objects.timer:tween(.8*duration, radius, {value = 0}, 'out-quad')
    end)
    scene.objects.timer:during(duration, function()
        angle = angle + lume.random(-math.pi, math.pi) * .2
        scene.camera:setPosition(lume.vector(angle, radius.value))
    end, function() scene.camera:setPosition(0, 0) end)
end


--------------------
-- Scene building --
--------------------

local S = SceneBuilder()

S:addGroup('borders', {init = function(group)
    -- top
    group:add(Border{
        x = -10, y = -10, width = w + 20, height = 10
    })
    -- right
    group:add(Border{
        x = w, y = 0, width = 10, height = h
    })
    -- left
    group:add(Border{
        x = -10, y = 0, width = 10, height = h
    })
end})

S:addGroup('bricks', {init = function(group)
    local level = require('entity.LevelBuilder').fromTable{
        area = {width = w, height = h/2},
        gridSize = {x = 24, y = 18},
        brickColor = {lume.color('#DBB36D', 255)},
        bricks = {
            {type = 'range', arguments = {fromX=9, toX=22, fromY=4, toY=12}},
        },
    }
    for _, brick in ipairs(level.bricks) do group:add(brick) end
end})

S:addObjectAs('player', {
    script = 'entity.Player',
    arguments = {
        x = w/2,
        y = h - 50,
        minx = 0, maxx = w,
        width = 100,
        height = 15,
        color = COLORS.player,
        controls = 'mouse',
    }
})

S:addGroup('balls', {z = -1})

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
        -- opacity fades to 0, brick rotates a bit
        local d = .3
        -- brick scale fades to 0
        scene.objects.timer:tween(d, brick, {scale=0}, 'in-back',
        function() brick:kill() end)
        shakeScreen(scene)
    end,
    collider = collisions.rectangleToCircle,
}

S:onCollisionBetween{
    object = 'player',
    group = 'balls',
    resolve = function(player, ball, scene)
        local res = collisions.resolveRectangleToMovingCircle(player, ball)
        ball.x = res.x
        -- bounce according to position on paddle
        ball.angle = -math.pi * (1 - (ball.x - (player.x-20))/(player.width+40))

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
        shakeScreen(scene)
    end,
    collider = collisions.rectangleToCircle,
}

S:addUpdateAction(function(scene)
    for _, ball in scene:group('balls'):each() do
        if ball.y > h then
            ball:kill()
            newPlayerAttachedBall(scene)
        end
    end
end)

S:addObjectAs('launch_ball_trigger', {
    script = 'core.KeyTrigger',
    arguments = {
        key = 'space',
        action = function()
            for _, ball in S.scene:group('balls'):each() do
                if ball.attached then ball:detach() end
            end
        end
    }
})

S:addCallback('enter', function(scene)
    love.graphics.setBackgroundColor(unpack(COLORS.background))

    -- make the bricks tween in the screen
    for _, brick in scene:group('bricks'):each() do
        local y = brick.y
        brick.y = y - h
        scene.objects.timer:tween(lume.random(.4, .8), brick, {y = y}, 'out-quad', function()
            brick.y = y
        end)
    end

    newPlayerAttachedBall(scene)
end)

return S
