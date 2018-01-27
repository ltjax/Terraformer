local class = require "middleclass"
local Grid = class "Grid"

local function keyFor(x, y)
    return tostring(x) .. "-" .. tostring(y)
end

function Grid:initialize()
    self.table = {}
end

function Grid:get(x, y)
    return self.table[keyFor(x, y)]
end

function Grid:set(x, y, value)
    assert(x ~= nil and y ~= nil)
    self.table[keyFor(x, y)] = value
end

function Grid:iterate(func)
    for _, v in pairs(self.table) do
        func(v)
    end
end

return Grid
