local Entities = require 'Entities'
local Player = require "player"

local InGameState = {}

function InGameState:init()
    self.entities = Entities:new()
    self:insertEntity({
        draw=function(self)
            love.graphics.setColor(0, 100, 100)
            love.graphics.rectangle("fill", 10, 10, 120, 80)
        end
    })
end

function InGameState:insertEntity(entity)
    self.entities:add(entity)
end

function InGameState:draw()
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
