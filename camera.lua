local class = require "middleclass"
local Camera = class "Camera"
local Transform = require "Transform"

function Camera:initialize()
    self.zoom = 25
    self.position = {x = 0, y = 0}
    self.shakestart = 0
    self.trauma = 0
end

function Camera:setup()
    local w = love.graphics:getWidth()
    local h = love.graphics:getHeight()
    love.graphics.origin()
    -- Origin to lower-left corner
    local transform =
        Transform:scale(1, -1):multiply(Transform:translate(0, -h):multiply(Transform:scale(self.zoom, self.zoom)))
    transform = transform:multiply(Transform:translate(-self.position.x, -self.position.y))

    local shakex = 0
    local shakey = 0
    if self.trauma > 0 then
        local shake = self.trauma * self.trauma
        local max_angle = math.rad(10)
        local max_offset = 50 *self.zoom / 25
        local SEED = 123
        local time = self.shakestart * 5
        local angle = max_angle * shake * (love.math.noise(SEED, time) * 2 - 1)
        shakex = max_offset * shake * (love.math.noise(SEED + 1, time) * 2 - 1)
        shakey = max_offset * shake * (love.math.noise(SEED + 2, time) * 2 - 1)

        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        -- rotate around the center of the screen by angle radians
        love.graphics.translate(width/2, height/2)
        love.graphics.rotate(angle)
        love.graphics.translate(-width/2, -height/2)
    end

    love.graphics.translate(transform.dx + shakex, transform.dy + shakey)
    love.graphics.scale(transform.sx, transform.sy)
end

function Camera:update()
    local dt = love.timer.getDelta()
    local w = love.graphics:getWidth()
    local h = love.graphics:getHeight()
    local mousex, mousey = love.mouse.getPosition()
    local BORDER = 50
    local MOVE_SPEED = 8.0
    local move_diff = MOVE_SPEED * dt  * 25 / self.zoom
    self.speed = move_diff /dt
    if self.trauma > 0 then
        self.trauma = math.max(0, self.trauma - dt * 0.5)
        self.shakestart = self.shakestart + dt
    end

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

function Camera:draw()
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(255, 0, 255)
    love.graphics.print("movespeed: " .. tostring(self.speed), 100, 0)
    love.graphics.pop()
end

function Camera:wheelmoved(_, y)
    self.zoom = self.zoom + y
    if self.zoom < 5 then
        self.zoom = 5
    end
    if self.zoom > 75 then
        self.zoom = 75
    end
end

function clamp(low, n, high)
    return math.min(math.max(low, n), high)
end

function Camera:addTrauma(v)
    if self.trauma == 0 then
        self.shakestart = 0
    end
    self.trauma = clamp(0, self.trauma + v, 1)
end

return Camera
