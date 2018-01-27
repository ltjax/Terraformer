local class = require 'middleclass'
local Grid = class 'Grid'

local function keyFor(x, y)
    return tostring(x).."-"..tostring(y)
end

function Grid:initialize()
    self.table = {}
end

function Grid:get(x, y)
    return self.table[keyFor(x, y)]
end

function Grid:set(x, y, value)
    self.table[keyFor(x, y)] = value
end

return Grid
