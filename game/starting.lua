function love.load()
    love.window.setTitle("My Awesome Game")
    startImage = love.graphics.newImage("startImage.png")
end
function love.draw()
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(startImage, 100, 100)
end