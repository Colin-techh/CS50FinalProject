-- Module for HUD (Heads-Up Display) elements
local ui_hud = {}

-- Draw basic HUD info (health, XP, enemy count)
function ui_hud.drawBasic(player, enemyCount)
    love.graphics.print("Health: " .. player.health, 10, 10)
    love.graphics.print("XP: " .. player.xp, 10, 30)
    love.graphics.print("Enemies: " .. enemyCount, 10, 50)
end

-- Draw game timer at top center
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
