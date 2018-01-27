local Gamestate = require "gamestate"
local constants = require 'constants'
local class = require 'middleclass'
local mainMenu = {}

local FADE_IN_TIME = 1.3

local MissionButton = class 'MissionButton'

function MissionButton:initialize(w, h, text)
    self.x = 0
    self.y = 0
    self.width = w
    self.height = h
    self.text = text
end

function MissionButton:setPosition(x, y)
    self.x = x
    self.y = y
end

function MissionButton:contains(x, y)
    return x >= self.x and y >= self.y and x <= self.x+self.width and y <= self.y+self.height
end

function MissionButton:draw()
    love.graphics.setFont(constants.NORMAL_FONT)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.printf(self.text, self.x, self.y+5, self.width, 'center')
end


function mainMenu:init()
    self.image = love.graphics.newImage("logo.png")
    
    
    local buttonWidth = 140
    local buttonHeight = 40
    local mission0 = "Expand to 1000 hectare in 5 days!"
    local mission1 = "Grow to over 9000 hectare!"
    local mission2 = "Get 10000 minerals rich!"
    self.buttons = {
        MissionButton:new(buttonWidth, buttonHeight, mission0),
        MissionButton:new(buttonWidth, buttonHeight, mission1),
        MissionButton:new(buttonWidth, buttonHeight, mission2)
        }
end

function mainMenu:enter()
    love.graphics.setBackgroundColor(0, 0, 0, 255)
    self.time = 0.0
    self:layoutButtons()
end

function mainMenu:resize(w, h)
    self:layoutButtons()
end

function mainMenu:layoutButtons()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    local buttonPadding = 10
    local buttonBarWidth = -buttonPadding
    for _, v in ipairs(self.buttons) do
        buttonBarWidth = buttonBarWidth + buttonPadding + v.width
    end
    
    local x = (windowWidth - buttonBarWidth) / 2.0
    local y = windowHeight - 200
    for _, v in ipairs(self.buttons) do
        v:setPosition(x, y)
        x = x + v.width + buttonPadding
    end
end



function mainMenu:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local imageWidth = self.image:getWidth()
    local imageHeight = self.image:getHeight()
    
    local s = 1.0
    if self.time < FADE_IN_TIME then
        s = self.time / FADE_IN_TIME
    else
        s = 0.9 + math.cos((self.time - FADE_IN_TIME)*(2*math.pi)) * 0.1
    end
    
    
    love.graphics.setColor(255*s, 255*s, 255*s, 255)
    love.graphics.draw(self.image, (windowWidth-imageWidth)/2, (windowHeight-imageHeight)/4)
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(constants.BIG_FONT)
    love.graphics.printf("Select your mission:", 0, windowHeight/2, windowWidth, 'center')
    
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
end

function mainMenu:update(dt)
    self.time = self.time + dt
end

function mainMenu:mousepressed(x, y, button)
    if button ~= 1 then
        return
    end
    for _, button in ipairs(self.buttons) do
        if button:contains(x,y) then
            Gamestate.switch(require "ingamestate")
        end
    end
end


function mainMenu:keypressed()
    if key == "escape" then
        love.event.quit()
    end
end

return mainMenu