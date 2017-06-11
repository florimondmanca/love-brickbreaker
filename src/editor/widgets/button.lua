local colors = require('settings').colors

-- button with attached action triggered on click

local button = {
    x = 0,
    y = 0,
    w = 80,
    h = 40,
    pad = 5,
    text = '',
    colors = {
        background = colors.btnBackground,
        text = colors.btnText,
    },
    action = function() end,
}

function button:setText(text, fit)
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

function button:draw()
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.print(self.text, self.x + self.pad, self.y + self.pad)
end

function button:mousepressed(x, y, btn)
    if btn == 1 then
        if x >= self.x
        and x <= self.x + self.w
        and y >= self.y
        and y <= self.y + self.h then
            self.action()
            print('button:clicked')
        end
    end
end

return button
