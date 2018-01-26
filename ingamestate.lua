local Entities = require 'Entities'
local Player = require "player"
local TerraFormer = require "terraformer"
local Node = require "node"
local EventBus = require 'EventBus'

local InGameState = {}

function InGameState:init()
    self.eventBus = EventBus:new()
    self.entities = Entities:new()
    self.player = Player:new();
    
    self:insertEntity(self.player)
    self:insertEntity(TerraFormer:new(2, 2))
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
    love.graphics.scale(1, -1)
    love.graphics.translate(0, -h)

    -- Scale everything up
    love.graphics.scale(25, 25)

    -- Draw simple grid
    local m=200
    for i=0,m do
        love.graphics.setColor(32,32,32)
        love.graphics.setLineWidth(1 / 25)
        love.graphics.line(i,0,i,m)
        love.graphics.line(0,i,m,i)
    end

    self.entities:callAll('draw')
    self.entities:callAll('drawBackground')
end

function InGameState:update(dt)
    self.entities:callAll('update')
end

function InGameState:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "space" then
        self.entities:callAll('step')
    end
end

return InGameState
