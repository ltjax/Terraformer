local class = require "middleclass"
local Powerline = class "Powerline"

function Powerline:initialize(startBuilding, endBuilding)
    self.time = 0
    self.start = startBuilding.position
    self.stop = endBuilding.position
end

function Powerline:draw()
    love.graphics.push()
    love.graphics.setColor(60+120*self.time, 100+120*self.time, 10)
    love.graphics.line(self.start.x, self.start.y, self.stop.x, self.stop.y)
    love.graphics.pop()
end

function Powerline:update(dt)
    self.time = math.modf(self.time + 0.1)
end

return Powerline
