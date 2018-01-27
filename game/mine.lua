local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local EnergyTransmitter = require "energytransmitter"
local Mine = class("Mine", EnergyTransmitter)
local messages = require "messages"
local resources = require "resources"

Mine.static.energy_cost = 0.9 -- per second
Mine.static.max_energy = Mine.energy_cost * 5
Mine.static.mineral_cost = 600
Mine.static.produce_speed = 2 -- per second
Mine.static.mine_pack = 5
Mine.static.image = love.graphics.newImage('mine.png')
Mine.static.needed_resource =  resources.type.METAL

function Mine:initialize(eventBus, posx, posy)
    EnergyTransmitter.initialize(self)
    self.eventBus = eventBus
    self.position = {x = posx, y = posy}
    self.energy = 0
    self.active = false
    self.generated = 0
end

function Mine:drawOverlay(camera)
    love.graphics.push()
    love.graphics.setColor(193, 70, 30, 255)
    love.graphics.setBlendMode('alpha')
    drawCentered(Mine.image, self.position.x, self.position.y)
    
    drawEnergyBar(self.position.x, self.position.y, self.energy / Mine.max_energy, Mine.energy_cost / Mine.max_energy)
    love.graphics.pop()
end

function Mine:update(dt)
    local usage = dt * Mine.energy_cost
    if self.energy > usage then
        if self.energy > 0.25 * Mine.max_energy then
            self.energy = self.energy - usage
            self.generated = self.generated + dt * Mine.produce_speed
        else
            self.energy = self.energy - usage / 2
            self.generated = self.generated + dt * Mine.produce_speed / 2
        end
        self.active = true
    else
        self.active = false
    end

    local packs = math.floor(self.generated / Mine.mine_pack)
    if packs > 0 then
        local minerals = packs * Mine.mine_pack
        self.generated = self.generated - minerals
        self.eventBus:dispatch(messages.minerals_produced(minerals))
    end
end

function Mine:receive()
    self.energy = math.min(self.energy + 1, Mine.max_energy)
end

function Mine:potential()
    return 0
end

return Mine
