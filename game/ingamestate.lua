local Entities = require 'entities'
local Gamestate = require 'gamestate'
local Player = require "player"
local TerraFormer = require "terraformer"
local Node = require "node"
local PowerPlant = require "powerplant"
local Mine = require "mine"
local EnergyTransmitter = require "energytransmitter"
local EventBus = require 'eventbus'
local Camera = require 'camera'
local Grid = require 'grid'
local PowerLine = require 'powerline'
local HudBuilding = require 'hud_building'
local mathhelpers = require 'mathhelpers'
local constants = require 'constants'
local TerraformedGrid = require 'terraformedgrid'
local settings = require 'settings'
local resources = require 'resources'

local InGameState = {}

InGameState.assets = {
    ambient_forest = love.audio.newSource("sfx/forest.mp3"),
    ambient_wind = love.audio.newSource("sfx/wind.mp3"),
    building_placement = love.audio.newSource("sfx/building_placement.mp3", "static"),
    not_enough_minerals = love.audio.newSource("sfx/insufficient_minerals.mp3", "static"),
    music = love.audio.newSource("sfx/music.mp3"),
    splosion = love.audio.newSource('sfx/splosion.mp3')
}

InGameState.assets.ambient_forest:setLooping(true)
InGameState.assets.ambient_wind:setLooping(true)
InGameState.assets.music:setLooping(true)
InGameState.assets.not_enough_minerals:setVolume(0.1)
InGameState.assets.splosion:setVolume(0.3)

function InGameState:enter(previous, setupFunction, goals)
    self.eventBus = EventBus:new()
    self.entities = Entities:new()
    self.player = Player:new(self.eventBus, goals);
    self.grid = Grid:new()
    self.resources = resources:new()
    self.camera = Camera:new();
    self.hud_building = HudBuilding:new(self)
    self.accumulated = 0.0
    self.background = love.graphics.newImage('background.png')
    self.terraformedGrid = TerraformedGrid:new(self.eventBus)
    self.forest_volume = 1
    self.time_outside = 0
    self.lctrl = false
    self.rctrl = false

    self.drag = {
        mode= 'off',
    }
    
    InGameState.assets.ambient_forest:setVolume(settings:ambientVolume())
    InGameState.assets.ambient_wind:setVolume(0.0)
    InGameState.assets.ambient_forest:play()
    InGameState.assets.ambient_wind:play()
    InGameState.assets.music:setVolume(0.1)
    love.audio.play(InGameState.assets.music)

    self:insertEntity(self.player)
    self:insertEntity(self.camera)
    self:insertEntity(self.hud_building)
    self:insertEntity(self.resources)

    if setupFunction then
        setupFunction(self)
    end
    
    
    self.entities:forEach(function(entity)
        if entity:isInstanceOf(TerraFormer) then
            entity.energy = TerraFormer.max_energy
            entity.active_radius = TerraFormer.shield_radius_max
            self.terraformedGrid:radiusChanged(entity)
        end
        if entity:isInstanceOf(Mine) then
            self.resources:set(entity.position.x, entity.position.y, resources.type.METAL)
        end
    end)
end

function InGameState:insertEntity(entity)
    self.entities:add(entity)
end

function InGameState:removeEntity(entity)
    self.entities:remove(entity)
end

function InGameState:insertBuilding(building)
  self:insertEntity(building)
  self.grid:set(building.position.x, building.position.y, building)
end

function InGameState:createBuilding(building_class, x, y)
    if not self:canBuild(x, y, building_class) then
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

function InGameState:destroyUnderMouse()
    local posx, posy = self:mouseGridPosition()
    if self:destroyAt(posx, posy) then
        InGameState.assets.splosion:play()
        return
    end
    -- todo check for powerlines
end
function InGameState:destroyAt(posx, posy)
    local building = self.grid:get(posx, posy)
    if building == nil then
        return false
    end
    self:destroyBuilding(building)
    return true
end
function InGameState:destroyBuilding(building)
    if building:isInstanceOf(EnergyTransmitter) then
        building:disconnectAll()
    end
    self.grid:set(building.position.x, building.position.y, nil)
    self:removeEntity(building)
end

function InGameState:drawBackgroundTiles()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(255, 255, 255, 200)
    local b0, b1 = self.camera:boundingBox()
    local tileSize = 50
    b0, b1 = mathhelpers.scale(b0, 1 / tileSize), mathhelpers.scale(b1, 1 / tileSize)
    b0, b1 = mathhelpers.floor(b0), mathhelpers.floor(b1)
    b0, b1 = mathhelpers.scale(b0, tileSize), mathhelpers.scale(b1, tileSize)

    for bx=b0.x,b1.x,tileSize do
        for by=b0.y,b1.y,tileSize do
            love.graphics.draw(self.background, bx, by, 0,tileSize/self.background:getWidth(), tileSize/self.background:getHeight())
        end
    end
end

function InGameState:canBuild(x, y, type)
    if self.grid:get(x, y) ~= nil then
        return false
    end
    if not self:terraformed(x, y) then
        return false
    end
    if type.needed_resource ~= nil and not self.resources:has(x, y, type.needed_resource) then
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

    love.graphics.setFont(constants.NORMAL_FONT)
    -- Scale everything up
    local canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight());
    love.graphics.setCanvas(canvas)
    self.camera:setup()
    love.graphics.clear()
    self.entities:callAll('drawBackground', self.camera)
    love.graphics.setCanvas()

    self:drawBackgroundTiles()

    love.graphics.origin()
    love.graphics.scale(1, -1)
    love.graphics.translate(0, -love.graphics.getHeight())
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(canvas)

    -- Draw simple grid
    self.camera:setup()
    if self.hud_building:placing() then
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
    end

    self.entities:callAll('draw', self.camera)
    self.entities:callAll('drawOverlay', self.camera)
    self.entities:callAll('drawHud', self.camera)

    if self.drag.start and self.drag.stop then
        love.graphics.setLineWidth(1 / 25)
        love.graphics.line(self.drag.start.x, self.drag.start.y, self.drag.stop.x, self.drag.stop.y)
    end

    love.graphics.push()
    love.graphics.origin()
    if self.time_outside > 10 then
        love.graphics.print("Lost? - Press 'H' to return home", 0, h - 20)
    end
    --love.graphics.print(tostring(x) .. "|" .. tostring(h - y), 0, 0)
    love.graphics.pop()
end

function InGameState:update(dt)
    local frameTime = 1/30
    dt = self.player:scaleTime(dt)
    self.entities:callAll('update', dt)
    self.accumulated = self.accumulated + dt
    while self.accumulated > frameTime do
        self.accumulated = self.accumulated - frameTime
        self.entities:callAll('step', frameTime)
    end
    self:updateAmbient(dt)
    if self.forest_volume > 0 then
        self.time_outside = 0
    else
        self.time_outside = self.time_outside + dt
    end
end
function InGameState:updateAmbient(dt)
    local p0, p1 = self.camera:boundingBox()
    local diff = mathhelpers.scale(mathhelpers.difference(p0, p1), 0.5)
    local center = mathhelpers.add(p0, diff)
    diff = mathhelpers.scale(diff, 0.5)
    local diff_o = {x=diff.x, y=-diff.y}
    local c0 = mathhelpers.add(center, diff)
    local c1 = mathhelpers.add(center, mathhelpers.negate(diff))
    local c2 = mathhelpers.add(center, diff_o)
    local c3 = mathhelpers.add(center, mathhelpers.negate(diff_o))

    local points = {center, c0, c1, c2, c3}
    local terraformed = 0
    for _, p in pairs(points) do
        if self:terraformed(p.x, p.y) then
            terraformed = terraformed + 1
        end
    end
    local inside = terraformed > #points / 2
    local AMBIENT_FADE = 2
    if inside then
        self.forest_volume = math.min(1, self.forest_volume + dt / AMBIENT_FADE)
    else
        self.forest_volume = math.max(0, self.forest_volume - dt / AMBIENT_FADE)
    end
    local wind_volume = 1 - self.forest_volume
    local ambient_volume = settings:ambientVolume()
    InGameState.assets.ambient_forest:setVolume(ambient_volume * self.forest_volume)
    InGameState.assets.ambient_wind:setVolume(ambient_volume * wind_volume)
end

function InGameState:mousepressed(x, y, button)
    if self.hud_building:mousepressed(x, y, button) then
        return
    end
    
    if button == 3 then
        self.camera.panning = true
        local x,y = love.mouse:getPosition();
        self.camera.initial_mousex = x;
        self.camera.initial_mousey = y;
        return
    end

    if button ~= 1 then
        return
    end

    if self:ctrl() then
        self:destroyUnderMouse()
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
    x, y = self:roundPosition(d.x, d.y)
    d = {x=x, y=y}
    if mathhelpers.length(d) > max_length then
        local ox, oy = 1, 1
        if d.x > 0 then
            ox = -1
        end
        if d.y > 0 then
            oy = -1
        end
        if mathhelpers.length({x=d.x+ox, y=d.y}) <= max_length then
            d.x = d.x + ox
        elseif mathhelpers.length({x=d.x, y=d.y+oy}) <= max_length then
            d.y = d.y + oy
        else
            d.x, d.y = d.x + ox, d.y + oy
        end
    end
    local e = mathhelpers.add(d, self.drag.start)
    return e.x, e.y
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

    self.camera.panning = false;
end

function InGameState:connectLine(startTarget, endTarget)
    self:insertEntity(PowerLine:new(self, startTarget, endTarget))
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
        Gamestate.switch(require 'mainmenu')
    end
    if key == "e" then
        self.player:increaseSpeed()
    end
    if key == "q" then
        self.player:decreaseSpeed()
    end
    if key == "h" then
        self.camera.position = {x=0, y=0}
    end
    if key == "rctrl" then
        self.rctrl = true
    end
    if key == "lctrl" then
        self.lctrl = true
    end
    if key == 'f1' then
        love.window.setFullscreen(not love.window.getFullscreen( ), "desktop")
    end
end

function InGameState:keyreleased(key)
    if key == "rctrl" then
        self.rctrl = false
    end
    if key == "lctrl" then
        self.lctrl = false
    end
end

function InGameState:ctrl()
    return self.rctrl or self.lctrl
end

function InGameState:wheelmoved(x, y)
    self.camera:wheelmoved(x, y)
end

return InGameState
