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
        xp = options.xp or 5,
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
    local player = options and options.player
    local dt = (options and options.dt) or 0
    local enemySet = options and options.enemySet or {}

    if not player then return end -- nothing to do if player missing

    local map = require("map")
    for index, other in pairs(enemySet) do
        if other ~= self then
            local collides = require("collisions")(other, self)
            if collides then
                local dx = self.x - other.x
                local dy = self.y - other.y
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
            self.x = self.x + moveX
            moved = true
        end
        if not blockedY then
            self.y = self.y + moveY
            moved = true
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