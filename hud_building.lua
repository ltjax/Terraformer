local class = require "middleclass"
local HudBuilding = class "HudBuilding"

local TerraFormer = require "terraformer"
local Node = require "node"
local PowerPlant = require "powerplant"

local buildings = {
    TERRAFORMER = {text = "TerraFormer", create_class = TerraFormer},
    NODE = {text = "Node", create_class = Node},
    POWERPLANT = {text = "PowerPlant", create_class = PowerPlant}
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
    for i, v in pairs(buildings) do
        local selected = self.placement == v.create_class
        local bg_color = {50, 120, 250}
        if selected then
            bg_color = {20, 50, 100}
        end
        love.graphics.setColor(unpack(bg_color))
        love.graphics.rectangle("fill", x, y, SIZE.w, SIZE.h, 5, 5)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(v.text, x + 5, y + 4)
        if v.create_class.mineral_cost then
            love.graphics.print(tostring(v.create_class.mineral_cost), x + SIZE.w - 30, y + 4)
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
    if self.ingamestate.grid:get(x, y) ~= nil then
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
                self.placement = v.create_class
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
