local class = require "middleclass"
local Player = class "Player"

function Player:initialize()
    self.minerals = 50
end

function Player:use_minerals(num_minerals)
    if self.minerals < num_minerals then
        return false
    end
    self.minerals = self.minerals - num_minerals
    return true
end

return Player
