local enemy = {}
local map = require("map")
-- Base enemy class that all enemy types inherit from
function enemy:new(options)
    local obj = {
        x = options.x or 0,
        y = options.y or 0,
        width = options.width or 32,
        height = options.height or 32,
        health = options.health or 10,
        speed = options.speed or 50,
        damage = options.damage or 1,
        knockback = options.knockback or 20,
        xp = options.xp or 5,
        takesKnockback = options.takesKnockback or true,
        image = options.imagePath or "enemy1"
    }
    setmetatable(obj, {__index = enemy})
    return obj
end
function enemy:draw()
    if not sprites[self.image] then
        return
    end
    love.graphics.draw(sprites[self.image], self.x, self.y)
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
    local player = options and options.player
    local dt = (options and options.dt) or 0
    local enemySet = options and options.enemySet or {}

    if not player then return end -- nothing to do if player missing

    -- Bump into other enemies to avoid overlapping
    for index, other in pairs(enemySet) do
        if other ~= self then
            local collides = require("collisions")(other, self)
            if collides then
                local dx = self.x - other.x
                local dy = self.y - other.y
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist == 0 then dist = 0.0001 end
                local newX = self.x + (dx / dist) * 1
                local newY = self.y + (dy / dist) * 1
                -- apply push-back with boundary checks
                if newX >= 0 and newX + (self.width or 0) <= 5000 then
                    self.x = newX
                end
                if newY >= 0 and newY + (self.height or 0) <= 5000 then
                    self.y = newY
                end
            end
        end
    end

    -- Move towards player with collision avoidance
    local vX = player.x - self.x
    local vY = player.y - self.y
    local distance = math.sqrt(vX^2 + vY^2)
    if distance > 0 then
        local moveX = (vX / distance) * self.speed * dt
        local moveY = (vY / distance) * self.speed * dt
        -- axis-separated moves checking map collision
        local testBoxX = { x = self.x + moveX, y = self.y, width = self.width or 0, height = self.height or 0 }
        local blockedX = map:collidesWithBlocking(testBoxX)
        local testBoxY = { x = self.x, y = self.y + moveY, width = self.width or 0, height = self.height or 0 }
        local blockedY = map:collidesWithBlocking(testBoxY)

        local moved = false
        if not blockedX then
            local newX = self.x + moveX
            -- check boundary (0 to 5000)
            if newX >= 0 and newX + (self.width or 0) <= 5000 then
                self.x = newX
                moved = true
            end
        end
        if not blockedY then
            local newY = self.y + moveY
            -- check boundary (0 to 5000)
            if newY >= 0 and newY + (self.height or 0) <= 5000 then
                self.y = newY
                moved = true
            end
        end

        -- simple detour: if both axes blocked attempt a perpendicular step to go around
        if not moved then
            local perpX = -moveY
            local perpY = moveX
            local testBoxPerp1 = { x = self.x + perpX, y = self.y + perpY, width = self.width or 0, height = self.height or 0 }
            if not map:collidesWithBlocking(testBoxPerp1) then
                self.x = self.x + perpX
                self.y = self.y + perpY
            else
                -- try the other side
                local testBoxPerp2 = { x = self.x - perpX, y = self.y - perpY, width = self.width or 0, height = self.height or 0 }
                if not map:collidesWithBlocking(testBoxPerp2) then
                    self.x = self.x - perpX
                    self.y = self.y - perpY
                end
            end
        end
    end
end
return enemy