local lume = require 'lib.lume'

local function checkGeom(geom)
    assert(geom.width, 'geometry requires number width')
    assert(geom.height, 'geometry requires number height')
end

local function checkMatrixSize(matrix, size)
    for i = 1, size do
        assert(matrix[i], 'matrix of size ' .. size .. ' misses line i=' .. i)
        for j = 1, size do
            assert(matrix[i][j], 'matrix of size ' .. size .. ' misses column j=' .. j .. 'at line i=' .. i)
        end
    end
end

local function parse(filename, geom)
    checkGeom(geom)

    local raw = require(filename)

    local matrix = lume.map(lume.split(raw.map, '\n'), function(line)
        return lume.split(line, ',')
    end)
    checkMatrixSize(matrix, raw.size)

    geom.marginX = geom.marginX or 0
    geom.marginY = geom.marginY or 0
    geom.brickWidth = (geom.width - 2*geom.marginX) / raw.size
    geom.brickHeight = (geom.height - 2*geom.marginY) / raw.size

    local coords = {}
    for i = 1, raw.size do
        for j = 1, raw.size do
            if matrix[j][i] == 'b' then
                lume.push(coords, {
                    x = geom.marginX + (i-1) * geom.brickWidth,
                    y = geom.marginY + (j-1) * geom.brickHeight,
                    width = geom.brickWidth,
                    height = geom.brickHeight,
                })
            end
        end
    end

    return {
        size = raw.size,
        coords = coords
    }
end

return {parse = parse}
