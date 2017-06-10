local lume = require 'lib.lume'
local settings = require 'settings'

local canvas = {}

local player = {
    x = 0, y = 0, w = 0, h = 0,
    color = settings.playerColor
}
local bricks = {}

-- if span mode is activated (true), a span of bricks will be drawn on screen
local spanMode = false
local spanBegin

-- the brick being drawn
local drawing

function canvas:newDrawing(x, y)
    drawing = {
        x = x or 0, y = y or 0, w = settings.brickWidth, h = settings.brickHeight,
        color = settings.brickColor,
    }
end

function canvas:saveDrawing()
    lume.push(bricks, drawing)
    print('new_brick: (' .. drawing.x .. ', ' .. drawing.y .. ')')
end

local function snapToGrid(x, y) return
    math.floor(x / settings.brickWidth) * settings.brickWidth,
    math.floor(y / settings.brickHeight) * settings.brickHeight
end

local function gridCoords(x, y) return
    math.floor(x / settings.brickWidth),
    math.floor(y / settings.brickHeight)
end

local function drawRectangle(rect)
    love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
end

local function getSpanBricks(xd, yd, xb, yb)
    local spanBricks = {}

    local drawingXg, drawingYg = gridCoords(xd, yd)
    local beginXg, beginYg = gridCoords(xb, yb)

    local xgi, ygi = drawingXg, drawingYg
    local xgf, ygf = beginXg, beginYg
    if xgi > xgf then xgi, xgf = xgf, xgi end
    if ygi > ygf then ygi, ygf = ygf, ygi end

    for i = xgi, xgf do
        for j = ygi, ygf do
            if i ~= beginXg or j ~= beginYg then
                lume.push(spanBricks, {
                    x = i * settings.brickWidth,
                    y = j * settings.brickHeight,
                    w = settings.brickWidth,
                    h = settings.brickHeight
                })
            end
        end
    end

    return spanBricks
end

function canvas:export()
    local success = love.filesystem.write('level.txt', lume.serialize(bricks))
    if success then
        print('export:success')
    else
        print('export:fail')
    end
end


function canvas:load()
    self:newDrawing()
end

function canvas:draw()
    -- player bar
    love.graphics.setColor(unpack(player.color))
    drawRectangle(player)

    -- existing bricks
    for _, brick in ipairs(bricks) do
        love.graphics.setColor(unpack(brick.color))
        drawRectangle(brick)
    end

    -- brick(s) being drawn
    love.graphics.setColor(255, 255, 255, 128)
    drawRectangle(drawing)
    if spanMode then
        if spanBegin then
            for _, spanBrick in ipairs(getSpanBricks(drawing.x, drawing.y, spanBegin.x, spanBegin.y)) do
                drawRectangle(spanBrick)
            end
        end
    end
end

function canvas:mousemoved(x, y)
    drawing.x, drawing.y = snapToGrid(x, y)
end

function canvas:keypressed(key)
    if key == 'rshift' or key == 'lshift' then
        spanMode = true
        print('span_mode:on')
    end
end

function canvas:keyreleased(key)
    if key == 'rshift' or key == 'lshift' then
        spanMode = false
        spanBegin = nil
        print('span_mode:off')
    end
    if key == 'return' then self:export() end
end

function canvas:mousereleased(_, _, button)
    if button == 1 then
        local xd, yd = drawing.x, drawing.y
        if spanMode then
            if spanBegin then
                for _, spanBrick in ipairs(getSpanBricks(xd, yd, spanBegin.x, spanBegin.y)) do
                    self:newDrawing(spanBrick.x, spanBrick.y)
                    self:saveDrawing()
                end
                self:newDrawing(xd, yd)
                spanBegin = nil
            else
                spanBegin = lume.clone(drawing)
                self:saveDrawing()
                self:newDrawing(xd, yd)
            end
        else
            self:saveDrawing()
            self:newDrawing(xd, yd)
        end
    end
end

return canvas
