local class = require "middleclass"
local resources = class "resources"

local Grid = require "grid"

-- per axis
local BLOCK_SIZE = 25
local NUM_BLOCKS = 5

resources.static.type = {
    METAL = {image = love.graphics.newImage("metal.png")},
    BLOCKER
}

function resources:initialize()
    self.resourcegrid = Grid:new()

    for x = -NUM_BLOCKS / 2, NUM_BLOCKS / 2 do
        for y = -NUM_BLOCKS / 2, NUM_BLOCKS / 2 do
            if x ~= 0 and y ~= 0 then
                self:set(
                    math.floor((x - 1) * BLOCK_SIZE + math.random(BLOCK_SIZE)),
                    math.floor((y - 1) * BLOCK_SIZE + math.random(BLOCK_SIZE)),
                    resources.type.METAL
                )
            end
        end
    end
end

function resources:drawOverlay()
    love.graphics.push()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha")

    self.resourcegrid:iterate(
        function(v)
            drawCentered(v.type.image, v.x, v.y)
        end
    )
    love.graphics.pop()
end

function resources:set(x, y, type)
    self.resourcegrid:set(x, y, {x = x, y = y, type = type})
end

function resources:has(x, y, type)
    local v = self.resourcegrid:get(x, y)
    if v == nil then
        return false
    end
    return v.type == type
end

return resources
