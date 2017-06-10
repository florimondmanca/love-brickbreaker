-- main.lua

local class = require 'lib.class'
local lume = require 'lib.lume'
local actions = require 'actions'
local asserts = require 'lib.asserts'


local colors = {
    background = {lume.color('rgb(50, 55, 75)', 256)},
    star = {
        center = {lume.color('rgb(250, 250, 240)', 256)},
        halo = {lume.color('rgb(100, 110, 150)', 256)},
        edge = {lume.color('rgb(100, 110, 150)', 256)},
    },
}

love.graphics.setBackgroundColor(colors.background)

-- constants
local w, h = love.graphics.getDimensions()

---------------
-- Utilities --
---------------

---- a material point with position and velocity that can be under forces
local Point = class('Point')

function Point:initialize(x, y, vx, vy, m)
    if type(x) == 'table' then
        y = x.y
        vx = x.vx
        vy = x.vy
        m = x.m
        x = x.x
    end
    self.x = x or 0
    self.y = y or 0
    self.vx = vx or 0
    self.vy = vy or 0
    self.fx = 0
    self.fy = 0
    self.m = m or 1
    self.invm = 1/self.m
    self.energy = {pot = 0, kin = 1/2*self.m*(self.vx^2 + self.vy^2)}
    self.energy.total = self.energy.pot + self.energy.kin
end

function Point:difference(other)
    return {
        x = self.x - other.x,
        y = self.y - other.y
    }
end

function Point:addForce(fx, fy)
    self.fx = self.fx + fx
    self.fy = self.fy + fy
end

function Point:update(dt)
    -- compute energies
    self.energy.pot = self.energy.pot - (self.fx * self.vx + self.fy * self.vy) * dt
    self.energy.kin = 1/2 * self.m * (self.vx^2 + self.vy^2)
    self.energy.total = self.energy.pot + self.energy.kin
    -- update velocity and position
    self.vx = self.vx + self.invm * self.fx * dt
    self.vy = self.vy + self.invm * self.fy * dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    -- reset forces
    self.fx = 0
    self.fy = 0
end

function Point:stickToMouse(dt)
    local mx, my = love.mouse.getPosition()
    self.vx = (mx - self.x) / dt
    self.vy = (my - self.y) / dt
    self.x, self.y = mx, my
end

-----------
-- Graph --
-----------

local function nodeExists(nodes, i)
    return lume.find(nodes, i)
end

local function addNode(nodes, edges, i)
    if not nodeExists(nodes, i) then
        lume.push(nodes, i)
        edges[i] = {}
    end
end

local function edgeExists(edges, i, j)
    return lume.find(edges[i], j) or lume.find(edges[j], i)
end

local function addEdge(edges, i, j)
    lume.push(edges[i], j)
    lume.push(edges[j], i)
end

local function edgePairs(edges)
    local mPairs = {}

    for i, e in pairs(edges) do
        for _, j in ipairs(e) do
            if true then
                table.insert(mPairs, {i, j})
            end
        end
    end

    return mPairs
end

local function iterEdgePairs(edges)
    print('\niter')
    local thePairs = edgePairs(edges)
    local i = 0
    return function()
        i = i + 1
        local p = thePairs[i]
        if p then
            return p[1], p[2]
        else return nil end
    end
end

local function addRandomEdges(nodes, edges, numEdges)
    local num = #(edgePairs(edges))
    print(num)
    while num < numEdges do
        local i, j = lume.randomchoice(nodes), lume.randomchoice(nodes)
        if i ~= j and not edgeExists(edges, i, j) then
            addEdge(edges, i, j)
            num = num + 1
        end
    end
end

local function generateRandomConnectedGraphEdges(nodes, edges, numEdges)
    asserts.required(nodes, 'nodes')
    asserts.required(numEdges, 'numEdges')
    -- verify that numEdges is not too big
    local maxNumEdges = #nodes * (#nodes - 1) / 2
    assert(numEdges < maxNumEdges, 'Cannot make more than ' .. maxNumEdges .. ' edges for ' .. #nodes .. ' nodes')

    local vertices = lume.set(nodes)
    local visited = {}

    local current = lume.randomchoice(vertices)
    lume.remove(vertices, current)
    lume.push(visited, current)

    while #vertices > 0 do
        local neighbor = lume.randomchoice(vertices)
        if not lume.find(visited, neighbor) then
            addEdge(edges, current, neighbor)
            lume.remove(vertices, neighbor)
            lume.push(visited, neighbor)
        end
        current = neighbor
    end

    addRandomEdges(nodes, edges, numEdges)

    return edges
end

local function hieholzer(vertices, edges)
    local current = lume.randomchoice(vertices)

end

local Graph = class('Graph')

----- initializes a graph
-- a graph has N vertices 1, 2, ... N and edges connecting them,
-- represented as (vi, vj) pairs of vertices.
function Graph:initialize()
    self.vertices = {}
    self.edges = {}
end


-------------------
-- Constellation --
-------------------


local Constellation = Graph:subclass('Constellation')

function Constellation:initialize(numStars, edgeDensity)
    Graph.initialize(self)
    asserts.required(numStars, 'numStars')
    edgeDensity = edgeDensity or 0.5
    local padding = 50
    self.attachedStar = nil
    -- create material points
    self.points = {}
    for i = 1, numStars do
        addNode(self.vertices, self.edges, i)
        self.points[i] = Point{
            x = lume.random(padding, w - padding),
            y = lume.random(padding, h - padding)
        }
    end
    -- create edges
    self.edges = generateRandomConnectedGraphEdges(
        self.vertices,
        self.edges,
        math.floor(lume.lerp(
            numStars - 1,
            numStars*(numStars-1) / 2,
            edgeDensity
        ))
    )
    -- attach actions
    self.actions = {}
    -- gravity
    lume.push(self.actions, actions.Gravity{g=10, radius=100})
    -- attraction between connected stars
    for left, right in iterEdgePairs(self.edges) do
        lume.push(self.actions, actions.Bind{left=left, right=right, intensity=10})
    end
    -- repulsion
    lume.push(self.actions, actions.Repulse{radius=100})
    -- dampening
    for i = 1, #self.vertices do
        lume.push(self.actions, actions.Dampen{index=i, intensity=10})
    end
end

function Constellation:update(dt)
    -- apply actions
    for _, action in ipairs(self.actions) do
        action:apply(self)
    end
    -- integrate
    for _, point in ipairs(self.points) do
        point:update(dt)
    end
    if self.attachedStar then
        self.points[self.attachedStar]:stickToMouse(dt)
    end
    -- self:outputEnergies()
end

function Constellation:draw()
    -- draw the contesllation edges
    for left, right in iterEdgePairs(self.edges) do
        local pa, pb = self.points[left], self.points[right]
        love.graphics.setLineWidth(1)
        love.graphics.setColor(colors.star.edge)
        love.graphics.line(pa.x, pa.y, pb.x, pb.y)
    end
    -- draw the stars
    for _, point in ipairs(self.points) do
        -- draw star halo
        love.graphics.setColor(colors.background)
        love.graphics.circle('fill', point.x, point.y, 10, 20)
        -- draw star center
        love.graphics.setLineWidth(1)
        love.graphics.setColor(colors.star.center)
        love.graphics.circle('fill', point.x, point.y, 4, 20)
        love.graphics.circle('line', point.x, point.y, 4)
    end
end

function Constellation:mousepressed(x, y, button)
    if button == 1 then
        for i, point in ipairs(self.points) do
            if lume.distance(point.x, point.y, x, y) < 10 then
                self.attachedStar = i
            end
        end
    end
end

function Constellation:mousereleased(_, _, button)
    if button == 1 then self.attachedStar = nil end
end

function Constellation:outputEnergies()
    local ep = lume.sum(self.points, function(p) return p.energy.pot end)
    local ec = lume.sum(self.points, function(p) return p.energy.kin end)
    print('Ep:', ep)
    print('Ec:', ec)
    print('Em:', ep + ec)
end

---------------
-- Main loop --
---------------

local objects = {}


local function toObjects(fname, ...)
    for _, object in ipairs(objects) do
        if object[fname] then object[fname](object, ...) end
    end
end

function love.load()
    lume.push(objects, Constellation(10, 0.17))
end

function love.update(dt)
    toObjects('update', dt)
end

function love.draw()
    toObjects('draw')
end

function love.keypressed(key)
    toObjects('keypressed', key)
end

function love.mousepressed(x, y, button)
    toObjects('mousepressed', x, y, button)
end

function love.mousereleased(x, y, button)
    toObjects('mousereleased', x, y, button)
end
