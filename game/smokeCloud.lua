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
        damage = 0.5, -- Damage per second
        lifetime = 5, -- lasts for 5 seconds
        imagePath = nil
    })
    setmetatable(obj, self)
    self.__index = self
    obj.radius = radius
    return obj
end
function smokeCloud:draw()
    love.graphics.setColor(1, 1, 1, 0.5) -- Set color to white with 50% opacity
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to opaque white
    if os.time() % 2 == 0 then
        self.radius = self.radius + 1
    end
end