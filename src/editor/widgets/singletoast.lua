local w, _ = love.graphics.getDimensions()

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

--- makes a new toast pop on the screen
function singleToast.new(msg, duration)
    if duration then singleToast.duration = duration end
    singleToast:setText(msg)
    singleToast:awake()
end

return singleToast
