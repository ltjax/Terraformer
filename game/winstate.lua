
local Gamestate = require "gamestate"
local constants = require 'constants'
local winState = {}

function winState:init()
end

function winState:enter()
    love.graphics.setBackgroundColor(0, 0, 0, 255)
end


function winState:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    love.graphics.setFont(constants.BIG_FONT)
    love.graphics.printf("Congratulations! You made it!", 0, windowHeight/2, windowWidth, 'center')
end

function winState:toMainMenu()
    Gamestate.switch(require "mainmenu")
end

function winState:keypressed()
    self:toMainMenu()
end

function winState:mousepressed(x, y, button)
    if button==1 then
        self:toMainMenu()
    end
end

return winState