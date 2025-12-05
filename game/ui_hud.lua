-- Module for HUD (Heads-Up Display) elements
local ui_hud = {}

-- Draw basic HUD info (health, XP, player level)
function ui_hud.drawBasic(player)
    -- Need a pretty box for our info :)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 5, 5, 120, 70)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 5, 5, 120, 70)

    love.graphics.print("Health: " .. player.health, 12, 12)
    love.graphics.print("Level:  " .. player.level, 12, 30)
    love.graphics.print("XP:     " .. player.xp,     12, 48)
    
    love.graphics.setColor(1, 1, 1)
end

-- Draw game timer at top center, this is what enemy scaling is based on
function ui_hud.drawTimer(gameTimer, width)
    local minutes = math.floor(gameTimer / 60)
    local seconds = math.floor(gameTimer % 60)
    local timerText = string.format("%02d:%02d", minutes, seconds)
    local font = love.graphics.getFont()
    local timerFont = love.graphics.newFont(32)
    love.graphics.setFont(timerFont)
    local timerWidth = timerFont:getWidth(timerText)
    love.graphics.print(timerText, width/2 - timerWidth/2, 10)
    love.graphics.setFont(font)
end

return ui_hud
