local class = require "middleclass"
local HudBuilding = class "HudBuilding"

local Node = require "node"
local buildings = {
    require "terraformer",
    Node,
    require "powerplant",
    require "mine",
}
local Y_STEP = 30
local SIZE = {w = 140, h = 20}

function buttonStart()
    return love.graphics.getWidth() - SIZE.w - 10, love.graphics.getHeight() - #buildings * Y_STEP - 40
end

function HudBuilding:initialize(ingamestate)
    self.ingamestate = ingamestate
    self.buttons = {}
    self.placement = nil
end

function HudBuilding:drawHud()
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setBlendMode("alpha")
    local x, y = buttonStart()
    for _, v in pairs(buildings) do
        local selected = self.placement == v
        local bg_color = {50, 120, 250}
        if selected then
            bg_color = {20, 50, 100}
        else
            if not self.ingamestate.player:has_minerals(v.mineral_cost) then
                bg_color = {180, 20, 20}
            end
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
    if self:placing() then
        self:draw_placement()
    end
end

function HudBuilding:placing()
    return self.placement ~= nil
end

function HudBuilding:draw_placement()
    local x, y = self.ingamestate:mouseGridPosition()
    love.graphics.push()
    if not self.ingamestate:canBuild(x, y, self.placement) or not self.ingamestate.player:has_minerals(self.placement.mineral_cost) then
        love.graphics.setColor(128, 0, 0)
    else
        love.graphics.setColor(0, 128, 0)
    end
    love.graphics.circle("fill", x, y, 0.3, 16)
    if self.placement == Node then
        local c = 0.5
        love.graphics.setColor(150*c+100, 160*c+50, 30*c+10)
        love.graphics.setLineWidth(1 / 25)
        local max_length = 7 -- see InGameState:dragTarget
        for ox = -max_length, max_length do
            for oy = -max_length, max_length do
                if math.sqrt(ox^2 + oy^2) <= max_length then
                    local tx = x + ox
                    local ty = y + oy
                    local t = self.ingamestate.grid:get(tx, ty)
                    if t~=nil and t:isInstanceOf(Node) then
                        love.graphics.line(x, y, tx, ty)
                    end
                end
            end
        end
    end
    love.graphics.pop()
end

function HudBuilding:mousepressed(mousex, mousey, button)
    if button == 1 then
        if self.placement then
            local x, y = self.ingamestate:mouseGridPosition()
            self.ingamestate:createBuilding(self.placement, x, y)
            return true
        end
        local x, y = buttonStart()
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
