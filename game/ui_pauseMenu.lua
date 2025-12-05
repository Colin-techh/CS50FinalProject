-- Module for pause menu UI and interactions
local ui_pauseMenu = {}

-- Initialize pause menu button positions
function ui_pauseMenu.initButtons(width, height)
    return {
        continue = {
            x = width/2 - 100,
            y = height/2 - 90,
            width = 200,
            height = 50
        },
        newGame = {
            x = width/2 - 100,
            y = height/2 - 20,
            width = 200,
            height = 50
        },
        quit = {
            x = width/2 - 100,
            y = height/2 + 50,
            width = 200,
            height = 50
        }
    }
end

-- Calculate total damage based on weapon and player stats
local function calculateTotalDamage(player, selectedWeapon)
    local weaponBaseDamage = 0
    if selectedWeapon == "sword" then
        weaponBaseDamage = 5
    elseif selectedWeapon == "boomerang" then
        weaponBaseDamage = 2
    elseif selectedWeapon == "pistol" then
        weaponBaseDamage = 2
    end
    return weaponBaseDamage + (player.damage or 0)
end

-- Draw pause menu overlay
function ui_pauseMenu.draw(width, height, buttons, player, selectedWeapon)
    -- Save current font to restore at the end
    local originalFont = love.graphics.getFont()
    
    -- Semi-transparent dark overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(1, 1, 1, 1)
    
    -- "Game Paused" title
    local titleFont = love.graphics.newFont(48)
    love.graphics.setFont(titleFont)
    local pauseText = "Game Paused"
    local pauseWidth = titleFont:getWidth(pauseText)
    love.graphics.print(pauseText, width/2 - pauseWidth/2, buttons.continue.y - 70)
    
    -- Stats table on the left
    local statsFont = love.graphics.newFont(18)
    love.graphics.setFont(statsFont)
    local statsX = 50
    local statsY = height/2 - 150
    local lineHeight = 25
    
    -- Stats title
    love.graphics.setColor(1, 1, 0.5, 1)
    love.graphics.print("Player Stats:", statsX, statsY)
    love.graphics.setColor(1, 1, 1, 1)
    statsY = statsY + lineHeight + 5
    
    -- Calculate stats
    local totalDamage = calculateTotalDamage(player, selectedWeapon)
    local attackSpeedMult = player.attackSpeedMultiplier or 1
    local attackSpeedBonus = (1 / attackSpeedMult - 1) * 100
    
    -- Display upgrade stats
    local stats = {
        {"Max Health", player.maxHealth or 3},
        {"Damage", totalDamage},
        {"Attack Speed", string.format("+%.0f%% faster", attackSpeedBonus)},
        {"Speed", math.floor((player.speed or 100))},
        {"XP Multiplier", string.format("%.2fx", player.xpMultiplier or 1)},
        {"Crit Chance", string.format("%.0f%%", (player.criticalHitChance or 0) * 100)},
        {"Lifesteal", string.format("%.0f%%", (player.lifesteal or 0) * 100)},
        {"Health Regen", (player.healthRegen or 0) .. " HP/10s"},
        {"Extra Projectiles", player.extraProjectiles or 0},
        {"Knockback Resist", string.format("%.0f%%", (player.knockbackResist or 0) * 100)},
        {"Invuln Duration", string.format("%.2fs", player.invulnDuration or 1)}
    }
    
    for _, stat in ipairs(stats) do
        love.graphics.print(stat[1] .. ": " .. stat[2], statsX, statsY)
        statsY = statsY + lineHeight
    end
    
    -- Draw buttons
    local buttonFont = love.graphics.newFont(24)
    love.graphics.setFont(buttonFont)
    
    -- Continue button
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", buttons.continue.x, buttons.continue.y, buttons.continue.width, buttons.continue.height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", buttons.continue.x, buttons.continue.y, buttons.continue.width, buttons.continue.height)
    local continueText = "Continue"
    local continueWidth = buttonFont:getWidth(continueText)
    love.graphics.print(continueText, buttons.continue.x + buttons.continue.width/2 - continueWidth/2, buttons.continue.y + 12)

    -- New Game button
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", buttons.newGame.x, buttons.newGame.y, buttons.newGame.width, buttons.newGame.height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", buttons.newGame.x, buttons.newGame.y, buttons.newGame.width, buttons.newGame.height)
    local newGameText = "New Game"
    local newGameWidth = buttonFont:getWidth(newGameText)
    love.graphics.print(newGameText, buttons.newGame.x + buttons.newGame.width/2 - newGameWidth/2, buttons.newGame.y + 12)
    
    -- Quit button
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", buttons.quit.x, buttons.quit.y, buttons.quit.width, buttons.quit.height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", buttons.quit.x, buttons.quit.y, buttons.quit.width, buttons.quit.height)
    local quitText = "Quit"
    local quitWidth = buttonFont:getWidth(quitText)
    love.graphics.print(quitText, buttons.quit.x + buttons.quit.width/2 - quitWidth/2, buttons.quit.y + 12)
    
    -- Restore original font and color
    love.graphics.setFont(originalFont)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Handle pause menu interactions
-- Returns: "continue", "newGame", "quit", or nil
function ui_pauseMenu.handleClick(buttons, isClicking)
    if isClicking(buttons.continue) then
        return "continue"
    end
    if isClicking(buttons.newGame) then
        return "newGame"
    end
    if isClicking(buttons.quit) then
        return "quit"
    end
    return nil
end

return ui_pauseMenu
