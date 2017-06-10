local w, h = love.graphics.getDimensions()

return function()
    local player = {
        x = w/2 - 50,
        y = h-40,
        width = 100,
        height = 20
    }

    function player:update()
        -- move with keyboard
        if love.keyboard.isDown('left') then self.x = self.x - 10 end
        if love.keyboard.isDown('right') then self.x = self.x + 10 end
    end

    function player:draw()
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end

    return player
end
