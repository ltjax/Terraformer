local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local EnergyTransmitter = require 'EnergyTransmitter'
local Node = class("Node", EnergyTransmitter)

Node.static.max_energy_storage = 50
Node.static.max_energy_output = 20
Node.static.energy_cost = 10
Node.static.edge_length = 0.25
Node.static.mineral_cost = 20

function Node:initialize(_, posx, posy)
    EnergyTransmitter.initialize(self)
    self.position = {x = posx, y = posy }
    self.energy = 0
    self.average_potential = 0
end

function Node:draw(camera)
  local half_edge_len = Node.edge_length * 0.5;
  local p = self:potential()
  love.graphics.push()
    love.graphics.setLineWidth(0.2)
    love.graphics.setColor(255*p, 255*p, 0, 255)
    love.graphics.rectangle(
      "line",
      self.position.x - half_edge_len,
      self.position.y - half_edge_len,
      Node.edge_length,
      Node.edge_length
    )

  love.graphics.pop();
  camera:drawText(mathhelpers.percentagestring(self:potential()), self.position.x, self.position.y)
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
