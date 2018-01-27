local Entities = require 'Entities'
local Player = require "player"
local TerraFormer = require "terraformer"
local Node = require "node"
local PowerPlant = require "powerplant"
local EventBus = require 'EventBus'
local Camera = require 'camera'
local Grid = require 'Grid'
local PowerLine = require 'powerline'
local HudBuilding = require 'hud_building'
local mathhelpers = require 'mathhelpers'

local InGameState = {}

function InGameState:init()
    self.eventBus = EventBus:new()
    self.entities = Entities:new()
    self.player = Player:new(self.eventBus);
    self.grid = Grid:new()
    self.camera = Camera:new();
    self.hud_building = HudBuilding:new(self)
    self.accumulated = 0.0

    self.drag = {
        mode= 'off',
    }
    self:insertEntity(self.player)
    self:insertEntity(self.camera)
    self:insertEntity(self.hud_building)

    local terraformer = TerraFormer:new(self.eventBus, 7, 14)
    local node = Node:new(nil, 5, 10)
    local powerPlant = PowerPlant:new(nil, 2, 11)
    self:insertBuilding(terraformer)
    self:insertBuilding(node)
    self:insertBuilding(powerPlant)
    
    self:connectLine(terraformer, node)
    self:connectLine(powerPlant, node)
end

function InGameState:insertEntity(entity)
    self.entities:add(entity)
end

function InGameState:insertBuilding(building)
  self:insertEntity(building)
  self.grid:set(building.position.x, building.position.y, building)
end

function InGameState:createBuilding(building_class, x, y)
    if self:canBuild(x, y) and self.player:use_minerals(building_class.mineral_cost) then
        local building = building_class:new(self.eventBus, x, y)
        self:insertBuilding(building)
        self.camera:addTrauma(0.2)
        return building
    end
    return nil
end

function InGameState:canBuild(x, y)
    if self.grid:get(x, y) ~= nil then
        return false
    end
    if not self:terraformed(x, y) then
        return false
    end
    return true
end

function InGameState:terraformed(x, y)
    for _, v in pairs(self.entities.list) do
        if v:isInstanceOf(TerraFormer) then
            local dist = mathhelpers.distance(v.position, {x=x, y=y})
            if dist <= v.active_radius then
                return true
            end
        end
    end
    return false
end


function InGameState:draw()
    local h = love.graphics:getHeight()
    self.camera:setup()

    -- Scale everything up
    love.graphics.setBlendMode("replace")
    
    self.entities:callAll('drawBackground')

    -- Draw simple grid
    love.graphics.setBlendMode("alpha")
    local m=200
    for i=0,m do
        love.graphics.setColor(32,32,32, 64)
        love.graphics.setLineWidth(1 / 25)
        love.graphics.line(i,0,i,m)
        love.graphics.line(0,i,m,i)
    end
    
    self.entities:callAll('draw', self.camera)
    self.camera:drawTop()

    if self.drag.start and self.drag.stop then
        love.graphics.line(self.drag.start.x, self.drag.start.y, self.drag.stop.x, self.drag.stop.y)
    end

    love.graphics.push()
    love.graphics.origin()
    local x,y = love.mouse.getPosition()
    love.graphics.print(tostring(x) .. "|" .. tostring(h - y), 0, 0)
    love.graphics.pop()
end

function InGameState:update(dt)
    local frameTime = 1/30
    self.entities:callAll('update', dt)
    self.accumulated = self.accumulated + dt
    while self.accumulated > frameTime do
        self.accumulated = self.accumulated - frameTime
        self.entities:callAll('step', frameTime)
    end
end

function InGameState:mousepressed(x, y, button)
    if self.hud_building:mousepressed(x, y, button) then
        return
    end
    
    if button ~= 1 then
        return
    end
    
    local x, y = self:mouseGridPosition()
    if self.grid:get(x, y)~=nil then
        self.drag.start = {x=x, y=y}
        self.drag.stop = nil
        self.drag.mode = 'line'
    end
end

function InGameState:dragTarget()
    local x, y = self:unroundedMousePosition()
    local d = mathhelpers.difference(self.drag.start, {x=x, y=y})
    local max_length = 7
    local length = mathhelpers.length(d)
    if length > max_length then
        d = mathhelpers.scale(d, max_length/length)
    end
    local e = mathhelpers.add(d, self.drag.start)
    return self:roundPosition(e.x, e.y)
end


function InGameState:mousemoved()
    if self.drag.mode == 'line' then
        local x, y = self:dragTarget()
        self.drag.stop = {x=x, y=y}
    end
end

function InGameState:mousereleased()
    if self.drag.mode == 'line' then
        local x, y = self:dragTarget()
        local endTarget = self.grid:get(x, y)
        if endTarget~=nil then
            local startTarget = self.grid:get(self.drag.start.x, self.drag.start.y)
            self:connectLine(startTarget, endTarget)
        end
        self.drag.start = nil
        self.drag.mode = 'off'
    end
end

function InGameState:connectLine(startTarget, endTarget)
    self:insertEntity(PowerLine:new(startTarget, endTarget))
end

function InGameState:unroundedMousePosition()
    local mousex, mousey = love.mouse.getPosition()
    local posx, posy = mousex / self.camera.zoom, (love.graphics:getHeight() - mousey) / self.camera.zoom;
    return posx + self.camera.position.x, posy + self.camera.position.y
end

function InGameState:roundPosition(x, y)
    local posx = math.floor( x + 0.5 )
    local posy = math.floor( y + 0.5 )
    return posx, posy
end

function InGameState:mouseGridPosition()
    return self:roundPosition(self:unroundedMousePosition())
end

function InGameState:keypressed(key)
    local posx, posy = self:mouseGridPosition()

    if key == "escape" then
        love.event.quit()
    end
    if key == "space" then
        -- IDEA: evaluate nodes in decending potential order
        self.entities:callAll('step')
    end
end

function InGameState:wheelmoved(x, y)
    self.camera:wheelmoved(x, y)
end

return InGameState
