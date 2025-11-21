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
end

yaleEnemy = {
    x = 100,
    y = 100,
    speed = 50
}

local player = {
  x = 300,
  y = 300,
  speed = 100,
  width = 32,
  height = 32
}

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
local key_mappings = {
    up    = "w" OR "up",
    left  = "a" OR "left",
    down  = "s" OR "down",
    right = "d" OR "right"
}

function love.update(dt)
    if isClicking(playButton) and isAtTitleScreen then
        isAtTitleScreen = false
    end

    local input = {x = 0, y = 0}
    local isDown = love.keyboard.isDown

    if isDown(key_mappings.up) then input.y = -1 end
    if isDown(key_mappings.down) then input.y = 1 end
    if isDown(key_mappings.left) then input.x = -1 end
    if isDown(key_mappings.right) then input.x = 1 end

  player.x = player.x + input.x * player.speed * dt
  player.y = player.y + input.y * player.speed * dt

  vX = player.x - yaleEnemy.x
  vY = player.y - yaleEnemy.y

  yaleEnemy.x = yaleEnemy.x + (vX / math.sqrt(vX^2 + vY^2)) * yaleEnemy.speed * dt
  yaleEnemy.y = yaleEnemy.y + (vY / math.sqrt(vX^2 + vY^2)) * yaleEnemy.speed * dt
end