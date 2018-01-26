local Entities = require 'Entities'
local Player = require "player"
local TerraFormer = require "terraformer"
local Node = require "node"
local PowerPlant = require "powerplant"
local EventBus = require 'EventBus'
local Transform = require 'Transform'

local InGameState = {}

function InGameState:init()
    self.eventBus = EventBus:new()
    self.entities = Entities:new()
    self.player = Player:new(self.eventBus);

    self:insertEntity(self.player)
    self:insertEntity(TerraFormer:new(self.eventBus, 2, 2))
    self:insertEntity(Node:new(1, 1))
end

function InGameState:insertEntity(entity)
    self.entities:add(entity)
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

    love.graphics.push()
    love.graphics.origin()
    local x,y = love.mouse.getPosition()
    love.graphics.print(tostring(x) .. "|" .. tostring(h - y), 0, 0)
    love.graphics.pop()
end

function InGameState:update(dt)
    self.entities:callAll('update')
end

function InGameState:keypressed(key)
    local mousex, mousey = love.mouse.getPosition()
    local posx, posy = mousex / 25, (love.graphics:getHeight() - mousey) / 25;
    posx = math.floor( posx + 0.5 )
    posy = math.floor( posy + 0.5 )
    
    if key == "escape" then
        love.event.quit()
    end
    if key == "space" then
        self.entities:callAll('step')
    end
    if key == "q" then
        self:insertEntity(TerraFormer:new(self.eventBus, posx, posy))
    end
    if key == "w" then
        self:insertEntity(Node:new(posx, posy))
    end
    if key == "e" then
        self:insertEntity(PowerPlant:new(posx, posy))
    end
end

return InGameState
