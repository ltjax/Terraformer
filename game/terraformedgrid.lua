local class = require 'middleclass'
local messages = require 'messages'
local Grid = require 'grid'
local mathhelpers = require 'mathhelpers'
local TerraFormer = require 'terraformer'

function isInside(terraformer, x, y)
    local dist = mathhelpers.distance(terraformer.position, {x=x, y=y})
    return dist <= terraformer.active_radius
end

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


local TerraformedGrid = class 'TerraformedGrid'

function TerraformedGrid:initialize(eventBus)
    self.eventBus = eventBus
    self.grid = Grid:new()
    self.totalTerraformed = 0
    eventBus:subscribe(messages.RADIUS_CHANGED, function(message)
            self:radiusChanged(message.terraformer)
        end)
end

function TerraformedGrid:radiusChanged(terraformer)
    local mx, my = terraformer.position.x, terraformer.position.y
    local r = TerraFormer.shield_radius_max;
    local ax, ay = mx - r, my - r
    local bx, by = mx + r, my + r
    
    local change = 0
    
    for y=ay, by do
        for x=ax, bx do
            local inside = isInside(terraformer, x, y)
            local e = self.grid:get(x, y)
            if e==nil then
                e = Set:new()
            end
            
            local contains = e:contains(terraformer)
            if inside ~= contains then
                if inside then
                    e:insert(terraformer)
                    if e:size() == 1 then
                        change = change + 1
                    end
                else
                    e:remove(terraformer)
                    if e:size() == 0 then
                        change = change - 1
                    end
                end
            end
            
            self.grid:set(x, y, e)
        end
    end
    
    if change ~= 0 then
        self.totalTerraformed = self.totalTerraformed + change
        self.eventBus:dispatch(messages.totalTerraformedChanged(self.totalTerraformed, change))
    end
end

return TerraformedGrid
