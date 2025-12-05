-- Module for title screen UI and interactions
local ui_titleScreen = {}

-- Initialize play button position
function ui_titleScreen.initButton(width, height, startImage)
    return {
        x = width/2 - startImage:getWidth()/8,
        y = height/2 - startImage:getHeight()/8,
        width = startImage:getWidth()/4,
        height = startImage:getHeight()/4
    }
end

-- Draw title screen
function ui_titleScreen.draw(width, height, startImage, player, background)
    local originalFont = love.graphics.getFont()

    love.graphics.setBlendMode("alpha")
    love.graphics.draw(startImage, width/2 - startImage:getWidth()/8, height/2 - startImage:getHeight()/8, 0, 0.25, 0.25)

    -- Big red title above the start button
    local title = "Yuck Fale"
    local titleFont = love.graphics.newFont(72)
    love.graphics.setFont(titleFont)
    local titleWidth = titleFont:getWidth(title)
    local titleX = width/2 - titleWidth/2
    local titleY = height/2 - startImage:getHeight()/4 - 50
    -- subtle shadow
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.print(title, titleX + 3, titleY + 3)
    love.graphics.setColor(0.9, 0, 0)
    love.graphics.print(title, titleX, titleY)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(originalFont)
    
    -- Center the player for the title screen
    if background then
        player.x = math.floor(background:getWidth() / 2 - (player.width or 0) / 2)
        player.y = math.floor(background:getHeight() / 2 - (player.height or 0) / 2)
    else
        player.x = 300
        player.y = 300
    end
end

return ui_titleScreen
