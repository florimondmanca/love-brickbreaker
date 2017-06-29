-- main.lua
local gamestate = require 'lib.gamestate'

require 'core.SoundManager'

math.randomseed(os.time())

function love.load()
    gamestate.registerEvents()
    gamestate.switch(require('scenes/game'):build())
end
