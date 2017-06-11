local utf8 = require 'utf8'
local colors = require('settings').colors

local w, h = love.graphics.getDimensions()

-- textbox for text input
local textBox = {
    x = 0,
    y = h - 50,
    w = w,
    h = 50,
    text = '',
    textObj = love.graphics.newText(love.graphics.getFont()),
    active = false,
    colors = {
        background = colors.textBoxBackground,
        text = colors.textBoxText,
    },
}

function textBox:getText() return self.text end

function textBox:setText(text)
    self.text = text
    self.textObj:set(text)
end

function textBox:clear()
    self:setText('')
end

function textBox:draw()
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.draw(self.textObj, self.x, self.y)
end

function textBox:mousepressed(x, y, button)
    if button == 1 then
        if x >= self.x
        and x <= self.x + self.w
        and y >= self.y
        and y <= self.y + self.h then
            self.active = true
            print('textbox:active')
        elseif self.active then
            self.active = false
            print('textbox:inactive')
        end
    end
end

function textBox:keypressed(key)
    if key == 'backspace' then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(self.text, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            self:setText(string.sub(self.text, 1, byteoffset - 1))
        end
    end
end

function textBox:textinput(text)
    if self.active then self:setText(self.text .. text) end
end

return textBox
