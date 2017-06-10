return function(x, y, width, height)
    local brick = {
        x = x,
        y = y,
        width = width,
        height = height,
        color = {255, 255, 255, 255}
    }

    function brick:draw()
        love.graphics.setColor(unpack(self.color))
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end

    function brick:setColor(r, g, b, a)
        self.color = {r, g, b, a}
    end

    return brick
end
