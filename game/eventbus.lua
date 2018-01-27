local class = require 'middleclass'

local EventBus = class 'EventBus'

function EventBus:initialize()
  self.listeners = {}
  self.token = 0
end

function EventBus:subscribe(type, callback)
  if self.listeners[type]==nil then
    self.listeners[type] = {}
  end

  self.token = self.token + 1
  table.insert(self.listeners[type], callback)
end

function EventBus:dispatch(message)
    if not self.listeners[message.type] then
        return
    end
    
    for _, callback in ipairs(self.listeners[message.type]) do
        callback(message)
    end
end

return EventBus
