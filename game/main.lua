-- Library usage
local Camera = require "libs.hump-master.camera"

camera = Camera(0, 0)

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
    -- yaleEnemyImage = love.graphics.newImage("assets/enemy1.png")

    
    key_mappings = {
        up    = {"w", "up"},
        left  = {"a", "left"},
        down  = {"s", "down"},
        right = {"d", "right"},
    }
    -- yaleEnemy = {
    --     x = 100,
    --     y = 100,
    --     speed = 50
    -- }
    require("yale")
    yalie = yaleEnemy:new(100, 100)
    player = { 
        x = 300,
        y = 300,
        speed = 100,
        width = 32,
        height = 32,
        health = 3
      }

end

function love.draw()
    if isAtTitleScreen then
        -- Draw play button
        love.graphics.setBlendMode("alpha")
        love.graphics.draw(startImage, width/2 - startImage:getWidth()/8, height/2 - startImage:getHeight()/8, 0, 0.25, 0.25)
        player.x = 300
        player.y = 300
        yalie:setPosition(100, 100)
        return
    end

    -- Attach camera so the view follows the player
    camera:attach()

    -- Draw the background image at the top-left corner (world coordinates)
    love.graphics.draw(background, 0, 0)

    -- Draw player and enemies in world space
    love.graphics.draw(playerImage, player.x, player.y)
    -- love.graphics.draw(yaleEnemyImage, yaleEnemy.x, yaleEnemy.y)
    yalie:draw()
    camera:detach()

    -- Draw HUD elements in screen space
    love.graphics.print("Health: " .. player.health, 10, 10)
    
end

function love.update(dt)
    if isClicking(playButton) and isAtTitleScreen then
        isAtTitleScreen = false
    end

    if(require("collisions")(player, yalie) and not isAtTitleScreen) then
        player.health = player.health - 1
        player.x = 300
        player.y = 300
        if(player.health <= 0) then
            isAtTitleScreen = true
            player.health = 3
        end
    end

    camera:lookAt(player.x, player.y)
        if isAtTitleScreen then
            return
        end
    require("playerMovement").update(player, yaleEnemy, key_mappings, dt)
    yalie:update(player, dt)
end