local colors = require('settings').colors

-- simple text label

local label = {
    x = 0,
    y = 0,
    w = 100,
    h = 50,
    pad = 5,
    text = '',
    colors = {text = colors.labelText},
}

function label:setText(text, fit)
    fit = fit or {x=true, y=true}
    self.text = text
    if fit.x then
        self.w = love.graphics.getFont():getWidth(text) + 2*self.pad
    end
    if fit.y then
        self.h = love.graphics.getFont():getHeight(text) + 2*self.pad
    end
    return self
end

function label:draw()
    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.print(self.text, self.x + self.pad, self.y + self.pad)
end

return label
