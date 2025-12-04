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
    obj.image = love.graphics.newImage(options.imagePath or "assets/projectile.png")
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