-- Library usage
local Camera = require "libs.hump-master.camera"
local gameRun = require("gameRun")
local gameState = require("gameState")
local gameUpdate = require("gameUpdate")
local gameDraw = require("gameDraw")
local uiWeaponSelection = require("ui_weaponSelection")
local uiUpgradeMenu = require("ui_upgradeMenu")
local uiTitleScreen = require("ui_titleScreen")
local uiPauseMenu = require("ui_pauseMenu")
local uiHud = require("ui_hud")

camera = Camera(0, 0)
player = require("player")

function love.load()
    love.window.setTitle("My Awesome Game")
    width, height = love.graphics.getDimensions()
    
    -- Background image
    background = love.graphics.newImage("assets/background.png")

    -- Load sprites (kept global for other modules)
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
    
    -- Initialize game state
    local stateData = gameState.init()
    isAtTitleScreen = stateData.isAtTitleScreen
    isChoosingWeapon = stateData.isChoosingWeapon
    isPaused = stateData.isPaused
    selectedWeapon = stateData.selectedWeapon
    weaponSelectionBuffer = stateData.weaponSelectionBuffer
    showUpgradeMenu = stateData.showUpgradeMenu
    upgradeChoices = stateData.upgradeChoices
    upgradeChoiceRects = stateData.upgradeChoiceRects
    weaponChoices = stateData.weaponChoices
    weaponChoiceRects = stateData.weaponChoiceRects
    gameTimer = stateData.gameTimer
    enemySet = stateData.enemySet
    projectiles = stateData.projectiles
    
    -- UI elements
    startImage = love.graphics.newImage("assets/startImage.png")
    playButton = uiTitleScreen.initButton(width, height, startImage)
    pauseButtons = uiPauseMenu.initButtons(width, height)
    pauseContinueButton = pauseButtons.continue
    pauseNewGameButton = pauseButtons.newGame
    pauseQuitButton = pauseButtons.quit

    -- Weapons
    sword = require("sword")
    sword.load()
    boomerang = require("boomerang")
    boomerang.load()
    pistol = require("pistol")
    pistol.load()

    -- Key mappings
    key_mappings = {
        up    = {"w", "up"},
        left  = {"a", "left"},
        down  = {"s", "down"},
        right = {"d", "right"},
    }
    
    -- Enemies
    require("yale")
    require("brown")
    require("dartmouth")
    require("cornell")
    map = require("map")
    spawningFunctions = require("spawning")
    
    -- Player
    player.load()
end

function newGame()
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
        uiTitleScreen.draw(width, height, startImage, player, background)
        return
    end

    if isChoosingWeapon and weaponChoices and weaponChoiceRects then
        uiWeaponSelection.draw(width, height, weaponChoiceRects)
        return
    end

    -- Draw game world
    gameDraw.drawWorld({
        camera = camera,
        background = background,
        map = map,
        player = player,
        selectedWeapon = selectedWeapon,
        enemySet = enemySet,
        projectiles = projectiles,
        sword = sword,
        boomerang = boomerang,
        pistol = pistol
    })

    -- Draw HUD
    uiHud.drawBasic(player, #enemySet)
    uiHud.drawTimer(gameTimer, width)
    
    -- Draw upgrade menu overlay
    if showUpgradeMenu and upgradeChoices then
        upgradeChoiceRects = uiUpgradeMenu.draw(width, height, upgradeChoices)
    end
    
    -- Draw pause menu overlay
    if isPaused then
        uiPauseMenu.draw(width, height, pauseButtons, player, selectedWeapon)
    end
end

function love.keypressed(key)
    -- Weapon selection via number keys
    if isChoosingWeapon and weaponChoiceRects and weaponChoices then
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
    
    -- Upgrade menu number key selection
    if showUpgradeMenu and upgradeChoices then
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
    -- Title screen
    if isClicking(playButton) and isAtTitleScreen then
        isAtTitleScreen = false
        isChoosingWeapon = true
        selectedWeapon = nil
        weaponSelectionBuffer = 1.0
        weaponChoices, weaponChoiceRects = uiWeaponSelection.buildChoices(
            width, height, sprites.sword, sprites.boomerang, sprites.pistol
        )
    end

    if isAtTitleScreen then return end
    
    -- Pause menu
    if isPaused then
        local action = uiPauseMenu.handleClick(pauseButtons, isClicking)
        if action == "continue" then
            isPaused = false
        elseif action == "newGame" then
            isPaused = false
            isAtTitleScreen = false
            isChoosingWeapon = true
            selectedWeapon = nil
            weaponSelectionBuffer = 1.0
            weaponChoices, weaponChoiceRects = uiWeaponSelection.buildChoices(
                width, height, sprites.sword, sprites.boomerang, sprites.pistol
            )
        elseif action == "quit" then
            love.event.quit()
        end
        return
    end

    -- Weapon selection
    if isChoosingWeapon then
        if weaponSelectionBuffer and weaponSelectionBuffer > 0 then
            weaponSelectionBuffer = math.max(0, weaponSelectionBuffer - dt)
        end
        local sel = uiWeaponSelection.handleMouse(weaponChoiceRects, weaponSelectionBuffer, isClicking)
        if sel then
            selectedWeapon = sel
            isChoosingWeapon = false
            weaponChoiceRects = nil
            weaponChoices = nil
            newGame()
        end
        return
    end

    -- World updates (if not frozen by upgrade menu)
    if not showUpgradeMenu and not isPaused then
        gameTimer = gameUpdate.updateWorld({
            player = player,
            dt = dt,
            camera = camera,
            selectedWeapon = selectedWeapon,
            enemySet = enemySet,
            projectiles = projectiles,
            gameTimer = gameTimer,
            sword = sword,
            boomerang = boomerang,
            pistol = pistol,
            playerMovement = require("playerMovement"),
            key_mappings = key_mappings,
            spawningFunctions = spawningFunctions,
            gameRun = gameRun,
            map = map,
            background = background,
            yaleEnemy = yaleEnemy,
            brownEnemy = brownEnemy,
            dartmouthEnemy = dartmouthEnemy,
            cornellEnemy = cornellEnemy
        })
    end

    -- Player update (always run for invuln timer, etc.)
    player:update()

    -- Handle player death
    if player.health <= 0 then
        isAtTitleScreen = true
        gameState.resetPlayer(player)
        if background then
            player.x = math.floor(background:getWidth() / 2 - (player.width or 0) / 2)
            player.y = math.floor(background:getHeight() / 2 - (player.height or 0) / 2)
        else
            player.x = 300
            player.y = 300
        end
        for index, enemy in pairs(enemySet) do
            enemy:setPosition(math.random(0, background and background:getWidth() or 800), math.random(0, background and background:getHeight() or 600))
        end
    end

    -- Upgrade menu input
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