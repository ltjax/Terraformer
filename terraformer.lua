local class = require "middleclass"
local TerraFormer = class "TerraFormer"
local messages = require "messages"

function TerraFormer:initialize(eventBus, posx, posy)
    self.eventBus = eventBus
    self.translation = {x = posx, y = posy}
end

function TerraFormer:draw()
  love.graphics.push()
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.circle("fill", self.translation.x, self.translation.y, 0.5)
  love.graphics.pop();
end

function TerraFormer:drawBackground()
  love.graphics.push()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(0, 255, 0, 127)
    love.graphics.circle("fill", self.translation.x, self.translation.y, 15.0, TerraFormer.segments)

    love.graphics.setBlendMode("add")
    love.graphics.setLineWidth(4)
    love.graphics.circle("line", self.translation.x, self.translation.y, 15.0, TerraFormer.segments)
  love.graphics.pop()
end

function TerraFormer:step()
    self.eventBus:dispatch(messages.minerals_produced(5))
end

TerraFormer.energy_cost = 10
TerraFormer.segments = 100

return TerraFormer
