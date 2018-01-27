local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local EnergyTransmitter = require 'EnergyTransmitter'
local Powerplant = class("Powerplant", EnergyTransmitter)

Powerplant.mineral_cost = 400
Powerplant.energy_produced_per_second = 1.4

function Powerplant:initialize(_, x, y)
    EnergyTransmitter.initialize(self)
    self.position = {x = x, y = y}
    self.connections = {}
    self.energyAccumulation = 0
end

function Powerplant:draw(camera)
    love.graphics.push()
    love.graphics.setColor(255, 255, 0)
    love.graphics.circle("fill", self.position.x, self.position.y, 0.5)
    love.graphics.pop()
    camera:drawText(mathhelpers.percentagestring(self:potential()), self.position.x, self.position.y)
end

function Powerplant:update(dt)
    self.energyAccumulation = self.energyAccumulation + dt*Powerplant.energy_produced_per_second
end

function Powerplant:potential()
    return 1
end

function Powerplant:output()
    local integral, fractional = math.modf(self.energyAccumulation)
    return integral
end

function Powerplant:take()
    self.energyAccumulation = self.energyAccumulation -1
end

return Powerplant
