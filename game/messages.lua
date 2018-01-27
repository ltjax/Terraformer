local messages = {
    MINERALS_PRODUCED = "minerals_produced",
    RADIUS_CHANGED = "radius_changed",
}

messages.minerals_produced = function(added_minerals)
    return {type = messages.MINERALS_PRODUCED, added_minerals = added_minerals}
end

messages.radiusChanged = function(terraformer)
    return {type = messages.RADIUS_CHANGED, terraformer = terraformer}
end


return messages
