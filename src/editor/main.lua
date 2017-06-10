local lume = require 'lib.lume'
local settings = require 'settings'

love.graphics.setBackgroundColor(200, 200, 200)


-- constants
local w, h = love.graphics.getDimensions()


---------------
-- Variables --
---------------

local player = {
    x = 0, y = 0, w = 0, h = 0,
    color = settings.playerColor
}
local bricks = {}
local toolbar = {
    x = 0, w = w,
    y = h - 30, h = 30
}

-- if span mode is activated (true), a span of bricks will be drawn on screen
local spanMode = false
local spanBegin

-- the brick being drawn
local drawing

-- toast for small message printing
local singleToast = {
    x = w/2,
    y = 50,
    text = love.graphics.newText(love.graphics.getFont(), ''),
    color = {100, 150, 100},
    duration = 2,  -- seconds
    time = 0,
    alive = false,
}

function singleToast:awake() self.alive = true end

function singleToast:setText(text)
    self.text:set(text)
end

function singleToast:update(dt)
    if not self.alive then return end
    self.time = self.time + dt
    if self.time > self.duration then
        self.time = 0
        self.alive = false
    end
end

function singleToast:draw()
    if not self.alive then return end
    love.graphics.setColor(self.color)
    love.graphics.draw(self.text, self.x - self.text:getWidth()/2, self.y)
end


---------------------------
-- Functions definitions --
---------------------------

local function snapToGrid(x, y) return
    math.floor(x / settings.brickWidth) * settings.brickWidth,
    math.floor(y / settings.brickHeight) * settings.brickHeight
end

local function gridCoords(x, y) return
    math.floor(x / settings.brickWidth),
    math.floor(y / settings.brickHeight)
end

local function newDrawing(x, y)
    drawing = {
        x = x or 0, y = y or 0, w = settings.brickWidth, h = settings.brickHeight,
        color = settings.brickColor,
    }
end

local function saveDrawing()
    lume.push(bricks, drawing)
    print('new_brick: (' .. drawing.x .. ', ' .. drawing.y .. ')')
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

--- makes a new toast pop on the screen
local function newToast(msg, duration)
    if duration then singleToast.duration = duration end
    singleToast:setText(msg)
    singleToast:awake()
end

local function export()
    local success = love.filesystem.write('level.txt', lume.serialize(bricks))
    if success then
        print('export:success')
        newToast('Exported level')
    else
        print('export:fail')
    end
end


----------------------
-- Love2D callbacks --
----------------------

function love.load()
    newDrawing()
end

function love.update(dt)
    singleToast:update(dt)
end

function love.draw()
    -- player bar
    love.graphics.setColor(unpack(player.color))
    drawRectangle(player)

    -- existing bricks
    for _, brick in ipairs(bricks) do
        love.graphics.setColor(unpack(brick.color))
        drawRectangle(brick)
    end

    -- drawing rectangle
    love.graphics.setColor(255, 255, 255, 128)
    drawRectangle(drawing)
    if spanMode then
        if spanBegin then
            for _, spanBrick in ipairs(getSpanBricks(drawing.x, drawing.y, spanBegin.x, spanBegin.y)) do
                drawRectangle(spanBrick)
            end
        end
    end

    -- toolbar
    love.graphics.setColor(170, 170, 170)
    drawRectangle(toolbar)

    singleToast:draw()
end

function love.mousemoved(x, y)
    drawing.x, drawing.y = snapToGrid(x, y)
end

function love.keypressed(key)
    if key == 'rshift' or key == 'lshift' then
        spanMode = true
        print('span_mode:on')
    end
end

function love.keyreleased(key)
    if key == 'rshift' or key == 'lshift' then
        spanMode = false
        spanBegin = nil
        print('span_mode:off')
    end
    if key == 'return' then export() end
end

function love.mousereleased(_, _, button)
    if button == 1 then
        local xd, yd = drawing.x, drawing.y
        if spanMode then
            if spanBegin then
                for _, spanBrick in ipairs(getSpanBricks(xd, yd, spanBegin.x, spanBegin.y)) do
                    newDrawing(spanBrick.x, spanBrick.y)
                    saveDrawing()
                end
                newDrawing(xd, yd)
                spanBegin = nil
            else
                spanBegin = lume.clone(drawing)
                saveDrawing()
                newDrawing(xd, yd)
            end
        else
            saveDrawing()
            newDrawing(xd, yd)
        end
    end
end
