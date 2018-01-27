local class = require "middleclass"

local EnergyTransmitter = require 'energytransmitter'
local TerraFormer = class("TerraFormer", EnergyTransmitter)
local messages = require "messages"

TerraFormer.static.max_energy = 30
TerraFormer.static.energy_cost = 10
TerraFormer.static.segments = 100

function TerraFormer:initialize(eventBus, posx, posy)
    EnergyTransmitter.initialize(self)
    self.eventBus = eventBus
    self.position = {x = posx, y = posy }
    self.energy = 0
    self.active = false
end

function TerraFormer:draw()
  love.graphics.push()
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.circle("fill", self.position.x, self.position.y, 0.5)
  love.graphics.pop();
end

function TerraFormer:drawBackground()
    if not self.active then
        return
    end

    love.graphics.push()
        love.graphics.setColor(0, 255, 0, 127)
        love.graphics.circle("fill", self.position.x, self.position.y, 15.0, TerraFormer.segments)
    love.graphics.pop()
end

function TerraFormer:step()
    EnergyTransmitter.step(self)
    self.active = false
    if self.energy >= TerraFormer.energy_cost then
        self.active = true
        self.energy = self.energy - TerraFormer.energy_cost
        self.eventBus:dispatch(messages.minerals_produced(5))
    end
end

function TerraFormer:receive(energy)
    self.energy = math.min(self.energy + energy, TerraFormer.max_energy)
end

function TerraFormer:potential()
    return self.energy / TerraFormer.max_energy
end

return TerraFormer
