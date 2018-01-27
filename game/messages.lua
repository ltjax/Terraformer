local messages = {
    MINERALS_PRODUCED = "minerals_produced"
}

messages.minerals_produced = function(added_minerals)
    return {type = messages.MINERALS_PRODUCED, added_minerals = added_minerals}
end

return messages
