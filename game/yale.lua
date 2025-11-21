yaleEnemy = {}
function yaleEnemy:new(x, y)
    local obj = {
        x = x or 0,
        y = y or 0,
        width = 32,
        height = 32,
        speed = 50,
        image = love.graphics.newImage("assets/enemy1.png")
    }
    self.__index = self
    setmetatable(obj, self)
    return obj
end
function yaleEnemy:draw()
    love.graphics.draw(self.image, self.x, self.y)
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