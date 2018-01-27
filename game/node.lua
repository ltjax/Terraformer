local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local EnergyTransmitter = require 'EnergyTransmitter'
local Node = class("Node", EnergyTransmitter)

Node.static.max_energy_storage = 50
Node.static.max_energy_output = 20
Node.static.energy_cost = 10
Node.static.edge_length = 0.25
Node.static.mineral_cost = 20
Node.static.image = love.graphics.newImage('node.png')

function Node:initialize(_, posx, posy)
    EnergyTransmitter.initialize(self)
    self.position = {x = posx, y = posy }
    self.energy = 0
    self.average_potential = 0
end

function Node:drawOverlay(camera)
  local half_edge_len = Node.edge_length * 0.5;
  local p = self:potential()
  love.graphics.push()
    love.graphics.setLineWidth(0.2)
    love.graphics.setColor(100*p+150,100*p+150, 150, 255)
    love.graphics.setBlendMode('alpha')
    drawCentered(Node.image, self.position.x, self.position.y)
  love.graphics.pop();
end

function Node:update(dt)
    if #self.connections <= 0 then
        return
    end
    
    local a = 0
    for _, connection in ipairs(self.connections) do
        a = a + connection:otherFor(self):potential()
    end
    self.average_potential = a / #self.connections
end


function Node:receive()
    self.energy = math.min(Node.max_energy_storage, self.energy+1)
end

function Node:take()
    self.energy = math.max(self.energy - 1, 0)
end

function Node:output()
    return math.min(Node.max_energy_output, self.energy)
end

function Node:potential()
    return self.average_potential
end


return Node
