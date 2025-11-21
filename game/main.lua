function love.load()
    love.window.setTitle("My Awesome Game")
    -- Background image
    background = love.graphics.newImage("assets/background.png")

    -- Press play
    startImage = love.graphics.newImage("startImage.png")
end

function love.draw()
    -- Draw the background image at the top-left corner
    love.graphics.draw(background, 0, 0)

    -- Draw play button
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(startImage, 100, 100, 0, 0.25, 0.25)
end
