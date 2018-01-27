local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local EnergyTransmitter = require 'energytransmitter'
local TerraFormer = class("TerraFormer", EnergyTransmitter)
local messages = require "messages"

TerraFormer.static.max_energy = 40
TerraFormer.static.energy_cost = 0.4 -- per second
TerraFormer.static.segments = 100
TerraFormer.static.mineral_cost = 100

function TerraFormer:initialize(eventBus, posx, posy)
    EnergyTransmitter.initialize(self)
    self.eventBus = eventBus
    self.position = {x = posx, y = posy }
    self.energy = 0
    self.active = false
    self.generated = 0
    self.active_radius = 15.0
end

function TerraFormer:draw(camera)
  love.graphics.push()
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.circle("fill", self.position.x, self.position.y, 0.5)
  love.graphics.pop();
  camera:drawText(mathhelpers.percentagestring(self:potential()), self.position.x, self.position.y)
end

function TerraFormer:drawBackground()
    if not self.active then
        return
    end

    love.graphics.push()
        love.graphics.setColor(0, 255, 0, 50)
        love.graphics.circle("fill", self.position.x, self.position.y, self.active_radius, TerraFormer.segments)
    love.graphics.pop()
end

function TerraFormer:update(dt)
    local usage = dt * TerraFormer.energy_cost
    if self.energy > usage then
        self.energy = self.energy - usage
        self.active = true
        self.generated = self.generated + dt
    else
        self.active = false
    end
    
    while self.generated > 1 do
        self.generated = self.generated - 1
        self.eventBus:dispatch(messages.minerals_produced(5))
    end
end

function TerraFormer:receive()
    self.energy = math.min(self.energy + 1, TerraFormer.max_energy)
end

function TerraFormer:potential()
    return 0
end

return TerraFormer
