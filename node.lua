local class = require "middleclass"
local Node = class "Node"

function Node:initialize(_, posx, posy)
  self.position = {x = posx, y = posy}
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
      self.edge_length,
      self.edge_length
    )

  love.graphics.pop();
end

Node.mineral_cost = 20
Node.energy_cost = 10
Node.edge_length = 0.25

return Node
