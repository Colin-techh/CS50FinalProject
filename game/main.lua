function love.load()
    -- Background image
    background = love.graphics.newImage("background.png")
end

function love.draw()
    -- Draw the background image at the top-left corner
    love.graphics.draw(background, 0, 0)
end