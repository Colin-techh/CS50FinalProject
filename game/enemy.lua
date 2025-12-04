enemy = {}
function enemy:new(options)
    local xx, yy, width, height, speed, damage, knockback, health, imagePath = options.x, options.y, options.width, options.height, options.speed, options.damage, options.knockback, options.health, options.imagePath
    local obj = {
        x = xx or 0,
        y = yy or 0,
        width = width or 32,
        height = height or 32,
        health = health or 10,
        speed = speed or 50,
        damage = damage or 1,
        knockback = knockback or 20,
        xp = xp or 5;
        image = love.graphics.newImage(imagePath or "assets/enemy1.png")
    }
    obj.__index = self
    setmetatable(obj, {__index = self})
    return obj
end
function enemy:draw()
    love.graphics.draw(self.image, self.x, self.y)
end
function enemy:decreaseHealth(amount)
    self.health = self.health - amount
    if self.health < 0 then
        self.health = 0
    end
end
function enemy:setPosition(x, y)
    self.x = x
    self.y = y
end
function enemy:update(options)
    player, dt, enemySet = options.player, options.dt, options.enemySet
    for index, enemy in pairs(enemySet) do
        local collides = require("collisions")(enemy, self)
        if collides then
            local dx = self.x - enemy.x
            local dy = self.y - enemy.y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist == 0 then dist = 0.0001 end
            self.x = self.x + (dx / dist) * 1
            self.y = self.y + (dy / dist) * 1
        end
    end
    local vX = player.x - self.x
    local vY = player.y - self.y
    local distance = math.sqrt(vX^2 + vY^2)
    if distance > 0 then
        self.x = self.x + (vX / distance) * self.speed * dt
        self.y = self.y + (vY / distance) * self.speed * dt
    end
end
return enemy