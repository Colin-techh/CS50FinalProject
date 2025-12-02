enemy = require("enemy")
yaleEnemy = {}
yaleEnemy.__index = yaleEnemy
function yaleEnemy:new(xx, yy)
    local obj = enemy:new(xx, yy, 32, 32, 50,1,48, 5, "assets/enemy1.png")
    setmetatable(self, {__index = enemy})
    setmetatable(obj, {__index = self})
    return obj
end
function yaleEnemy:setPosition(x, y)
    self.x = x
    self.y = y
end
function yaleEnemy:update(player, dt)
    local vX = player.x - self.x
    local vY = player.y - self.y
    local distance = math.sqrt(vX^2 + vY^2)
    if distance > 0 then
        self.x = self.x + (vX / distance) * self.speed * dt
        self.y = self.y + (vY / distance) * self.speed * dt
    end
end