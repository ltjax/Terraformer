local class = require "middleclass"
local mathhelpers = require "mathhelpers"
local EnergyTransmitter = require 'energytransmitter'

local TerraFormer = class("TerraFormer", EnergyTransmitter)
local messages = require "messages"

TerraFormer.static.energy_cost = 0.7 -- per second
TerraFormer.static.max_energy = TerraFormer.energy_cost * 10
TerraFormer.static.segments = 100
TerraFormer.static.mineral_cost = 100
TerraFormer.static.shield_radius_increase = 0.5 -- per second
TerraFormer.static.shield_radius_min = 2
TerraFormer.static.shield_radius_max = 8
TerraFormer.static.image = love.graphics.newImage('terraformer.png')
TerraFormer.static.noise_texture = love.graphics.newImage('fractal_noise.png')
TerraFormer.noise_texture:setWrap("repeat", "repeat")

function TerraFormer:initialize(eventBus, posx, posy)
    EnergyTransmitter.initialize(self)
    self.position = {x = posx, y = posy }
    self.energy = 0
    self.active = false
    self.generated = 0
    self.active_radius = TerraFormer.shield_radius_min
    self.eventBus = eventBus

    local fragSrc =  [[
        uniform vec2 gridCenter;
        uniform vec2 camPosition;
        uniform float camZoom;
        uniform float maxRadius;
        uniform vec2 windowSize;
        uniform sampler2D perlin;

        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec2 gridFrag = gl_FragCoord.xy / camZoom + camPosition;    
            vec4 noise = Texel(perlin, vec2(gridFrag * 0.45));
            float opacity = smoothstep(maxRadius, maxRadius - 8, length(gridFrag - gridCenter));
            return vec4(color.rgb, step(0.5, noise.r * 0.45 + opacity));
        }
    ]]
 
    local vertexSrc = [[
        vec4 position( mat4 transform_projection, vec4 vertex_position )
        {   
            vec4 clipspace = transform_projection * vertex_position;
            clipspace.y *= -1.0;
            return clipspace;
        }
    ]]

    self.shader = love.graphics.newShader(fragSrc, vertexSrc);
    self.shader:send("gridCenter", { self.position.x, self.position.y })
end

function TerraFormer:drawOverlay(camera)
    local x, y = self.position.x, self.position.y
    love.graphics.push()
    love.graphics.setColor(180, 255, 180, 255)
    love.graphics.setBlendMode('alpha')
    drawCentered(TerraFormer.image, x, y)
    drawEnergyBar(self.position.x, self.position.y, self.energy / TerraFormer.max_energy, TerraFormer.energy_cost / TerraFormer.max_energy)

  love.graphics.pop();
  --camera:drawText(string.format("Energy: %.1f", self.energy), x, y)
end

function TerraFormer:drawBackground(camera)
    if not self.active then
        return
    end
    self.shader:send("camPosition", { camera.position.x, camera.position.y })
    self.shader:send("camZoom", camera.zoom )
    self.shader:send("maxRadius", self.active_radius)
    self.shader:send("perlin", TerraFormer.static.noise_texture)

    love.graphics.getBlendMode("alpha")
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
        if self.active_radius ~= TerraFormer.shield_radius_max then
            self.active_radius = math.min(TerraFormer.shield_radius_max, self.active_radius + TerraFormer.shield_radius_increase * dt)
            self.eventBus:dispatch(messages.radiusChanged(self))
        end
    else
        if self.active_radius ~= TerraFormer.shield_radius_min then
            self.active_radius = math.max(TerraFormer.shield_radius_min, self.active_radius - TerraFormer.shield_radius_increase * dt)
            if self.active_radius <= TerraFormer.shield_radius_min then
                self.active = false
            end
            self.eventBus:dispatch(messages.radiusChanged(self))
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
