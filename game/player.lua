local class = require "middleclass"
local Player = class "Player"
local messages = require "messages"
local constants = require 'constants'

function Player:initialize(eventBus)
    eventBus:subscribe(messages.MINERALS_PRODUCED, function (message)
        self.minerals = self.minerals + message.added_minerals
        self.mineralBump = math.min(1.0, self.mineralBump + 0.3)
    end)
    eventBus:subscribe(messages.TOTAL_TERRAFORMED_CHANGED, function (message)
            self.score = message.total
            if message.delta > 0 then
                self.scoreBump = math.min(1.0, self.scoreBump + 0.3)
            end
        end)
        
    self.minerals = 50
    self.mineralBump = 0.0
    self.score = 0
    self.scoreBump = 0.0
end

function Player:draw()
    local s = 1.0 + self.mineralBump * self.mineralBump * 0.8
    local t = 1.0 + self.scoreBump * self.scoreBump * 0.8
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(constants.BIG_FONT)
    love.graphics.print(tostring(self.minerals), 10, 10, 0, s, s)
    love.graphics.setFont(constants.NORMAL_FONT)
    love.graphics.print("Minerals", 10, 40)
    love.graphics.setFont(constants.BIG_FONT)
    local x = love.graphics.getWidth() - 200
    love.graphics.print(tostring(self.score), x, 10, 0, t, t)
    love.graphics.setFont(constants.NORMAL_FONT)
    love.graphics.print("Score", x, 40)
    love.graphics.pop()
end

function Player:update(dt)
    if self.mineralBump > 0 then
        self.mineralBump = math.max(0, self.mineralBump - 0.7*dt)
    end
    if self.scoreBump > 0 then
        self.scoreBump = math.max(0, self.scoreBump - 0.7*dt)
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
