local class = require 'middleclass'

local Entities = class 'Entities'

function Entities:initialize()
  self.list = {}
end

function Entities:add(entity)
  table.insert(self.list, entity)
end

function Entities:callAll(functionName)
  for _, entity in ipairs(self.list) do
    local f = entity[functionName]
    if f~=nil then
      f(entity)
    end
  end
end

return Entities
