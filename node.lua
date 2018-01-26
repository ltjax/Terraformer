local class = require "middleclass"
local Node = class "Node"

function Node:initialize(posx, posy)
  self.translation = {x = posx, y = posy}
end

function Node:draw()
  local half_edge_len = Node.edge_length * 0.5;
  love.graphics.push()
    love.graphics.setLineWidth(0.2)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.rectangle(
      "line",
      self.translation.x - half_edge_len,
      self.translation.y - half_edge_len,
      self.edge_length,
      self.edge_length
    )

  love.graphics.pop();
end

Node.energy_cost = 10
Node.edge_length = 0.25

return Node
