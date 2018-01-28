
local Gamestate = require "gamestate"
local constants = require 'constants'
local failState = {}

function failState:init()
end

function failState:enter()
    love.graphics.setBackgroundColor(0, 0, 0, 255)
end

function failState:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    love.graphics.setFont(constants.BIG_FONT)
    love.graphics.printf("Oh no, you did not make it! Try again!", 0, windowHeight/2, windowWidth, 'center')
end

function failState:toMainMenu()
    Gamestate.switch(require "mainmenu")
end

function failState:keypressed()
    self:toMainMenu()
end

function failState:mousepressed(x, y, button)
    if button==1 then
        self:toMainMenu()
    end
end

return failState