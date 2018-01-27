local class = require "middleclass"

local Powerline = class "Powerline"

Powerline.static.max_energy = 40

function Powerline:initialize(startBuilding, endBuilding)
    self.time = 0
    self.a = startBuilding
    self.a:connect(self)
    self.b = endBuilding
    self.b:connect(self)
    self.saturation = 0
end

function Powerline:draw()
    local c = math.sin(self.time)
    c = c * c
    c = c * self.saturation
    local p0 = self.a.position
    local p1 = self.b.position
    love.graphics.push()
    love.graphics.setColor(200*c+50, 160*c+50, 30*c+10)
    love.graphics.line(p0.x, p0.y, p1.x, p1.y)
    love.graphics.pop()
end

function Powerline:update(dt)
    self.time = self.time + dt
    while self.time > math.pi*2 do
      self.time = self.time - math.pi*2
    end
end

function Powerline:otherFor(connector)
    if connector == self.a then
        return self.b
    end
    return self.a
end

function Powerline:doesTransmitFrom(connector)
    return self:otherFor(connector):potential() < connector:potential()
end

function Powerline:transmitFrom(connector, energy)
    energy = math.min(Powerline.max_energy, energy)
    self.saturation = energy / Powerline.max_energy
    local other = self:otherFor(connector)
    if other.receive then
        connector:take(energy)
        other:receive(energy)
    end
end

return Powerline
