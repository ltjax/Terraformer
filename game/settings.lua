local settings = {}

settings.volume = 1.0
settings.music_volume = 1.0
settings.ambient_volume = 0.04


function settings:musicVolume()
    return self.volume * self.music_volume
end

function settings:ambientVolume()
    return self.volume * self.ambient_volume
end

return settings
