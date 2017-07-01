local class = require 'lib.class'
local lume = require 'lib.lume'
local Brick = require 'entity.Brick'


local function _buildBrickSingle(level, arguments)
    assert(arguments.x and arguments.y, 'brickSingle requires x and y')
    level:addBrick(Brick{
        x = arguments.x * level.brickWidth, y = arguments.y * level.brickHeight,
        width = level.brickWidth, height = level.brickHeight,
        color = level.brickColor,
    })
end

local function _buildBrickRange(level, arguments)
    assert(arguments.fromX, 'brickRange requires fromX')
    assert(arguments.toX, 'brickRange requires toX')
    assert(arguments.fromY, 'brickRange requires fromY')
    assert(arguments.toY, 'brickRange requires toY')
    for x = arguments.fromX, arguments.toX do
        for y = arguments.fromY, arguments.toY do
            _buildBrickSingle(level, {x=x, y=y})
        end
    end
end

local brickBuilders = {
    single = _buildBrickSingle,
    range = _buildBrickRange,
}

local function buildBricks(level, bricksTable)
    if not brickBuilders[bricksTable.type] then
        error('Unknown brick builder type: ' .. tostring(bricksTable.type))
    end
    brickBuilders[bricksTable.type](level, bricksTable.arguments)
end

local Level = class()

function Level:init(t)
    t = t or {}
    assert(type(t.areaWidth) == 'number', 'Level requires number areaWidth')
    assert(type(t.areaHeight) == 'number', 'Level requires number areaHeight')
    assert(type(t.gridSizeX) == 'number', 'Level requires number brickWidth')
    assert(type(t.gridSizeY) == 'number', 'Level requires number brickHeight')
    assert(type(t.brickColor) == 'table', 'Level requires table brickColor')
    self.areaWidth = t.areaWidth
    self.areaHeight = t.areaHeight
    self.gridSizeX = t.gridSizeX
    self.gridSizeY = t.gridSizeY
    self.brickColor = t.brickColor
    self.brickWidth = self.areaWidth / self.gridSizeX
    self.brickHeight = self.areaHeight / self.gridSizeY
    self.bricks = {}
end

function Level:addBrick(...)
    for _, brick in ipairs{...} do lume.push(self.bricks, brick) end
end

function Level.fromTable(source)
    local level = Level{
        areaWidth = source.area.width,
        areaHeight = source.area.height,
        gridSizeX = source.gridSize.x,
        gridSizeY = source.gridSize.y,
        brickColor = source.brickColor,
    }
    for _, bricksTable in ipairs(source.bricks) do
        buildBricks(level, bricksTable)
    end
    return level
end

function Level.fromFile(filename)
    local source = require(filename)
    return Level.fromTable(source)
end

return Level
