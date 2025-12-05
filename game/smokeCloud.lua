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
        lifetime = 8, -- lasts for 5 seconds
        imagePath = nil
    })
    self.__index = self
    setmetatable(obj, self)
    
    obj.radius = radius
    return obj
end
function smokeCloud:update(options)
    local dt,player = options.dt, options.player
    self.age = self.age + dt
    self.radius = self.radius + dt * 10 -- Expand radius over time
    if self.age >= self.lifetime then
        self.isExpired = true
    end

    -- Check if player is inside the smoke cloud
    local dx = player.x + player.width/2 - self.x
    local dy = player.y + player.height/2 - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    if distance < self.radius then
        player.health = player.health - self.damage * dt
    end
end
function smokeCloud:draw()
    love.graphics.setColor(1, 1, 1, 0.5) -- Set color to white with 50% opacity
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to opaque white 
end