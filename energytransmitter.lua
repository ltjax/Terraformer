local class = require "middleclass"
local EnergyTransmitter = class "EnergyTransmitter"

function EnergyTransmitter:initialize()
    self.connections = {}
end

function EnergyTransmitter:output()
    return 0
end

function EnergyTransmitter:receive(energy)
end

function EnergyTransmitter:take(energy)
end

function EnergyTransmitter:potential()
    return 0
end

function EnergyTransmitter:step()
    local lower = {}
    for _, connection in ipairs(self.connections) do
        if connection:doesTransmitFrom(self) then
            table.insert(lower, connection)
        end
    end

    if #lower == 0 then
        return
    end

    local powerPerConnection = self:output() / #lower
    for _, connection in ipairs(lower) do
        connection:transmitFrom(self, powerPerConnection)
    end
end

function EnergyTransmitter:connect(powerLine)
    table.insert(self.connections, powerLine)
end

return EnergyTransmitter
