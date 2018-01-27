local class = require "middleclass"
local Gamestate = require "gamestate"

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
