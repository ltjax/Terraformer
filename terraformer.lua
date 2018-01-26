local class = require "middleclass"
local TerraFormer = class "TerraFormer"

function TerraFormer:initialize(posx, posy)
  self.translation = {x = posx, y = posy}
end

function TerraFormer:draw()
  love.graphics.push()
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.circle("fill", self.translation.x, self.translation.y, 2.0)
  love.graphics.pop();
end

function TerraFormer:drawBackground()
  love.graphics.push()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(0, 255, 0, 127)
    love.graphics.circle("fill", self.translation.x, self.translation.y, 15.0)

    love.graphics.setBlendMode("add")
    love.graphics.setLineWidth(4)
    love.graphics.circle("line", self.translation.x, self.translation.y, 15.0)
  love.graphics.pop()
end

TerraFormer.energy_cost = 10

return TerraFormer
