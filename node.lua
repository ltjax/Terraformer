local class = require "middleclass"

local EnergyTransmitter = require 'EnergyTransmitter'
local Node = class("Node", EnergyTransmitter)

Node.static.max_energy_storage = 50
Node.static.max_energy_output = 25
Node.static.energy_cost = 10
Node.static.edge_length = 0.25

function Node:initialize(posx, posy)
    EnergyTransmitter.initialize(self)
    self.position = {x = posx, y = posy }
    self.energy = 0
end

function Node:draw()
  local half_edge_len = Node.edge_length * 0.5;
  love.graphics.push()
    love.graphics.setLineWidth(0.2)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.rectangle(
      "line",
      self.position.x - half_edge_len,
      self.position.y - half_edge_len,
      Node.edge_length,
      Node.edge_length
    )

  love.graphics.pop();
end

function Node:receive(energy)
    self.energy = math.min(Node.max_energy_storage, energy)
end

function Node:take(energy)
    self.energy = math.max(self.energy - energy, 0.0)
end

function Node:output()
    return math.min(Node.max_energy_output, self.energy)
end

function Node:potential()
    return self.energy / Node.max_energy_storage
end


return Node
