local Pistol = {}
local projectile = require("projectile")

-- Configurable stats
local fireRate = .5          -- shots per second
local damage = 2            -- damage per bullet
local bulletSpeed = 240     -- pixels/sec
local bulletLifetime = 2.0  -- seconds
local bulletDisplaySize = 12 -- target display size in pixels for bullet
local pistolDisplaySize = 27 -- target pistol image size (75% of previous 36)
local autoFire = false      -- hold mouse to auto-fire

local pistolImage
local bulletImage
local drawScalePistol = 1
local drawScaleBullet = 1

local state = {
    cooldown = 0
}

function Pistol.load()
    if love.filesystem.getInfo("assets/pistol.png") then
        pistolImage = love.graphics.newImage("assets/pistol.png")
    end
    if love.filesystem.getInfo("assets/pistol_bullet.png") then
        bulletImage = love.graphics.newImage("assets/pistol_bullet.png")
    end
    -- compute scales
    if pistolImage then
        local iw, ih = pistolImage:getWidth(), pistolImage:getHeight()
        drawScalePistol = pistolDisplaySize / math.max(iw, ih)
    end
    if bulletImage then
        local iw, ih = bulletImage:getWidth(), bulletImage:getHeight()
        drawScaleBullet = bulletDisplaySize / math.max(iw, ih)
    end
end

local function facingToVector(facing)
    if facing == "right" then return 1, 0, 0 end
    if facing == "left" then return -1, 0, math.pi end
    if facing == "up" then return 0, -1, -math.pi/2 end
    return 0, 1, math.pi/2
end

local function spawnBullet(px, py, vx, vy, player)
    local b = {}
    b.x = px
    b.y = py
    b.vX = vx
    b.vY = vy
    b.speed = bulletSpeed
    b.age = 0
    b.lifetime = bulletLifetime
    b.damage = damage + (player and player.damage or 0)
    b.player = player
    b.width = bulletDisplaySize
    b.height = bulletDisplaySize
    b.image = bulletImage
    b.drawScale = drawScaleBullet
    b.isExpired = false

    function b:update(options)
        -- support both numeric dt (from main loop) and { dt = <num> } table form
        local dt
        if type(options) == "table" then dt = options.dt else dt = options end
        dt = dt or 0
        self.x = self.x + self.vX * self.speed * dt
        self.y = self.y + self.vY * self.speed * dt
        self.age = self.age + dt
        if self.age >= self.lifetime then self.isExpired = true end
        -- collision with enemies
        local isColliding = require("collisions")
        for i, enemy in pairs(enemySet) do
            if not self.isExpired and enemy and (enemy.health == nil or enemy.health > 0) then
                if isColliding(self, enemy) then
                    if enemy.decreaseHealth then enemy:decreaseHealth(self.damage) else enemy.health = (enemy.health or 0) - self.damage end
                    
                    -- apply lifesteal
                    if self.player and self.player.lifesteal and self.player.lifesteal > 0 then
                        self.player.health = math.min(self.player.health + self.damage * self.player.lifesteal, self.player.maxHealth)
                    end
                    
                    -- simple knockback
                    if enemy.takesKnockback == true then
                        local ex = (enemy.x or 0) + (enemy.width or 0)/2
                        local ey = (enemy.y or 0) + (enemy.height or 0)/2
                        local dx = ex - self.x
                        local dy = ey - self.y
                        local dist = math.sqrt(dx*dx + dy*dy)
                        if dist == 0 then dist = 0.0001 end
                        local kb = enemy.knockback or 20
                        enemy.x = enemy.x + (dx / dist) * kb
                        enemy.y = enemy.y + (dy / dist) * kb
                    end
                    self.isExpired = true
                end
            end
        end
    end

    function b:draw()
        if self.image then
            local angle = math.atan2(self.vY, self.vX)
            love.graphics.draw(self.image, self.x, self.y, angle, self.drawScale, self.drawScale, (self.image:getWidth()/2), (self.image:getHeight()/2))
        else
            love.graphics.circle("fill", self.x, self.y, self.width/2)
        end
    end

    table.insert(projectiles, b)
end

function Pistol.tryFire(player)
    if state.cooldown > 0 then return end
    -- compute spawn position at player's center
    local px = player.x + (player.width or 0)/2
    local py = player.y + (player.height or 0)/2
    local vx, vy, _ = facingToVector(player.facing)
    
    -- spawn main bullet
    spawnBullet(px + vx * (player.width/2 + 4), py + vy * (player.height/2 + 4), vx, vy, player)
    
    -- spawn extra projectiles if upgrade active
    local extraCount = player.extraProjectiles or 0
    if extraCount > 0 then
        local angleOffset = math.pi / 6 -- 30 degrees between projectiles
        for i = 1, extraCount do
            local angle = math.atan2(vy, vx)
            local offsetAngle = angle + (angleOffset * i)
            local evx = math.cos(offsetAngle)
            local evy = math.sin(offsetAngle)
            spawnBullet(px + evx * (player.width/2 + 4), py + evy * (player.height/2 + 4), evx, evy, player)
        end
    end
    
    state.cooldown = 1 / fireRate
end

function Pistol.update(player, enemySetLocal, dt)
    -- cooldown
    if state.cooldown > 0 then state.cooldown = math.max(0, state.cooldown - dt) end
    -- auto-fire: when cooldown expired, shoot toward closest enemy if any
    if state.cooldown == 0 and enemySetLocal and next(enemySetLocal) ~= nil then
        local target = projectile.findClosestEnemy(player, enemySetLocal)
        if target then
            local px = player.x + (player.width or 0)/2
            local py = player.y + (player.height or 0)/2
            local tx = (target.x or 0) + (target.width or 0)/2
            local ty = (target.y or 0) + (target.height or 0)/2
            local dx = tx - px
            local dy = ty - py
            local d = math.sqrt(dx*dx + dy*dy)
            if d == 0 then d = 0.0001 end
            local vx, vy = dx / d, dy / d
            
            -- spawn main bullet
            spawnBullet(px + vx * (player.width/2 + 4), py + vy * (player.height/2 + 4), vx, vy, player)
            
            -- spawn extra projectiles if upgrade active
            local extraCount = player.extraProjectiles or 0
            if extraCount > 0 then
                local angleOffset = math.pi / 6 -- 30 degrees between projectiles
                for i = 1, extraCount do
                    local angle = math.atan2(vy, vx)
                    local offsetAngle = angle + (angleOffset * i)
                    local evx = math.cos(offsetAngle)
                    local evy = math.sin(offsetAngle)
                    spawnBullet(px + evx * (player.width/2 + 4), py + evy * (player.height/2 + 4), evx, evy, player)
                end
            end
            
            state.cooldown = 1 / fireRate
        end
    end
end

function Pistol.draw(player)
    -- draw pistol graphic on player according to horizontal facing only
    if not pistolImage then return end
    local px = player.x + (player.width or 0)/2
    local py = player.y + (player.height or 0)/2
    local horiz = player.lastHorizontalFacing or player.facing or "right"
    local offset = 18
    local drawX = px + (horiz == "left" and -offset or offset)
    local scaleX = drawScalePistol * (horiz == "left" and -1 or 1)
    local scaleY = drawScalePistol
    love.graphics.draw(pistolImage, drawX, py, 0, scaleX, scaleY, pistolImage:getWidth()/2, pistolImage:getHeight()/2)
end

return Pistol
