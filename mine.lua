local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local EnergyTransmitter = require "energytransmitter"
local Mine = class("Mine", EnergyTransmitter)
local messages = require "messages"

Mine.static.max_energy = 40
Mine.static.energy_cost = 0.4 -- per second
Mine.static.mineral_cost = 600
Mine.static.produce_speed = 2 -- per second
Mine.static.mine_pack = 5
Mine.static.image = love.graphics.newImage('mine.png')

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
    love.graphics.setColor(193, 43, 5, 255)
    love.graphics.setBlendMode('alpha')
    drawCentered(Mine.image, self.position.x, self.position.y)
    love.graphics.pop()
end

function Mine:update(dt)
    local usage = dt * Mine.energy_cost
    if self.energy > usage then
        if self.energy > 0.75 * Mine.max_energy then
            self.energy = self.energy - 4 * usage
            self.generated = self.generated + dt * 4 * Mine.produce_speed
        elseif self.energy > 0.25 * Mine.max_energy then
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
