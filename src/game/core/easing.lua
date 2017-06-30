local sin = math.sin
local asin = math.asin
local pow = math.pow
local pi = math.pi
local abs = math.abs

local easing = {}

--[[
In the following:
- t = elapsed time
- b = begin
- c = change = ending - beginning
- d = duration
]]--

function easing.linear(t, b, c, d)
    return b + c * t/d
end


----------
-- Quad --
----------

function easing.inQuad(t, b, c, d)
    return b + c * (t/d)^2
end

function easing.outQuad(t, b, c, d)
    t = t / d
    return b - c * t * (t-2)
end

function easing.inOutQuad(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t^2 + b
    else
        return -c / 2 * ((t - 1) * (t - 3) - 1) + b
    end
end

function easing.outInQuad(t, b, c, d)
    if t < d / 2 then
        return easing.outQuad(t * 2, b, c / 2, d)
    else
        return easing.inQuad((t * 2) - d, b + c / 2, c / 2, d)
    end
end


-----------------
-- Exponential --
-----------------

function easing.inExp(t, b, c, d)
    if t == 0 then return b
    else return  c * pow(2, 10 * (t / d - 1)) + b - c * 0.001 end
end

function easing.outExp(t, b, c, d)
    if t == d then return b + c
    else return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b end
end


----------
-- Back --
----------

function easing.inBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    t = t / d
    return c * t * t * ((s + 1) * t - s) + b
end

function easing.outBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function easing.inOutBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    s = s * 1.525
    t = t / d * 2
    if t < 1 then
        return c / 2 * (t * t * ((s + 1) * t - s)) + b
    else
        t = t - 2
        return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
    end
end

function easing.outInBack(t, b, c, d, s)
    if t < d / 2 then
        return outBack(t * 2, b, c / 2, d, s)
    else
        return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
    end
end


return easing
