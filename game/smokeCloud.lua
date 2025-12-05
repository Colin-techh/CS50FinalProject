projectileClass = require("projectile")
smokeCloud = {}
function smokeCloud:new(x, y, radius)
    local obj = projectileClass:new({
        x = x,
        y = y,
        vX = 0,
        vY = 0,
        speed = 0,
        width = radius * 2,
        height = radius * 2,
        isExpired = false,
        damage = 0.5, -- Damage per second
        lifetime = 3, -- lasts for 5 seconds
        imagePath = nil
    })
    self.__index = self
    setmetatable(obj, self)
    
    obj.radius = radius
    return obj
end
function smokeCloud:update(dt)
    self.age = self.age + dt
    self.radius = self.radius + dt * 10 -- Expand radius over time
    if self.age >= self.lifetime then
    self.isExpired = true
    end
end
function smokeCloud:draw()
    love.graphics.setColor(1, 1, 1, 0.5) -- Set color to white with 50% opacity
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to opaque white 
end