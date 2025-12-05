projectileClass = {}
projectileClass.__index = projectileClass
function projectileClass:new(options)
    local obj = {}
    setmetatable(obj, projectileClass)
    obj.x = options.x or 0
    obj.y = options.y or 0
    obj.vX = options.vX or 0
    obj.vY = options.vY or 0
    obj.speed = options.speed or 200
    obj.width = options.width or 8
    obj.height = options.height or 8
    obj.damage = options.damage or 1
    obj.lifetime = options.lifetime or 2 -- seconds
    obj.age = 0
    obj.isExpired = false
    obj.imagePath = options.imagePath or "assets/sword.png"
    return obj
end
function projectileClass:draw()
    love.graphics.draw(self.image, self.x, self.y)
end
function projectileClass:update(dt)
    self.x = self.x + self.vX * self.speed * dt
    self.y = self.y + self.vY * self.speed * dt
    self.age = self.age + dt
    if self.age >= self.lifetime then
        self.isExpired = true
    end
end

-- Helper: find the closest enemy to a player from an enemySet
function projectileClass.findClosestEnemy(player, enemySet)
    if not enemySet then return nil end
    local best, bestDist = nil, math.huge
    for _, enemy in pairs(enemySet) do
        if enemy and (enemy.health == nil or enemy.health > 0) then
            local ex = (enemy.x or 0) + (enemy.width or 0)/2
            local ey = (enemy.y or 0) + (enemy.height or 0)/2
            local px = player.x + (player.width or 0)/2
            local py = player.y + (player.height or 0)/2
            local dx = ex - px
            local dy = ey - py
            local d = math.sqrt(dx*dx + dy*dy)
            if d < bestDist then bestDist = d; best = enemy end
        end
    end
    return best
end

return projectileClass