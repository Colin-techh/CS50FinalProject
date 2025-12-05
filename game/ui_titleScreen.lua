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
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(startImage, width/2 - startImage:getWidth()/8, height/2 - startImage:getHeight()/8, 0, 0.25, 0.25)
    
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
