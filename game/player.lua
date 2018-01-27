local class = require "middleclass"
local Player = class "Player"
local messages = require "messages"
local constants = require 'constants'

function Player:initialize(eventBus)
    eventBus:subscribe(messages.MINERALS_PRODUCED, function (message)
        self.minerals = self.minerals + message.added_minerals
        self.mineralBump = math.min(1.0, self.mineralBump + 0.3)
    end)
    self.minerals = 50
    self.mineralBump = 0.0
end

function Player:draw()
    local s = 1.0 + self.mineralBump * self.mineralBump * 0.8
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(constants.BIG_FONT)
    love.graphics.print(tostring(self.minerals), 10, 10, 0, s, s)
    love.graphics.setFont(constants.NORMAL_FONT)
    love.graphics.print("Minerals", 10, 40)
    love.graphics.pop()
end

function Player:update(dt)
    if self.mineralBump > 0 then
        self.mineralBump = math.max(0, self.mineralBump - 0.7*dt)
    end
end

function Player:has_minerals(num_minerals)
    return num_minerals <= self.minerals
end

function Player:use_minerals(num_minerals)
    if not self:has_minerals(num_minerals) then
        return false
    end
    self.minerals = self.minerals - num_minerals
    return true
end

return Player
