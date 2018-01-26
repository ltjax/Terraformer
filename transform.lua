local class = require 'middleclass'
local Transform = class 'Transform'

function Transform:initialize(sx, sy, dx, dy)
  self.sx = sx
  self.sy = sy
  self.dx = dx
  self.dy = dy
end

function Transform.static:scale(sx, sy)
  return Transform:new(sx, sy, 0, 0)
end

function Transform.static:translate(x, y)
  return Transform:new(1, 1, x, y)
end

function Transform:invert()
  return Transform:new(
    1 / self.sx,
    1 / self.sy,
    -self.dx / self.sx,
    -self.dy / self.sy
  )
end

function Transform:multiply(transform)
  return Transform:new(
    self.sx*transform.sx,
    self.sy*transform.sy,
    self.sx*transform.dx+self.dx,
    self.sy*transform.dy+self.dy)
end

return Transform