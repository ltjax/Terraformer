local class = require "middleclass"
local Player = class "Player"
local messages = require "messages"

function Player:initialize(eventBus)
    eventBus:subscribe(messages.MINERALS_PRODUCED, function (message)
        self.minerals = self.minerals + message.added_minerals
    end)
    self.minerals = 50
end

function Player:draw()
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("Minerals: " .. tostring(self.minerals), 10, 10)
    love.graphics.pop()
end

function Player:use_minerals(num_minerals)
    if self.minerals < num_minerals then
        return false
    end
    self.minerals = self.minerals - num_minerals
    return true
end

return Player
