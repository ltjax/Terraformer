local class = require "middleclass"
local HudBuilding = class "HudBuilding"

local buildings = {
    require "terraformer",
    require "node",
    require "powerplant"
}
local Y_STEP = 30
local SIZE = {w = 140, h = 20}

function HudBuilding:initialize(ingamestate)
    self.ingamestate = ingamestate
    self.buttons = {}
    self.placement = nil
    self.button_start = {
        x = love.graphics.getWidth() - 150,
        y = love.graphics.getHeight() - 100
    }
end

function HudBuilding:draw()
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setBlendMode("alpha")
    local x = self.button_start.x
    local y = self.button_start.y
    for _, v in pairs(buildings) do
        local selected = self.placement == v
        local bg_color = {50, 120, 250}
        if selected then
            bg_color = {20, 50, 100}
        end
        love.graphics.setColor(unpack(bg_color))
        love.graphics.rectangle("fill", x, y, SIZE.w, SIZE.h, 5, 5)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(v.name, x + 5, y + 4)
        if v.mineral_cost then
            love.graphics.print(tostring(v.mineral_cost), x + SIZE.w - 30, y + 4)
        end
        y = y + Y_STEP
    end
    love.graphics.pop()
    if self.placement then
        self:draw_placement()
    end
end
function HudBuilding:draw_placement()
    local x, y = self.ingamestate:mouseGridPosition()
    love.graphics.push()
    if self.ingamestate.grid:get(x, y) ~= nil or not self.ingamestate.player:has_minerals(self.placement.mineral_cost) then
        love.graphics.setColor(128, 0, 0)
    else
        love.graphics.setColor(0, 128, 0)
    end
    love.graphics.circle("fill", x, y, 0.7)
    love.graphics.pop()
end

function HudBuilding:mousepressed(mousex, mousey, button)
    if button == 1 then
        if self.placement then
            local x, y = self.ingamestate:mouseGridPosition()
            self.ingamestate:createBuilding(self.placement, x, y)
            self.placement = nil
            return true
        end
        local x = self.button_start.x
        local y = self.button_start.y
        for _, v in pairs(buildings) do
            if mousex > x and mousex < x + SIZE.w and mousey > y and mousey < y + SIZE.h then
                self.placement = v
                return true
            end
            y = y + Y_STEP
        end
    end
    if button == 2 then
        self.placement = nil
        return true
    end
    return self.placement ~= nil
end

return HudBuilding
