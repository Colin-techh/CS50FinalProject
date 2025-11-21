box = {}
	function box:new(width, height)
		local direction = math.random()*2*math.pi
		local newObject = {x = math.random()*width, y = math.random()*height, Vx = math.cos(direction), Vy = math.sin(direction)}
		self.__index = self
		return setmetatable(newObject, self)
	end
    -- Test
	function box:draw()
		love.graphics.rectangle("fill", self.x,self.y,10,10)
	end
	function box:increase(width, height)
		self.x = self.x + self.Vx
		self.y = self.y + self.Vy

		-- lets use polar coordintes
		local mouseX, mouseY = love.mouse.getPosition()
		local dx = mouseX - self.x
		local dy = mouseY - self.y

		local Vmag = math.sqrt(self.Vx * self.Vx + self.Vy * self.Vy)
		local deltaTheta = math.atan2(self.Vx * dy - self.Vy * dx, self.Vx * dx + self.Vy * dy)
		
		local theta = math.atan2(self.Vy , self.Vx)
		self.Vx = Vmag * math.cos(theta + deltaTheta)
		self.Vy = Vmag * math.sin(theta + deltaTheta)

		
	end