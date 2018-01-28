local class = require "middleclass"
local Gamestate = require "gamestate"

function drawCentered(image, x, y)
    love.graphics.draw(image, x, y, 0, 1/image:getWidth(), -1/image:getHeight(), image:getWidth()/2, image:getHeight()/2)
end

function drawEnergyBar(x, y, percentage, critical)
    if percentage < 0.01 then
        return
    end
    
    local barX, barY = x+0.51, y-0.5
    love.graphics.setColor(0, 64, 0, 64)
    love.graphics.rectangle('fill', barX, barY, 0.1, 1)
    if percentage < critical then
        love.graphics.setColor(64, 0, 0, 200)
    else
        love.graphics.setColor(0, 32, 0, 64)
    end
    love.graphics.rectangle('fill', barX, barY, 0.1, percentage)

end

function clamp(low, n, high)
    return math.min(math.max(low, n), high)
end

function love.load(arg)

    -- Enable debugging
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    else
        math.randomseed(os.time())
    end

    love.window.setTitle("Terraformer")
    
    -- Start the gamestate manager and move to the logo state
    local events = {'draw', 'errhand', 'focus', 'keypressed', 'keyreleased', 'mousefocus',
        'mousepressed', 'mousereleased', 'mousemoved', 'wheelmoved', 'quit', 'resize', 'textinput',
        'threaderror', 'update', 'visible', 'gamepadaxis', 'gamepadpressed',
        'gamepadreleased', 'joystickadded', 'joystickaxis', 'joystickhat',
        'joystickpressed', 'joystickreleased', 'joystickremoved' }

    Gamestate.registerEvents(events)
    Gamestate.switch(require "mainmenu")
end
