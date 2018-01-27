local Entities = require 'Entities'
local Player = require "player"
local TerraFormer = require "terraformer"
local Node = require "node"
local PowerPlant = require "powerplant"
local EventBus = require 'EventBus'
local Transform = require 'Transform'
local Grid = require 'Grid'
local PowerLine = require 'powerline'

local InGameState = {}

function InGameState:init()
  self.eventBus = EventBus:new()
  self.entities = Entities:new()
  self.player = Player:new(self.eventBus);
  self.grid = Grid:new()

  self.drag = {
      mode= 'off',
  }
  self:insertEntity(self.player)

  local terraformer = TerraFormer:new(self.eventBus, 7, 14)
  local node = Node:new(5, 10)
  local powerPlant = PowerPlant:new(2, 11)
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

function InGameState:draw()
    local w = love.graphics:getWidth()
    local h = love.graphics:getHeight()
    love.graphics.origin()

    -- Origin to lower-left corner
    local Camera = Transform:scale(1, -1):multiply(Transform:translate(0, -h):multiply(Transform:scale(25, 25)))

    love.graphics.translate(Camera.dx, Camera.dy)
    love.graphics.scale(Camera.sx, Camera.sy)

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

function InGameState:newBuildingFor(key, posx, posy)
    if key == "q" then
        return TerraFormer:new(self.eventBus, posx, posy)
    end
    if key == "w" then
        return Node:new(posx, posy)
    end
    if key == "e" then
        return PowerPlant:new(posx, posy)
    end
    return nil
end

function InGameState:mousepressed()
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
    local posx, posy = mousex / 25, (love.graphics:getHeight() - mousey) / 25;
    posx = math.floor( posx + 0.5 )
    posy = math.floor( posy + 0.5 )
    return posx, posy
end

function InGameState:keypressed(key)
  local posx, posy = self:mouseGridPosition()
  
  if key == "escape" then
      love.event.quit()
  end
  if key == "space" then
      self.entities:callAll('step')
  end

  if self.grid:get(posx, posy) then
      return
  end

  local building = self:newBuildingFor(key, posx, posy)
  if not building then
      return
  end

  self:insertBuilding(building)
end

return InGameState
