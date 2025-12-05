-- Library usage
local Camera = require "libs.hump-master.camera"
local gameRun = require("gameRun")
local uiWeaponSelection = require("ui_weaponSelection")
local uiUpgradeMenu = require("ui_upgradeMenu")

camera = Camera(0, 0)

local player = require("player")

function love.load()
    love.window.setTitle("My Awesome Game")
    width, height = love.graphics.getDimensions()
    -- Background image
    background = love.graphics.newImage("assets/background.png")

    -- Call .newImage on all sprites
    sprites = {
        player = love.graphics.newImage("assets/player1.png"),
        sword = love.graphics.newImage("assets/sword.png"),
        boomerang = love.graphics.newImage("assets/boomerang.png"),
        pistol = love.graphics.newImage("assets/pistol.png"),
        bottle = love.graphics.newImage("assets/bottle.png"),
        enemy1 = love.graphics.newImage("assets/enemy1.png"),
        enemy2 = love.graphics.newImage("assets/enemy2.png"),
        enemy3 = love.graphics.newImage("assets/enemy3.png"),
        enemy4 = love.graphics.newImage("assets/enemy4.png"),
        pistol_bullet = love.graphics.newImage("assets/pistol_bullet.png"),
        tree = love.graphics.newImage("assets/tree.png"),
        rock = love.graphics.newImage("assets/rock.png"),
        grass = love.graphics.newImage("assets/grass.png")
    }


    isColliding = require("collisions")
    isClicking = require("isClicking")
    isAtTitleScreen = true
    isChoosingWeapon = false
    isPaused = false
    selectedWeapon = nil -- "sword" | "boomerang" | "pistol"
    weaponSelectionBuffer = 0
    -- Press play
    startImage = love.graphics.newImage("assets/startImage.png")
    playButton = {
        x = width/2 - startImage:getWidth()/8,
        y = height/2 - startImage:getHeight()/8,
        width = startImage:getWidth()/4,
        height = startImage:getHeight()/4
    }
    
    -- Pause menu buttons
    pauseContinueButton = {
        x = width/2 - 100,
        y = height/2 - 90,
        width = 200,
        height = 50
    }
    pauseNewGameButton = {
        x = width/2 - 100,
        y = height/2 - 20,
        width = 200,
        height = 50
    }
    pauseQuitButton = {
        x = width/2 - 100,
        y = height/2 + 50,
        width = 200,
        height = 50
    }

    -- sword (automatic slash)
    sword = require("sword")
    sword.load()
        -- boomerang (auto-launch toward nearest enemy when returned)
        boomerang = require("boomerang")
        boomerang.load()
    -- pistol (player weapon)
    pistol = require("pistol")
    pistol.load()

    -- Start game timer
    gameTimer = 0

    -- UI selection images (reuse assets)
    selectionSwordImage = sprites["sword"]
    selectionBoomerangImage = sprites["boomerang"]
    selectionPistolImage = sprites["pistol"]
    
    key_mappings = {
        up    = {"w", "up"},
        left  = {"a", "left"},
        down  = {"s", "down"},
        right = {"d", "right"},
    }
    -- Enemy setup
    require("yale")
    require("brown")
    require("dartmouth")
    require("cornell")
    enemySet = {}
    projectiles = {}
    map = require("map")

    -- Spawning enemy setup
    spawningFunctions = require("spawning")
    -- Player
    player.load()

    

    -- initial world created when the player actually starts a run (newGame)
end

-- start a fresh run: regenerate map, reset enemies/projectiles, center player and spawn enemies
function newGame()
    -- Reset game timer
    gameTimer = 0
    
    gameRun.newRun({
        background = background,
        map = map,
        player = player,
        enemySet = enemySet,
        projectiles = projectiles,
        yaleEnemy = yaleEnemy,
        brownEnemy = brownEnemy,
        dartmouthEnemy = dartmouthEnemy
    })
end

function love.draw()

    if isAtTitleScreen then
        -- Draw play button
        love.graphics.setBlendMode("alpha")
        love.graphics.draw(startImage, width/2 - startImage:getWidth()/8, height/2 - startImage:getHeight()/8, 0, 0.25, 0.25)
        -- center the player for the title screen (and when returning to title)
        if background then
            player.x = math.floor(background:getWidth() / 2 - (player.width or 0) / 2)
            player.y = math.floor(background:getHeight() / 2 - (player.height or 0) / 2)
        else
            player.x = 300
            player.y = 300
        end
        
        return
    end

    -- weapon selection UI (screen-space)
    if isChoosingWeapon and weaponChoices and weaponChoiceRects then
        uiWeaponSelection.draw(width, height, weaponChoiceRects)
        return
    end

    -- Attach camera so the view follows the player
    camera:attach()

    -- Draw the background image at the top-left corner (world coordinates)
    love.graphics.draw(background, 0, 0)
    -- draw background map elements (grass) underneath characters
    if map and map.drawGrass then map:drawGrass() end

    -- Draw player and enemies in world space

    -- Draw player
    player:draw()

    -- draw selected weapon on player (only one enabled)
    if selectedWeapon == "pistol" then
        pistol.draw(player)
    end
    if selectedWeapon == "sword" then
        sword.draw(player)
    end
    if selectedWeapon == "boomerang" then
        boomerang.draw(player, enemySet)
    end
    love.graphics.setColor(1, 1, 1, 1)

    for index, enemy in pairs(enemySet) do
        enemy:draw()
    end
    for index, projectile in pairs(projectiles) do
        -- skip extra boomerang objects (they're drawn in boomerang.draw)
        if not projectile.isExtraProjectile then
            projectile:draw()
        end
    end
    
    -- draw blocking map elements (rocks / trees) above characters
    if map and map.drawBlocking then map:drawBlocking() end
    camera:detach()

    -- Draw HUD elements in screen space
    love.graphics.print("Health: " .. player.health, 10, 10)
    love.graphics.print("XP: " .. player.xp, 10, 30)
    love.graphics.print("Enemies: " .. #enemySet, 10, 50)
    
    -- Draw game timer at top center
    local minutes = math.floor(gameTimer / 60)
    local seconds = math.floor(gameTimer % 60)
    local timerText = string.format("%02d:%02d", minutes, seconds)
    local font = love.graphics.getFont()
    local timerFont = love.graphics.newFont(32)
    love.graphics.setFont(timerFont)
    local timerWidth = timerFont:getWidth(timerText)
    love.graphics.print(timerText, width/2 - timerWidth/2, 10)
    love.graphics.setFont(font)
    
    -- Draw upgrade menu overlay when active
    if showUpgradeMenu and upgradeChoices then
        upgradeChoiceRects = uiUpgradeMenu.draw(width, height, upgradeChoices)
    end
    
    -- Draw pause menu overlay when active
    if isPaused then
        -- Semi-transparent dark overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1, 1, 1, 1)
        
        -- "Game Paused" title
        local titleFont = love.graphics.newFont(48)
        love.graphics.setFont(titleFont)
        local pauseText = "Game Paused"
        local pauseWidth = titleFont:getWidth(pauseText)
        -- place the title above the Continue button
        love.graphics.print(pauseText, width/2 - pauseWidth/2, pauseContinueButton.y - 70)
        
        -- Stats table on the left
        love.graphics.setFont(font)
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
        
        -- Calculate actual damage based on selected weapon
        local weaponBaseDamage = 0
        if selectedWeapon == "sword" then
            weaponBaseDamage = 5
        elseif selectedWeapon == "boomerang" then
            weaponBaseDamage = 2
        elseif selectedWeapon == "pistol" then
            weaponBaseDamage = 2
        end
        local totalDamage = weaponBaseDamage + (player.damage or 0)
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
        
        -- Continue button
        love.graphics.setFont(font)
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", pauseContinueButton.x, pauseContinueButton.y, pauseContinueButton.width, pauseContinueButton.height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", pauseContinueButton.x, pauseContinueButton.y, pauseContinueButton.width, pauseContinueButton.height)
        local buttonFont = love.graphics.newFont(24)
        love.graphics.setFont(buttonFont)
        local continueText = "Continue"
        local continueWidth = buttonFont:getWidth(continueText)
        love.graphics.print(continueText, pauseContinueButton.x + pauseContinueButton.width/2 - continueWidth/2, pauseContinueButton.y + 12)

        -- New Game button
        love.graphics.setFont(font)
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", pauseNewGameButton.x, pauseNewGameButton.y, pauseNewGameButton.width, pauseNewGameButton.height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", pauseNewGameButton.x, pauseNewGameButton.y, pauseNewGameButton.width, pauseNewGameButton.height)
        love.graphics.setFont(buttonFont)
        local newGameText = "New Game"
        local newGameWidth = buttonFont:getWidth(newGameText)
        love.graphics.print(newGameText, pauseNewGameButton.x + pauseNewGameButton.width/2 - newGameWidth/2, pauseNewGameButton.y + 12)
        
        -- Quit button
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", pauseQuitButton.x, pauseQuitButton.y, pauseQuitButton.width, pauseQuitButton.height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", pauseQuitButton.x, pauseQuitButton.y, pauseQuitButton.width, pauseQuitButton.height)
        local quitText = "Quit"
        local quitWidth = buttonFont:getWidth(quitText)
        love.graphics.print(quitText, pauseQuitButton.x + pauseQuitButton.width/2 - quitWidth/2, pauseQuitButton.y + 12)
        
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.keypressed(key)
    -- weapon selection via number keys
    if isChoosingWeapon and weaponChoiceRects and weaponChoices then
        -- block key selection while the initial click buffer is active
            if not weaponSelectionBuffer or weaponSelectionBuffer <= 0 then
                local sel = uiWeaponSelection.handleKey(key, weaponChoiceRects, weaponSelectionBuffer)
                if sel then
                    selectedWeapon = sel
                    isChoosingWeapon = false
                    weaponChoiceRects = nil
                    weaponChoices = nil
                    newGame()
                    return
                end
        end
    end
    -- allow number key selection when upgrade menu is active
    if showUpgradeMenu and upgradeChoices then
        -- accept both main row and numpad keys ("1", "2", "3")
            local chosen = uiUpgradeMenu.handleKey(key, upgradeChoices)
            if chosen and chosen.apply then
                chosen.apply(player)
                showUpgradeMenu = false
                upgradeChoices = nil
                upgradeChoiceRects = nil
                return
            end
    end
    
    -- Toggle pause with Escape key
    if key == "escape" and not isAtTitleScreen and not isChoosingWeapon and not showUpgradeMenu then
        isPaused = not isPaused
    end
end

function love.update(dt)
    if isClicking(playButton) and isAtTitleScreen then
        -- go to weapon selection screen before starting the game
        isAtTitleScreen = false
        isChoosingWeapon = true
        selectedWeapon = nil
        weaponSelectionBuffer = 1.0 -- seconds to ignore immediate selection clicks/keys
        weaponChoices, weaponChoiceRects = uiWeaponSelection.buildChoices(width, height, selectionSwordImage, selectionBoomerangImage, selectionPistolImage)
    end

    if isAtTitleScreen then
        return
    end
    
    -- Handle pause menu clicks
    if isPaused then
        if isClicking(pauseContinueButton) then
            isPaused = false
            return
        end
        if isClicking(pauseNewGameButton) then
            isPaused = false
            isAtTitleScreen = false
            isChoosingWeapon = true
            selectedWeapon = nil
            weaponSelectionBuffer = 1.0
            weaponChoices, weaponChoiceRects = uiWeaponSelection.buildChoices(width, height, selectionSwordImage, selectionBoomerangImage, selectionPistolImage)
        end
        if isClicking(pauseQuitButton) then
            love.event.quit()
        end
        return
    end

    -- if weapon selection is active, skip world updates and process selection input here
    if isChoosingWeapon then
        -- tick down the selection buffer so accidental input right after pressing Start is ignored
        if weaponSelectionBuffer and weaponSelectionBuffer > 0 then
            weaponSelectionBuffer = math.max(0, weaponSelectionBuffer - dt)
        end
        -- process clicks immediately (only after the buffer has expired)
        local sel = uiWeaponSelection.handleMouse(weaponChoiceRects, weaponSelectionBuffer, isClicking)
        if sel then
            selectedWeapon = sel
            isChoosingWeapon = false
            weaponChoiceRects = nil
            weaponChoices = nil
            newGame()
        end
        -- do not run any other game updates while choosing the starting weapon
        return
    end

    -- If upgrade menu is open, freeze the world (no camera movement, enemies, projectiles, or player updates)
    if not showUpgradeMenu and not isPaused then
        camera:lookAt(player.x, player.y)
        
        -- update health regeneration
        if player.healthRegen and player.healthRegen > 0 then
            player.healthRegenTimer = (player.healthRegenTimer or 0) + dt
            if player.healthRegenTimer >= (player.healthRegenInterval or 10) then
                player.health = math.min(player.health + player.healthRegen, player.maxHealth)
                player.healthRegenTimer = 0
            end
        end
        
        -- update player movement
        require("playerMovement").update(player, key_mappings, dt)
        -- update only the selected weapon
        if selectedWeapon == "sword" then
            sword.update(player, enemySet, dt)
        end
        if selectedWeapon == "boomerang" then
            boomerang.update(player, enemySet, dt)
        end
        if selectedWeapon == "pistol" then
            pistol.update(player, enemySet, dt)
        end
        -- update colision and handle damage
        for index, enemy in pairs(enemySet) do
            require("handleDamage")({player = player, enemy = enemy})
        end
        -- enemy AI update and death handling
        for index = #enemySet, 1, -1 do
            local enemy = enemySet[index]
            if enemy then
                enemy:update({player = player, dt = dt, enemySet = enemySet})
                if (enemy.health or 0) <= 0 then
                    table.remove(enemySet, index)
                    if player and player.addXP then
                        player:addXP(enemy.xp)
                    else
                        player.xp = player.xp + (enemy.xp or 0)
                    end
                end
            end
        end

        -- projectile updates
        for index = #projectiles, 1, -1 do
            local projectile = projectiles[index]
            if projectile then
                -- skip extra boomerang objects (they're handled in boomerang.update)
                if not projectile.isExtraProjectile then
                    projectile:update({dt=dt, player=player})
                    if projectile.isExpired then
                        table.remove(projectiles, index)
                    end
                end
            end
        end

        -- update game timer
        gameTimer = gameTimer + dt

        -- spawn enemies
        spawningFunctions.spawnEnemy({
            gameTime = math.floor(gameTimer),
            enemySet = enemySet,
            yaleEnemy = yaleEnemy,
            brownEnemy = brownEnemy,
            dartmouthEnemy = dartmouthEnemy,
            cornellEnemy = cornellEnemy,
            findSpawnSafe = gameRun.makeSpawnFinder(map, background:getWidth(), background:getHeight(), player)
        })
    end

    player:update()

    -- handle upgrade menu input (click to choose)
    if showUpgradeMenu and upgradeChoiceRects and upgradeChoices then
        local chosen = uiUpgradeMenu.handleMouse(upgradeChoiceRects, upgradeChoices, isClicking)
        if chosen and chosen.apply then
            chosen.apply(player)
            showUpgradeMenu = false
            upgradeChoices = nil
            upgradeChoiceRects = nil
        end
    end
end

function addEnemy(enemy)
    table.insert(enemySet, enemy)
end