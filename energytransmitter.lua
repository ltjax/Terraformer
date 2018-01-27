local class = require "middleclass"
local EnergyTransmitter = class "EnergyTransmitter"

function EnergyTransmitter:initialize()
    self.connections = {}
end

function EnergyTransmitter:output()
    return 0
end

function EnergyTransmitter:receive()
end

function EnergyTransmitter:take()
end

function EnergyTransmitter:potential()
    return 0
end

function EnergyTransmitter:step()
    local output = self:output()
    if output <= 0 then
        return
    end
    
    local lower = {}
    for _, connection in ipairs(self.connections) do
        if connection:doesTransmitFrom(self) then
            table.insert(lower, connection)
        end
    end

    if #lower == 0 then
        return
    end

    table.sort(lower, function(a, b) return a:otherFor(self):potential() < b:otherFor(self):potential() end)
    
    while output > 0 do
        for _, connection in ipairs(lower) do
            -- put one energy quant on the line
            connection:transmitFrom(self)
            output = output - 1
            if output <= 0 then
                break
            end
        end
    end
    
end

function EnergyTransmitter:connect(powerLine)
    table.insert(self.connections, powerLine)
end

return EnergyTransmitter
