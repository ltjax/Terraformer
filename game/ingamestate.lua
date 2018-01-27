local Entities = require 'entities'
local Player = require "player"
local TerraFormer = require "terraformer"
local Node = require "node"
local PowerPlant = require "powerplant"
local Mine = require "mine"
local EventBus = require 'eventbus'
local Camera = require 'camera'
local Grid = require 'grid'
local PowerLine = require 'powerline'
local HudBuilding = require 'hud_building'
local mathhelpers = require 'mathhelpers'
local constants = require 'constants'

local InGameState = {}

InGameState.assets = {
    building_placement = love.audio.newSource("sfx/building_placement.mp3", "static"),
    not_enough_minerals = love.audio.newSource("sfx/not_enough_mins.mp3", "static")
}

function InGameState:init()
    self.eventBus = EventBus:new()
    self.entities = Entities:new()
    self.player = Player:new(self.eventBus);
    self.grid = Grid:new()
    self.camera = Camera:new();
    self.hud_building = HudBuilding:new(self)
    self.accumulated = 0.0
    self.background = love.graphics.newImage('background.png')
    self.speedUp = 1
    self.time = 0

    self.drag = {
        mode= 'off',
    }
    self:insertEntity(self.player)
    self:insertEntity(self.camera)
    self:insertEntity(self.hud_building)

    local terraformer = TerraFormer:new(nil, 7, 14)
    terraformer.energy = 5
    terraformer.active_radius = TerraFormer.shield_radius_max
    local node = Node:new(nil, 5, 10)
    local powerPlant = PowerPlant:new(nil, 2, 11)
    local mine = Mine:new(self.eventBus, 6, 7)
    self:insertBuilding(terraformer)
    self:insertBuilding(node)
    self:insertBuilding(powerPlant)
    self:insertBuilding(mine)
    
    self:connectLine(terraformer, node)
    self:connectLine(powerPlant, node)
    self:connectLine(mine, node)
end

function InGameState:insertEntity(entity)
    self.entities:add(entity)
end

function InGameState:insertBuilding(building)
  self:insertEntity(building)
  self.grid:set(building.position.x, building.position.y, building)
end

function InGameState:createBuilding(building_class, x, y)
    if not self:canBuild(x, y) then
        return nil
    end
    if not self.player:use_minerals(building_class.mineral_cost) then
        InGameState.assets.not_enough_minerals:play()
        return nil
    end
    local building = building_class:new(self.eventBus, x, y)
    self:insertBuilding(building)
    self.camera:addTrauma(0.2)
    InGameState.assets.building_placement:play()
    return building
end

function InGameState:drawBackgroundTiles()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(255, 255, 255, 200)
    local tileSize = 50
    for by=-1,0 do
        for bx=-1,0 do
            love.graphics.draw(self.background, bx*tileSize, by*tileSize, 0,tileSize/self.background:getWidth(), tileSize/self.background:getHeight())
        end
    end
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

    love.graphics.setFont(constants.NORMAL_FONT)
    -- Scale everything up
    love.graphics.setBlendMode("replace")
    
    self.entities:callAll('drawBackground')
    
    self:drawBackgroundTiles()    

    -- Draw simple grid
    local b0, b1 = self.camera:boundingBox()
    b0, b1 = mathhelpers.floor(b0), mathhelpers.floor(b1)
    love.graphics.setBlendMode("alpha")
    local m=200
    for i=b0.x,b1.x do
        for j=b0.y,b1.y do
            love.graphics.setColor(32,32,32, 4)
            love.graphics.setLineWidth(1 / 25)
            love.graphics.line(i,b0.y,i,b1.y+1)
            love.graphics.line(b0.x,j,b1.x+1,j)
        end
    end
    
    self.entities:callAll('draw', self.camera)
    self.entities:callAll('drawOverlay', self.camera)
    self.camera:drawTop()

    if self.drag.start and self.drag.stop then
        love.graphics.line(self.drag.start.x, self.drag.start.y, self.drag.stop.x, self.drag.stop.y)
    end

    love.graphics.push()
    love.graphics.origin()
    local x,y = love.mouse.getPosition()
    --love.graphics.print(tostring(x) .. "|" .. tostring(h - y), 0, 0)
    love.graphics.setBlendMode("alpha")
    love.graphics.setFont(constants.BIG_FONT)
    love.graphics.setColor(255, 255, 255, 128)
    local timeString = string.format("%.1f", self.time)
    if self.speedUp ~= 1 then
        formatString = "%s (%.0fx)"
        if self.speedUp < 1 then
            formatString = "%s (%.2fx)"
        end
        
        timeString = string.format(formatString, timeString, self.speedUp)
    end
    
    love.graphics.print(timeString, love.graphics.getWidth() / 2, 0)
    love.graphics.pop()
end

function InGameState:update(dt)
    local frameTime = 1/30
    dt = dt * self.speedUp
    self.time = self.time + dt
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
    if key == "e" then
        self.speedUp = self.speedUp * 2
    end
    if key == "q" then
        self.speedUp = self.speedUp * 0.5
    end
    
    if key == 'f1' then
        love.window.setFullscreen(not love.window.getFullscreen( ), "desktop")
    end
end

function InGameState:wheelmoved(x, y)
    self.camera:wheelmoved(x, y)
end

return InGameState
