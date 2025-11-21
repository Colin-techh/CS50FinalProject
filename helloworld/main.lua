function love.load()
	width, height = love.graphics.getDimensions()
	math.randomseed(os.time())
	require("box")

	-- List of boxes
	boxes = {}
	for i = 1, 50 do
		boxes[i] = box:new(width, height)
	end
end
function love.mousepressed(x, y, button)
	-- On button press, send boxes around in random direction
	for key, value in pairs(boxes) do
		local direction = math.random() * 2 * math.pi
		boxes[key].x = math.cos(direction) * width/2 + x
		boxes[key].y = math.sin(direction) * height/2 + y
	end
	
-- https://github.com/Colin-techh/CS50FinalProject
--         git remote add origin https://github.com/Colin-techh/CS50FinalProject
end
function love.update()
	for key, value in pairs(boxes) do
		boxes[key]:increase(width, height)
	end
end
function love.draw()
	for key, value in pairs(boxes) do
		boxes[key]:draw()
	end
end