local class = require "middleclass"
local Camera = class "Camera"
local Transform = require "transform"
local mathhelpers = require "mathhelpers"

function Camera:initialize()
    self.zoom = 50
    self.position = {x = 0, y = 0}
    self.shakestart = 0
    self.trauma = 0
    self.texts = {}
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
        local max_offset = 50 * self.zoom / 25
        local SEED = 123
        local time = self.shakestart * 5
        local angle = max_angle * shake * (love.math.noise(SEED, time) * 2 - 1)
        shakex = max_offset * shake * (love.math.noise(SEED + 1, time) * 2 - 1)
        shakey = max_offset * shake * (love.math.noise(SEED + 2, time) * 2 - 1)

        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        -- rotate around the center of the screen by angle radians
        love.graphics.translate(width / 2, height / 2)
        love.graphics.rotate(angle)
        love.graphics.translate(-width / 2, -height / 2)
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
    local move_diff = MOVE_SPEED * dt * 25 / self.zoom
    self.speed = move_diff / dt
    if self.trauma > 0 then
        self.trauma = math.max(0, self.trauma - dt * 0.5)
        self.shakestart = self.shakestart + dt
    end

    if not love.window.getFullscreen() and (mousex <= 0 or mousex >= w-1 or mousey <= 1 or mousey >= h-1 or not love.window.hasFocus()) then
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

function Camera:drawTop()
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(255, 0, 255)
    love.graphics.setBlendMode("alpha")
    for _, v in pairs(self.texts) do
        love.graphics.print(unpack(v))
    end
    self.texts = {}
    love.graphics.pop()
end

function Camera:boundingBox()
    local windowSize = mathhelpers.scale({x = love.graphics:getWidth(),y = love.graphics:getHeight() }, 1 / self.zoom)
    return self.position, mathhelpers.add(self.position, windowSize)
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

function Camera:drawText(text, gridx, gridy)
    local h = love.graphics.getHeight()
    local x = (gridx + 0.5 - self.position.x) * self.zoom
    local y = h - (gridy + 0.5 - self.position.y) * self.zoom
    table.insert(self.texts, {text, x, y})
end

return Camera
