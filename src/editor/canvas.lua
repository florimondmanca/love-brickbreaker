local lume = require 'lib.lume'
local settings = require 'settings'


local w, h = love.graphics.getDimensions()

local canvas = {
    x = 0,
    y = 0,
    w = w,
    h = h - 50,
    colors = {
        background = {60, 60, 60}
    },
    active = true,
    current = nil,
    spanBegin = nil,
    spanning = false,
    bricks = {},
}

function canvas:newDrawing(x, y)
    self.drawing = {
        x = x or 0, y = y or 0, w = settings.brickWidth, h = settings.brickHeight,
        color = settings.brickColor,
    }
end

function canvas:saveDrawing()
    lume.push(self.bricks, self.drawing)
    print('new_brick: (' .. self.drawing.x .. ', ' .. self.drawing.y .. ')')
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
    if not self.active then return end
    local success = love.filesystem.write('level.txt', lume.serialize(self.bricks))
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
    love.graphics.setColor(unpack(self.colors.background))
    drawRectangle(self)
    -- existing bricks
    for _, brick in ipairs(self.bricks) do
        love.graphics.setColor(unpack(brick.color))
        drawRectangle(brick)
    end

    -- brick(s) being drawn
    love.graphics.setColor(255, 255, 255, 128)
    drawRectangle(self.drawing)
    if self.spanning then
        if self.spanBegin then
            for _, spanBrick in ipairs(
            getSpanBricks(self.drawing.x, self.drawing.y, self.spanBegin.x, self.spanBegin.y)) do
                drawRectangle(spanBrick)
            end
        end
    end
end

function canvas:mousemoved(x, y)
    self.drawing.x, self.drawing.y = snapToGrid(x, y)
    self.drawing.x = lume.clamp(self.drawing.x, self.x, self.x + self.w - self.drawing.w)
    self.drawing.y = lume.clamp(self.drawing.y, self.y, self.y + self.h - self.drawing.h)
end

function canvas:keypressed(key)
    if key == 'rshift' or key == 'lshift' then
        self.spanning = true
        print('span_mode:on')
    end
end

function canvas:keyreleased(key)
    if key == 'rshift' or key == 'lshift' then
        self.spanning = false
        self.spanBegin = nil
        print('span_mode:off')
    end
    if key == 'return' then self:export() end
end

function canvas:mousepressed(x, y, button)
    if button == 1 then
        if x >= self.x
        and x <= self.x + self.w
        and y >= self.y
        and y <= self.y + self.h then
            self.active = true
            print 'canvas:active'
        elseif self.active then
            self.active = false
            print 'canvas:inactive'
        end
    end
end

function canvas:mousereleased(_, _, button)
    if button == 1 and self.active then
        local xd, yd = self.drawing.x, self.drawing.y
        if self.spanning then
            if self.spanBegin then
                for _, spanBrick in ipairs(getSpanBricks(xd, yd, self.spanBegin.x, self.spanBegin.y)) do
                    self:newDrawing(spanBrick.x, spanBrick.y)
                    self:saveDrawing()
                end
                self:newDrawing(xd, yd)
                self.spanBegin = nil
            else
                self.spanBegin = lume.clone(self.drawing)
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
