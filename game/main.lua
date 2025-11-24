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
    
    key_mappings = {
        up    = {"w", "up"},
        left  = {"a", "left"},
        down  = {"s", "down"},
        right = {"d", "right"},
    }
    require("yale")
    yalie = yaleEnemy:new(100, 100)
        player = { 
                x = 300,
                y = 300,
                speed = 100,
                width = 32,
                height = 32,
                health = 3,
                isInvulnerable = false,
                invulnTimer = 0,
                invulnDuration = 1.0
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
    -- Flash player while invulnerable
    if player.isInvulnerable then
        local flashOn = math.floor(love.timer.getTime() * 10) % 2 == 0
        if flashOn then
            love.graphics.setColor(1, 1, 1, 0.35)
        end
    end

    love.graphics.draw(playerImage, player.x, player.y)
    love.graphics.setColor(1, 1, 1, 1)

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

    camera:lookAt(player.x, player.y)
    if isAtTitleScreen then
        return
    end

    -- update player movement and handle knockback/damage inside the module
    require("playerMovement").update(player, yalie, key_mappings, dt)

    -- enemy AI update
    yalie:update(player, dt)

    -- handle death / reset here so gameplay module doesn't need global state
    if player.health <= 0 then
        isAtTitleScreen = true
        player.health = 3
        player.x = 300
        player.y = 300
        yalie:setPosition(100, 100)
    end
end