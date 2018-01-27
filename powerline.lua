local class = require "middleclass"
local Powerline = class "Powerline"

function Powerline:initialize(startBuilding, endBuilding)
    self.time = 0
    self.start = startBuilding.position
    self.stop = endBuilding.position
end

function Powerline:draw()
  local c = math.sin(self.time)
  c = c * c
  love.graphics.push()
  love.graphics.setColor(255*c, 255*c, 255*c)
  love.graphics.line(self.start.x, self.start.y, self.stop.x, self.stop.y)
  love.graphics.pop()
end

function Powerline:update(dt)
    self.time = self.time + dt
    while self.time > math.pi*2 do
      self.time = self.time - math.pi*2
    end
end

return Powerline
