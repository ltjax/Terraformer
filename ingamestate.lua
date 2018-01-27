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

local InGameState = {}

function InGameState:init()
    self.eventBus = EventBus:new()
    self.entities = Entities:new()
    self.player = Player:new(self.eventBus);
    self.grid = Grid:new()
    self.camera = Camera:new();
    self.hud_building = HudBuilding:new(self)

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
    if self.grid:get(x, y) == nil and self.player:use_minerals(building_class.mineral_cost) then
        local building = building_class:new(self.eventBus, x, y)
        self:insertBuilding(building)
        self.camera:addTrauma(0.2)
        return building
    end
    return nil
end

function InGameState:draw()
    local h = love.graphics:getHeight()
    self.camera:setup()

    -- Scale everything up
    love.graphics.setBlendMode("replace")
    
    self.entities:callAll('drawBackground')

    -- Draw simple grid
    local m=200
    for i=0,m do
        love.graphics.setColor(32,32,32)
        love.graphics.setLineWidth(1 / 25)
        love.graphics.line(i,0,i,m)
        love.graphics.line(0,i,m,i)
    end
    
    self.entities:callAll('draw')

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
    self.entities:callAll('update', dt)
end

function InGameState:mousepressed(x, y, button)
    if self.hud_building:mousepressed(x, y, button) then
        return
    end
    local x, y = self:mouseGridPosition()
    if self.grid:get(x, y)~=nil then
        self.drag.start = {x=x, y=y}
        self.drag.mode = 'line'
    end
end

function InGameState:mousemoved()
    if self.drag.mode == 'line' then
        local x, y = self:mouseGridPosition()
        self.drag.stop = {x=x, y=y }
    end
end

function InGameState:mousereleased()
    local x, y = self:mouseGridPosition()
    local endTarget = self.grid:get(x, y)
    if self.drag.mode == 'line' then
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

function InGameState:mouseGridPosition()
    local mousex, mousey = love.mouse.getPosition()
    local posx, posy = mousex / self.camera.zoom, (love.graphics:getHeight() - mousey) / self.camera.zoom;
    posx = math.floor( posx + 0.5 + self.camera.position.x)
    posy = math.floor( posy + 0.5 + self.camera.position.y)
    return posx, posy
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
