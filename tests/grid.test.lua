
describe('grid', function()
    local Grid = require('grid')
    it('finds previously set objects', function()
        local grid = Grid:new()
        local myObject = {test="test!"}
        grid:set(3, 3, myObject)
        assert.same(grid:get(3, 3), myObject)
    end)
end)