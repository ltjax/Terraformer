

local InGameState = {}

function InGameState:init()

end

function InGameState:draw()

end

function InGameState:update(dt)

end

function InGameState:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return InGameState
