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

    local fragSrc =  [[
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(texture, texture_coords);
            vec4 c = color;
            
            if(length(texture_coords) > 0.5)
              c = vec4(1.0, 1.0, 0.0, 1.0);
            
            return vec4(gl_FragCoord.xy, 0.0, 1.0);
        }
    ]]
 
    local vertexSrc = [[
        vec4 position( mat4 transform_projection, vec4 vertex_position )
        {
            return transform_projection * vertex_position;
        }
    ]]

    self.shader = love.graphics.newShader(fragSrc, vertexSrc);

end

function TerraFormer:drawOverlay(camera)
    local x, y = self.position.x, self.position.y
    
    love.graphics.push()
    love.graphics.setColor(180, 255, 180, 255)
    love.graphics.setBlendMode('alpha')
    drawCentered(TerraFormer.image, x, y)

    if self.active and self.active_radius < TerraFormer.shield_radius_max then
        love.graphics.setLineWidth(0.05);
        love.graphics.setColor(0, 255, 0, 150)
        love.graphics.circle("line", self.position.x, self.position.y, self.active_radius, TerraFormer.segments)
    end
  love.graphics.pop();
  camera:drawText(string.format("Energy: %.1f", self.energy), x, y)
end

function TerraFormer:drawBackground()
    if not self.active then
        return
    end
    love.graphics.setShader(self.shader)
    love.graphics.push()
        love.graphics.setColor(0, 255, 0, 50)
        love.graphics.circle("fill", self.position.x, self.position.y, self.active_radius, TerraFormer.segments)
    love.graphics.pop()
    love.graphics.setShader()
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
