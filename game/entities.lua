local class = require 'middleclass'

local Entities = class 'Entities'

function Entities:initialize()
  self.list = {}
end

function Entities:add(entity)
  table.insert(self.list, entity)
end

function Entities:remove(entity)
    for i, v in pairs(self.list) do
        if v == entity then
            table.remove(self.list, i)
            break
        end
    end
end

function Entities:findIf(callback)
    for _, entity in ipairs(self.list) do
        if callback(entity) then
            return entity
        end
    end
    return nil
end

function Entities:forEach(callback)
    for _, entity in ipairs(self.list) do
        callback(entity)
    end
end

function Entities:callAll(functionName, ...)
  for _, entity in ipairs(self.list) do
    local f = entity[functionName]
    if f~=nil then
      f(entity, ...)
    end
  end
end

return Entities
