local lume = require 'lib.lume'

local collisions = {}

function collisions.circleToCircle(a, b)
    return (b.x - a.x)^2 + (b.y - a.y)^2 <= (a.radius + b.radius)^2
end

local rectGeom = {
    topleft = function(r) return {x = r.x, y = r.y} end,
    topright = function(r) return {x = r.x + r.width, y = r.y} end,
    bottomright = function(r) return {x = r.x + r.width, y = r.y + r.height} end,
    bottomleft = function(r) return {x = r.x, y = r.y + r.height} end,
}

function rectGeom.vertices(r)
    return {rectGeom.topleft(r), rectGeom.topright(r), rectGeom.bottomright(r), rectGeom.bottomleft(r)}
end

function rectGeom.edges(r)
    return {
        top = {rectGeom.topleft(r), rectGeom.topright(r)},
        right = {rectGeom.topright(r), rectGeom.bottomright(r)},
        bottom = {rectGeom.bottomright(r), rectGeom.bottomleft(r)},
        left = {rectGeom.bottomleft(r), rectGeom.topleft(r)}
    }
end

----- tests if a circle and an edge intersect
local function intersectingCircleAndEdge(cir, edge)
    local a, b = unpack(edge)
    local ab = {x = b.x - a.x, y = b.y - a.y}  -- direction a -> b
    -- compute projection of circle center on the segment ab
    local acdotab = (cir.x - a.x) * ab.x + (cir.y - a.y) * ab.y
    local t = acdotab / lume.length(ab.x, ab.y, true)
    local d = {x = a.x + t * ab.x, y = a.y + t * ab.y}
    return lume.all({
        lume.distance(cir.x, cir.y, d.x, d.y, true) <= cir.radius^2,
        (d.x - a.x) * ab.x + (d.y - a.y) * ab.y > 0,
        (d.x - b.x) * ab.x + (d.y - b.y) * ab.y < 0
    })
end

function collisions.rectangleToCircle(rect, cir)
    return lume.any(rectGeom.edges(rect), function(edge)
        return intersectingCircleAndEdge(cir, edge)
    end)
end

local function rectanglesOverlap(rect1, rect2)
    local ox = (
        math.min(rect1.x + rect1.width, rect2.x + rect2.width)
        - math.max(rect1.x, rect2.x)
    )
    local oy = (
        math.min(rect1.y + rect1.height, rect2.y + rect2.height)
        - math.max(rect1.y, rect2.y)
    )
    if rect1.x > rect2.x then ox = -ox end
    if rect1.y > rect2.y then oy = -oy end
    return {x=ox, y=oy}
end

local function circleBoundingBox(cir)
    return {
        x = cir.x - .7071067812 * cir.radius,
        y = cir.y - .7071067812 * cir.radius,
        width = 2*cir.radius,
        height = 2*cir.radius
    }
end

function collisions.resolveRectangleToMovingRectangle(fixed, mobile)
    local overlap = rectanglesOverlap(fixed, mobile)
    if math.abs(overlap.x) < math.abs(overlap.y) then
        overlap = {x=overlap.x, y=0}
    else
        overlap = {x=0, y=overlap.y}
    end
    return {x = mobile.x + overlap.x, y = mobile.y + overlap.y}
end

function collisions.resolveRectangleToMovingCircle(rect, cir)
    local res = collisions.resolveRectangleToMovingRectangle(rect, circleBoundingBox(cir))
    res.x = res.x + .7071067812 * cir.radius
    res.y = res.y + .7071067812 * cir.radius

    local vx, vy = cir.vx, cir.vy

    if (vx > 0 and res.x < rect.x)
    or (vx < 0 and res.x > rect.x + rect.width) then
        vx = -vx
    end

    if (vy > 0 and res.y < rect.y)
    or (vy < 0 and res.y > rect.y + rect.height) then
        vy = -vy
    end

    return {vx = vx, vy = vy, x = res.x, y = res.y}
end


return collisions
