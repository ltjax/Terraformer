local class = require "middleclass"
local mathhelpers = require "mathhelpers"

local Powerline = class "Powerline"

Powerline.static.max_energy = 40

function Powerline:initialize(startBuilding, endBuilding)
    self.time = 0
    self.a = startBuilding
    self.a:connect(self)
    self.toA = {}
    self.b = endBuilding
    self.b:connect(self)
    self.toB = {}
    self.length = mathhelpers.magnitude(self.a.position, self.b.position)
    self.image = love.graphics.newImage('particle.png')
end

function Powerline:drawLane(lane, from, to)
    local dx = to.x - from.x
    local dy = to.y - from.y
    local s = 0.025
    
    for _, v in ipairs(lane) do
        local px = from.x + v*dx
        local py = from.y + v*dy
        love.graphics.draw(self.image, px, py, 0, s, s, 16, 16)
        --love.graphics.circle('fill', px, py, 0.3)
    end
end

function Powerline:draw(camera)
    local c = math.sin(self.time)
    c = c * c
    local p0 = self.a.position
    local p1 = self.b.position
    love.graphics.push()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(150*c+100, 160*c+50, 30*c+10)
    love.graphics.setLineWidth(1/25)
    love.graphics.line(p0.x, p0.y, p1.x, p1.y)
    
    love.graphics.setBlendMode("add")
    love.graphics.setColor(255, 255, 255, 255)
    self:drawLane(self.toA, self.b.position, self.a.position)
    self:drawLane(self.toB, self.a.position, self.b.position)
    love.graphics.setBlendMode("replace")
    
    love.graphics.pop()
    local middle = {x = (p0.x + p1.x) * 0.5, y = (p0.y + p1.y) * 0.5}
    camera:drawText(tostring(#self.toA + #self.toB), middle.x, middle.y)
end

function Powerline:update(dt)
    self.time = self.time + dt
    while self.time > math.pi*2 do
      self.time = self.time - math.pi*2
    end
    local move = 10*dt/self.length
    self:updateLane(move, self.a, self.toA)
    self:updateLane(move, self.b, self.toB)
end

function Powerline:updateLane(move, target, targetLane)
    local dst = 1
    for i=1,#targetLane do
        local newValue = targetLane[i] + move
        if newValue > 1.0 then
            target:receive()
        else
            targetLane[dst] = newValue
            dst = dst + 1
        end
    end
    for i=dst,#targetLane do
        targetLane[i] = nil
    end
end

function Powerline:otherFor(connector)
    if connector == self.a then
        return self.b, self.toB
    end
    return self.a, self.toA
end

function Powerline:doesTransmitFrom(connector)
    return self:otherFor(connector):potential() < connector:potential()
end

function Powerline:transmitFrom(connector)
    local other, targetLane = self:otherFor(connector)
    connector:take(energy)
    table.insert(targetLane, 0.0)
end

return Powerline
