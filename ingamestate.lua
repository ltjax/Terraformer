
local InGameState = {}

function InGameState:init()
    self.entities = {}
    self:insertEntity({
        draw=function(self)
            love.graphics.setColor(0, 100, 100)
            love.graphics.rectangle("fill", 10, 10, 120, 80)
        end
    })
end

function InGameState:insertEntity(entity)
    table.insert(self.entities, entity)
end

function InGameState:draw()
    for _, entity in ipairs(self.entities) do
        if entity.drawBackground then
            entity:drawBackground()
        end
    end

    for _, entity in ipairs(self.entities) do
        if entity.draw then
            entity:draw()
        end
    end
end

function InGameState:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.update then
            entity:update()
        end
    end
end

function InGameState:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "space" then
        for _, entity in ipairs(self.entities) do
            if entity.step then
                entity:step()
            end
        end
    end
end

return InGameState
