function love.load()
    love.window.setTitle("My Awesome Game")
    width, height = love.graphics.getDimensions()
    -- Background image
    background = love.graphics.newImage("assets/background.png")

    isColliding = require("collisions")
    isClicking = require("isClicking")
    isAtTitleScreen = true
    -- Press play
    startImage = love.graphics.newImage("assets/startImage.png")
    playButton = {
        x = width/2 - startImage:getWidth()/8,
        y = height/2 - startImage:getHeight()/8,
        width = startImage:getWidth()/4,
        height = startImage:getHeight()/4
    }

    -- player image
    playerImage = love.graphics.newImage("assets/player1.png")

    --enemy images
    yaleEnemyImage = love.graphics.newImage("assets/enemy1.png")

    key_mappings = {
        up    = {"w", "up"},
        left  = {"a", "left"},
        down  = {"s", "down"},
        right = {"d", "right"},
    }
    yaleEnemy = {
        x = 100,
        y = 100,
        speed = 50
    }
    player = {
        x = 300,
        y = 300,
        speed = 100,
        width = 32,
        height = 32
      }
end

function love.draw()
    if isAtTitleScreen then
        -- Draw play button
        love.graphics.setBlendMode("alpha")
        love.graphics.draw(startImage, width/2 - startImage:getWidth()/8, height/2 - startImage:getHeight()/8, 0, 0.25, 0.25)
        return
    end

    -- Draw the background image at the top-left corner
    love.graphics.draw(background, 0, 0)

    --Draw player
    love.graphics.draw(playerImage, player.x, player.y)

    --Draw enemies
    love.graphics.draw(yaleEnemyImage, yaleEnemy.x, yaleEnemy.y)
end

function love.update(dt)
    if isClicking(playButton) and isAtTitleScreen then
        isAtTitleScreen = false
    end

    require("playerMovement").update(player, yaleEnemy, key_mappings, dt)
end