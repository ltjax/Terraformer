local class = require "middleclass"
local Powerplant = class "Player"

Powerplant.mineral_cost = 400
Powerplant.energy_produced_per_step = 50

function Powerplant:initialize(x, y)
    self.position = {x = x, y = y}
end

function Powerplant:draw()
    love.graphics.push()
    love.graphics.setColor(255, 255, 0)
    love.graphics.circle("fill", self.position.x, self.position.y, 2.0)
    love.graphics.pop()
end

function Powerplant:step()
end

return Powerplant
