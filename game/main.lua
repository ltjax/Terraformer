local class = require "middleclass"
local Gamestate = require "gamestate"

function drawCentered(image, x, y)
    love.graphics.draw(image, x, y, 0, 1/image:getWidth(), -1/image:getHeight(), image:getWidth()/2, image:getHeight()/2)
end

function love.load(arg)

    -- Enable debugging
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end

    love.window.setTitle("Terraformer")
    
    -- Start the gamestate manager and move to the logo state
    local events = {'draw', 'errhand', 'focus', 'keypressed', 'keyreleased', 'mousefocus',
        'mousepressed', 'mousereleased', 'mousemoved', 'wheelmoved', 'quit', 'resize', 'textinput',
        'threaderror', 'update', 'visible', 'gamepadaxis', 'gamepadpressed',
        'gamepadreleased', 'joystickadded', 'joystickaxis', 'joystickhat',
        'joystickpressed', 'joystickreleased', 'joystickremoved' }

    Gamestate.registerEvents(events)
    Gamestate.switch(require "ingamestate")
end
