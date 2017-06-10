local asserts = require 'lib.asserts'
local lume = require 'lib.lume'

-----------------------
-- Utility functions --
-----------------------

local utils = {}


--- returns the coordinates of a grid of bricks
-- @tparam int nX the number of bricks on X axis (number of columns)
-- @tparam int nY the number of bricks on Y axis (number of rows)
-- @tparam number brickWidth
-- @tparam number brickHeight
function utils.makeBarGrid(nX, nY, brickWidth, brickHeight)
    asserts.required(nX, 'nX')
    asserts.required(nY, 'nY')
    asserts.required(brickWidth, 'brickWidth')
    asserts.required(brickHeight, 'brickHeight')

    local coords = {}
    local x0 = love.graphics.getWidth() / 2 - nX * brickWidth / 2
    local y0 = 2 * brickHeight
    local dx = brickWidth
    local dy = brickHeight
    for i = 0, nX - 1 do
        for j = 0, nY - 1 do
            local x = x0 + i * dx
            local y = y0 + j * dy
            lume.push(coords, {x=x, y=y, width=brickWidth, height=brickHeight})
        end
    end
    return coords
end

function utils.Rect(x, y, w, h)
    local rect = {
        x = x or 0,
        y = y or 0,
        w = w or 0,
        h = h or 0
    }
    return rect
end

return utils
