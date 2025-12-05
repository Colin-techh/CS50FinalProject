local enemy = require("enemy")
brownEnemy = {}
setmetatable(brownEnemy, {__index = enemy})
require("smokeCloud")
function brownEnemy:new(xx, yy)
    local obj = enemy:new({x=xx, y=yy, width=21, height=29, speed=100, damage=1, knockback=48, health=2, imagePath="assets/enemy2.png"})
    
    setmetatable(obj, {__index = self})
    return obj
end
function brownEnemy:draw()
    love.graphics.draw(self.image, self.x, self.y)

end
function brownEnemy:attack()
    -- Create smoke cloud that deals DoT to player if they are inside it
    local cloud = smokeCloud:new(self.x + self.width/2, self.y + self.height/2, 2)
    table.insert(projectiles, cloud)
end
function brownEnemy:update(options)
    local player = options and options.player
    local dt = (options and options.dt) or 0
    local enemySet = options and options.enemySet or {}
    if not player then return end

    for index, enemy in pairs(enemySet) do
        if enemy ~= self then
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
    end

    local vX = player.x - self.x
    local vY = player.y - self.y
    local distance = math.sqrt(vX^2 + vY^2)
    if distance > 100 then
        self.x = self.x + (vX / distance) * self.speed * dt
        self.y = self.y + (vY / distance) * self.speed * dt
    end

    -- Every five seconds call attack function with a cooldown
    if not self.attackTimer then
        self.attackTimer = math.random() * 5
    end
    self.attackTimer = self.attackTimer + dt
    if self.attackTimer >= 5 then
        self:attack()
        self.attackTimer = 0
    end

end

return brownEnemy