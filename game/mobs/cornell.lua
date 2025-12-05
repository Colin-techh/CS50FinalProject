local enemy = require("enemy")
local collides = require("collisions")
cornellEnemy = {}
setmetatable(cornellEnemy, {__index = enemy})
function cornellEnemy:new(xx, yy)
    -- Create cornell enemy using enemy base class
    local obj = enemy:new({x=xx, y=yy, width=84, height=116, speed=20, damage=5, knockback=48, health=12, takesKnockback = false, xp=15, imagePath="enemy4"})
    obj.takesKnockback = false
    setmetatable(obj, {__index = self})
    return obj
end
function cornellEnemy:attack()
    -- Nothing for now, could add a special attack later!
    
end
function cornellEnemy:update(options)
    local player = options and options.player
    local dt = (options and options.dt) or 0
    local enemySet = options and options.enemySet or {}
    if not player then return end

    -- Simple collision avoidance with other enemies
    for index, enemy in pairs(enemySet) do
        if enemy ~= self then
            if collides(enemy, self) then
                local dx = self.x - enemy.x
                local dy = self.y - enemy.y
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist == 0 then dist = 0.0001 end
                self.x = self.x + (dx / dist) * 1
                self.y = self.y + (dy / dist) * 1
            end
        end
    end

    -- Move towards player
    local vX = player.x - self.x
    local vY = player.y - self.y
    local distance = math.sqrt(vX^2 + vY^2)
    if distance > 0 then
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

return cornellEnemy