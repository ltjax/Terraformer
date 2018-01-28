local Gamestate = require "gamestate"
local constants = require 'constants'
local helpState = {}

helpState.helpImage = love.graphics.newImage('help.png')

function helpState:init()
    self.previous = nil
end

function helpState:enter(previous)
    self.previous = previous
end


function helpState:draw()
    if self.previous ~= nil then
        self.previous:draw()
    end
    
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local imageWidth = self.helpImage:getWidth()
    local imageHeight = self.helpImage:getHeight()
    
    local x = (windowWidth-imageWidth)/2
    local y = (windowHeight-imageHeight)/2
    
    love.graphics.origin()
    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(0,0,0,64)
    love.graphics.rectangle('fill', 0, 0, windowWidth, windowHeight)
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self.helpImage, x, y)
end


function helpState:keypressed()
    Gamestate.pop()
end

function helpState:mousepressed(x, y, button)
end

return helpState