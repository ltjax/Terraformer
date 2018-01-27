local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local EnergyTransmitter = require 'energytransmitter'
local TerraFormer = class("TerraFormer", EnergyTransmitter)
local messages = require "messages"

TerraFormer.static.max_energy = 40
TerraFormer.static.energy_cost = 0.4 -- per second
TerraFormer.static.segments = 100
TerraFormer.static.mineral_cost = 100
TerraFormer.static.shield_radius_increase = 0.5 -- per second
TerraFormer.static.shield_radius_min = 2
TerraFormer.static.shield_radius_max = 8
TerraFormer.static.image = love.graphics.newImage('terraformer.png')

function TerraFormer:initialize(_, posx, posy)
    EnergyTransmitter.initialize(self)
    self.position = {x = posx, y = posy }
    self.energy = 0
    self.active = false
    self.generated = 0
    self.active_radius = TerraFormer.shield_radius_min
end

function TerraFormer:drawOverlay(camera)
  love.graphics.push()
    love.graphics.setColor(180, 255, 180, 255)
    love.graphics.setBlendMode('alpha')
    drawCentered(TerraFormer.image, self.position.x, self.position.y)
    if self.active and self.active_radius < TerraFormer.shield_radius_max then
        love.graphics.setLineWidth(0.05);
        love.graphics.setColor(0, 255, 0, 150)
        love.graphics.circle("line", self.position.x, self.position.y, self.active_radius, TerraFormer.segments)
    end
  love.graphics.pop();
  local p = (self.active_radius - TerraFormer.shield_radius_min) / (TerraFormer.shield_radius_max - TerraFormer.shield_radius_min)
  camera:drawText(mathhelpers.percentagestring(p), self.position.x, self.position.y)
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
        self.active_radius = math.min(TerraFormer.shield_radius_max, self.active_radius + TerraFormer.shield_radius_increase * dt)
    else
        self.active_radius = math.max(TerraFormer.shield_radius_min, self.active_radius - TerraFormer.shield_radius_increase * dt)
        if self.active_radius <= TerraFormer.shield_radius_min then
            self.active = false
        end
    end
end

function TerraFormer:receive()
    self.energy = math.min(self.energy + 1, TerraFormer.max_energy)
end

function TerraFormer:potential()
    return 0
end

return TerraFormer
