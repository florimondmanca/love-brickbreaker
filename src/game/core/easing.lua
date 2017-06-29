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
        return easing.outQuad (t * 2, b, c / 2, d)
    else
        return easing.inQuad((t * 2) - d, b + c / 2, c / 2, d)
    end
end

function easing.inExp(t, b, c, d)
    if t == 0 then return b
    else return  c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001 end
end

function easing.outExp(t, b, c, d)
    if t == d then return b + c
    else return c * 1.001 * (-math.pow(2, -10 * t / d) + 1) + b end
end

return easing
