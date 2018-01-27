local class = require "middleclass"
local Camera = class "Camera"
local Transform = require "Transform"

function Camera:initialize()
    self.zoom = 25
    self.position = {x = 0, y = 0}
end

function Camera:setup()
    local w = love.graphics:getWidth()
    local h = love.graphics:getHeight()
    love.graphics.origin()
    -- Origin to lower-left corner
    local transform =
        Transform:scale(1, -1):multiply(Transform:translate(0, -h):multiply(Transform:scale(self.zoom, self.zoom)))
    transform = transform:multiply(Transform:translate(-self.position.x, -self.position.y))

    love.graphics.translate(transform.dx, transform.dy)
    love.graphics.scale(transform.sx, transform.sy)
end

function Camera:update()
    local dt = love.timer.getDelta()
    local w = love.graphics:getWidth()
    local h = love.graphics:getHeight()
    local mousex, mousey = love.mouse.getPosition()
    local BORDER = 50
    local MOVE_SPEED = 4.0
    local move_diff = MOVE_SPEED * dt

    if mousex < 0 or mousey < 0 or mousex > w or mousey > h then
        -- outside of window
        return
    end

    if mousex < BORDER then
        self.position.x = self.position.x - move_diff
    end
    if mousex > w - BORDER then
        self.position.x = self.position.x + move_diff
    end

    -- y is flipped
    if mousey < BORDER then
        self.position.y = self.position.y + move_diff
    end
    if mousey > h - BORDER then
        self.position.y = self.position.y - move_diff
    end
end

return Camera
