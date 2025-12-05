enemy = require("enemy")
dartmouth = {}
function dartmouthEnemy:new(xx, yy)
    local obj = enemy:new({x=xx, y=yy, width=22, height=28, speed=80, damage=2, knockback=64, health=10, imagePath="assets/enemy3.png"})
    setmetatable(self, {__index = enemy})
    setmetatable(obj, {__index = self})
    return obj
end