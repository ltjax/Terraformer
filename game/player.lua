local class = require "middleclass"
local Player = class "Player"
local messages = require "messages"
local constants = require 'constants'

function Player:initialize(eventBus, goals)
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
        
    self.minerals = 500
    self.mineralBump = 0.0
    self.score = 0
    self.scoreBump = 0.0
    self.goals = goals
    self.time = 0
    self.speedUp = 1
end

function Player:scaleTime(dt)
    return dt * self.speedUp
end

function Player:increaseSpeed()
    self.speedUp = self.speedUp * 2
end

function Player:decreaseSpeed()
    self.speedUp = self.speedUp * 0.5
end

function Player:drawHud()
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
    love.graphics.print("Hectare", x, 40)
    self:drawTime()
    love.graphics.pop()
end

function Player:drawTime()
    --love.graphics.setBlendMode("alpha")
    love.graphics.setFont(constants.BIG_FONT)
    love.graphics.setColor(255, 255, 255, 255)
    local timeString = string.format("%.1f", self.time)
    if self.speedUp ~= 1 then
        formatString = "%s (%.0fx)"
        if self.speedUp < 1 then
            formatString = "%s (%.2fx)"
        end
        
        timeString = string.format(formatString, timeString, self.speedUp)
    end
    
    local x = love.graphics.getWidth() / 2 - 100
    love.graphics.print(timeString, x, 10)
    
    love.graphics.setFont(constants.NORMAL_FONT)
    love.graphics.print("Seconds", x, 40)
end


function Player:update(dt)
    if self.mineralBump > 0 then
        self.mineralBump = math.max(0, self.mineralBump - 0.7*dt)
    end
    if self.scoreBump > 0 then
        self.scoreBump = math.max(0, self.scoreBump - 0.7*dt)
    end
    
    self.time = self.time + dt
    self:checkGoals()
end

function Player:checkGoals()
    if not self.goals then
        return
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
