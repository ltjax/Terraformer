local mathhelpers = {}

function mathhelpers.percentagestring(value)
    return tostring(math.floor(value * 100)) .. "%"
end

return mathhelpers
