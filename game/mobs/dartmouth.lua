local enemy = require("enemy")
local projectileClass = require("projectile")
local collides = require("collisions")
dartmouthEnemy = {}
setmetatable(dartmouthEnemy, {__index = enemy})
function dartmouthEnemy:new(xx, yy)
    -- Create dartmouth enemy using enemy base class
    local obj = enemy:new({x=xx, y=yy, width=22, height=28, speed=60, damage=2, knockback=64, health=10, xp=10, imagePath="enemy3"})
    -- Add wobble property for movement pattern (sinucoidal movement because Dartmouth students are perpetually wasted)
    obj.wobble = math.random() * 5
    setmetatable(obj, {__index = dartmouthEnemy})
    return obj
end
function dartmouthEnemy:attack()
    -- throw beer bottle (bottle.png) at player and deal damage on contact

    -- calculate velocity towards player
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist == 0 then dist = 0.0001 end
    local vX = dx / dist
    local vY = dy / dist

    local bottle = projectileClass:new({
        x = self.x + self.width/2,
        y = self.y + self.height/2,
        vX = vX,
        vY = vY,
        speed = 150,
        width = 10,
        height = 30,
        damage = self.damage,
        lifetime = 3,
        imagePath = "bottle"
    })
    -- check collision with player
    function bottle:update(options)
        local dt = options.dt
        self.x = self.x + self.vX * self.speed * dt
        self.y = self.y + self.vY * self.speed * dt
        self.age = self.age + dt
        if self.age >= self.lifetime then self.isExpired = true end
        local isColliding = require("collisions")
        if not self.isExpired and isColliding(self, player) then
            player.health = player.health - self.damage
            self.isExpired = true
        end
    end
    -- draw bottle such that it rotates through the air
    function bottle:draw()
        if not sprites[self.image] then return end
        local angle = math.atan2(self.vY, self.vX) + love.timer.getTime() * 10
        local img = sprites[self.image]
        love.graphics.draw(img, self.x, self.y, angle, 0.5, 0.5, img:getWidth()/2, img:getHeight()/2)
    end
    table.insert(projectiles, bottle)
end
function dartmouthEnemy:update(options)
    -- Simple collision avoidance with other enemies
    player, dt, enemySet = options.player, options.dt, options.enemySet
    for index, enemy in pairs(enemySet) do
        if collides(enemy, self) then
            local dx = self.x - enemy.x
            local dy = self.y - enemy.y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist == 0 then dist = 0.0001 end
            self.x = self.x + (dx / dist) * 1
            self.y = self.y + (dy / dist) * 1
        end
    end

    -- Move towards player with wobble
    local wobble = love.timer.getTime() * 3 + self.wobble
    local wobbleX = math.sin(wobble) * 100
    local wobbleY = math.cos(wobble) * 100
    local vX = (player.x + wobbleX) - self.x
    local vY = (player.y + wobbleY) - self.y
    local distance = math.sqrt(vX^2 + vY^2)
    if distance > 50 then
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