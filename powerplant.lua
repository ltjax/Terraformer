local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local EnergyTransmitter = require 'EnergyTransmitter'
local Powerplant = class("Powerplant", EnergyTransmitter)

Powerplant.mineral_cost = 400
Powerplant.energy_produced_per_step = 50

function Powerplant:initialize(_, x, y)
    EnergyTransmitter.initialize(self)
    self.position = {x = x, y = y}
    self.connections = {}
end

function Powerplant:draw(camera)
    love.graphics.push()
    love.graphics.setColor(255, 255, 0)
    love.graphics.circle("fill", self.position.x, self.position.y, 0.5)
    love.graphics.pop()
    camera:drawText(mathhelpers.percentagestring(self:potential()), self.position.x, self.position.y)
end

function Powerplant:potential()
    return 1
end

function Powerplant:output()
    return Powerplant.energy_produced_per_step
end

return Powerplant
