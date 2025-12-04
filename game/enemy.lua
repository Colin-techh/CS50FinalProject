enemy = {}
function enemy:new(xx, yy, width, height, speed, damage, knockback, health, imagePath)
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
return enemy