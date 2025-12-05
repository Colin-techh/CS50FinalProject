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
    -- support both calling conventions:
    --  1) update(dt)  -- main update loop passes a number
    --  2) update({ dt = dt, player = player }) -- optional table form
    local dt, player
    if type(options) == "table" then
        dt = options.dt
        player = options.player
    else
        dt = options
        -- try to fall back to the global player if present
        player = _G.player
    end
    dt = dt or 0

    self.age = (self.age or 0) + dt
    self.radius = (self.radius or 0) + dt * 10 -- Expand radius over time
    if self.age >= self.lifetime then
        self.isExpired = true
    end

    -- Check if player is inside the smoke cloud
    local dx = player.x + player.width/2 - self.x
    local dy = player.y + player.height/2 - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    if player and type(player.x) == "number" and type(player.y) == "number" and type(player.width) == "number" and type(player.height) == "number" then
        if distance < self.radius then
            player.health = player.health - self.damage * dt
        end
    end
end
function smokeCloud:draw()
    love.graphics.setColor(1, 1, 1, 0.5) -- Set color to white with 50% opacity
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to opaque white 
end