local messages = {
    MINERALS_PRODUCED = "minerals_produced",
    RADIUS_CHANGED = "radius_changed",
    TOTAL_TERRAFORMED_CHANGED = "total_terraformed_changed",
}

messages.minerals_produced = function(added_minerals)
    return {type = messages.MINERALS_PRODUCED, added_minerals = added_minerals}
end

messages.radiusChanged = function(terraformer)
    return {type = messages.RADIUS_CHANGED, terraformer = terraformer}
end

messages.totalTerraformedChanged = function(total, delta)
    return {type = messages.TOTAL_TERRAFORMED_CHANGED, total=total, delta=delta}
end

return messages
