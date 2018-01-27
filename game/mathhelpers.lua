local mathhelpers = {}

function mathhelpers.percentagestring(value)
    return tostring(math.floor(value * 100)) .. "%"
end

function mathhelpers.magnitude(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    return math.sqrt(dx*dx + dy*dy)
end

function mathhelpers.difference(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    return {x=dx, y=dy}
end

function mathhelpers.squared(a)
    return a.x*a.x + a.y*a.y
end

function mathhelpers.length(a)
    return math.sqrt(mathhelpers.squared(a))
end

function mathhelpers.scale(a, s)
    return {x=a.x*s, y=a.y*s}
end

function mathhelpers.add(a, b)
    return {x=a.x+b.x, y=a.y+b.y}
end

function mathhelpers.negate(a)
    return {x=-a.x, y=-a.y}
end

function mathhelpers.distance(a, b)
    return mathhelpers.length(mathhelpers.difference(a, b))
end

function mathhelpers.floor(a)
    return {x=math.floor(a.x), y=math.floor(a.y)}
end

return mathhelpers
