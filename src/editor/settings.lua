local lume = require 'lib.lume'

local function make(code)
    local r, g, b, a = lume.color(code, 256)
    return {r, g, b, a}
end

return {
    colors = {
        player = make('#4DFFF3'),
        brick = make('#503D3F'),
        background = make('#503D3F'),
        canvasBackground = make('#D7F2BA'),
        labelText = make('#FFFFFF'),
        textBoxBackground = make('#539987'),
        textBoxText = make('#FFFFFF'),
        btnBackground = make('#539987'),
        btnText = make('#FFFFFF'),
    },
    brickDims = {
        w = 50,
        h = 20
    },
}
