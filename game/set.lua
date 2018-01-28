local class = require 'middleclass'

local Set = class 'Set'
function Set:initialize()
    self.count = 0
    self.table = {}
end

function Set:contains(element)
    return self.table[element]~=nil
end

function Set:insert(element)
    if self:contains(element) then
        return
    end
    self.count = self.count + 1
    self.table[element] = true
end

function Set:remove(element)
    if self:contains(element) then
        self.table[element] = nil
        self.count = self.count - 1
    end
end

function Set:size()
    return self.count
end

return Set
