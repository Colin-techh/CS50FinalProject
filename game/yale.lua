local enemy = require("enemy")
yaleEnemy = {}
setmetatable(yaleEnemy, {__index = enemy})
function yaleEnemy:new(xx, yy)
    local obj = enemy:new({x = xx, y = yy, width = 24, height = 29, speed = 50, damage = 1, knockback = 48, health = 5, imagePath = "assets/enemy1.png"})
    
    setmetatable(obj, {__index = self})
    return obj
end
function yaleEnemy:setPosition(x, y)
    self.x = x
    self.y = y
end

return yaleEnemy