local Gamestate = require "gamestate"
local constants = require 'constants'
local class = require 'middleclass'
local mainMenu = {}

-- TODO: Should probably go to a missions module
local TerraFormer = require "terraformer"
local Node = require "node"
local PowerPlant = require "powerplant"
local Mine = require "mine"

local FADE_IN_TIME = 1.3

local MissionButton = class 'MissionButton'

function MissionButton:initialize(w, h, text, setup, goals)
    self.x = 0
    self.y = 0
    self.width = w
    self.height = h
    self.text = text
    self.setup = setup
    self.goals = goals
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
    
    -- TODO: Should probably go to a missions module
    
    local buttonWidth = 140
    local buttonHeight = 40
    local ox, oy = 6, 6
    local missionSetup = function(game)
        local terraformer = TerraFormer:new(game.eventBus, ox+math.random(1, 3), oy+math.random(1, 2))
        local node = Node:new(game.eventBus, ox, oy)
        local powerPlant = PowerPlant:new(game.eventBus, ox+math.random(-3, -1), oy+math.random(1, 2))
        local mine = Mine:new(game.eventBus, ox+math.random(-1, 1), oy+math.random(-3, -1))
        game:insertBuilding(terraformer)
        game:insertBuilding(node)
        game:insertBuilding(powerPlant)
        game:insertBuilding(mine)
        
        game:connectLine(terraformer, node)
        game:connectLine(powerPlant, node)
        game:connectLine(mine, node)
    end
    
    local missionSetup0 = function(game)
        local terraformer = TerraFormer:new(game.eventBus, ox+math.random(1, 3), oy+math.random(1, 2))
        local node = Node:new(game.eventBus, ox, oy)
        local powerPlant = PowerPlant:new(game.eventBus, ox+math.random(-3, -1), oy+math.random(1, 2))
        local mine = Mine:new(game.eventBus, ox+math.random(-2, -1), oy+math.random(-3, -1))
        local mine2 = Mine:new(game.eventBus, ox+math.random(1, 2), oy+math.random(-3, -1))
        game:insertBuilding(terraformer)
        game:insertBuilding(node)
        game:insertBuilding(powerPlant)
        game:insertBuilding(mine)
        game:insertBuilding(mine2)
        
        game:connectLine(terraformer, node)
        game:connectLine(powerPlant, node)
        game:connectLine(mine, node)
        game:connectLine(mine2, node)
    end
    
    local missionGoals0 = {
        timeLimit=300,
        hectare=750
    }
    local mission0 = string.format("Expand to %.0f hectare in %.0f minutes!",
        missionGoals0.hectare, missionGoals0.timeLimit / 60)
    
    local missionGoals1 = {
        hectare=3000
    }
    local mission1 = string.format("Grow to over %.0f hectare!", missionGoals1.hectare)

    
    local missionGoals2 = {
        minerals=10000
    }
    local mission2 = string.format("Get %.0f minerals rich!", missionGoals2.minerals)
    
    self.buttons = {
        MissionButton:new(buttonWidth, buttonHeight, mission1, missionSetup, missionGoals1),
        MissionButton:new(buttonWidth, buttonHeight, mission0, missionSetup0, missionGoals0),
        MissionButton:new(buttonWidth, buttonHeight, mission2, missionSetup, missionGoals2)
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
            Gamestate.switch(require "ingamestate", button.setup, button.goals)
            Gamestate.push(require 'helpstate')
        end
    end
end


function mainMenu:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if key == 'f1' then
        love.window.setFullscreen(not love.window.getFullscreen( ), "desktop")
    end
end

return mainMenu