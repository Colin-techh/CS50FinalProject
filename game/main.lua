-- Library usage
local Camera = require "libs.hump-master.camera"
local gameRun = require("gameRun")
local uiWeaponSelection = require("ui_weaponSelection")
local uiUpgradeMenu = require("ui_upgradeMenu")

camera = Camera(0, 0)



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
        pistol_bullet = love.graphics.newImage("assets/pistol_bullet.png"),
        tree = love.graphics.newImage("assets/tree.png"),
        rock = love.graphics.newImage("assets/rock.png"),
        grass = love.graphics.newImage("assets/grass.png")
    }


    isColliding = require("collisions")
    isClicking = require("isClicking")
    isAtTitleScreen = true
    isChoosingWeapon = false
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

    -- player image
    playerImage = sprites["player"]
    -- sword (automatic slash)
    sword = require("sword")
    sword.load()
        -- boomerang (auto-launch toward nearest enemy when returned)
        boomerang = require("boomerang")
        boomerang.load()
    -- pistol (player weapon)
    pistol = require("pistol")
    pistol.load()

    -- Enemy types
    yaleEnemy = require("yale")
    brownEnemy = require("brown")

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
    enemySet = {}
    projectiles = {}
    map = require("map")

    -- Player
    player = {
        x = 0,
        y = 0,
        speed = 100,
        width = 32,
        height = 32,
        maxHealth = 3,
        health = 3,
        xp = 0,
        xpMultiplier = 1.0,
        level = 1,
        xpToNext = 10,
        healOnLevel = false,
        knockbackResist = 0,
        isInvulnerable = false,
        invulnTimer = 0,
        invulnDuration = 1.0,
        facing = "down",
        lastHorizontalFacing = "right"
    }

    -- helper methods on player
    function player:addXP(amount)
        amount = (amount or 0) * (self.xpMultiplier or 1)
        self.xp = (self.xp or 0) + amount
        while self.xp >= (self.xpToNext or 10) do
            self:levelUp()
        end
    end
    function player:levelUp()
        self.level = (self.level or 1) + 1
        self.xpToNext = (self.level) * 10
        upgrades = require("upgrades")
        upgradeChoices = upgrades.getRandomChoices(3, self.level)
        showUpgradeMenu = true
    end

    -- initial world created when the player actually starts a run (newGame)
end

-- start a fresh run: regenerate map, reset enemies/projectiles, center player and spawn enemies
function newGame()
    gameRun.newRun({
        background = background,
        map = map,
        player = player,
        enemySet = enemySet,
        projectiles = projectiles,
        yaleEnemy = yaleEnemy,
        brownEnemy = brownEnemy
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
    -- Flash player while invulnerable
    if player.isInvulnerable then
        local flashOn = math.floor(love.timer.getTime() * 10) % 2 == 0
        if flashOn then
            love.graphics.setColor(1, 1, 1, 0.35) 
        end
    end

    love.graphics.draw(playerImage, player.x, player.y)
    -- draw selected weapon on player (only one enabled)
    if selectedWeapon == "pistol" then
        pistol.draw(player)
    end
    love.graphics.setColor(1, 1, 1, 1)

    for index, enemy in pairs(enemySet) do
        enemy:draw()
    end
    for index, projectile in pairs(projectiles) do
        projectile:draw()
    end
    -- draw selected weapon visuals
    if selectedWeapon == "sword" then
        sword.draw(player)
    end
    if selectedWeapon == "boomerang" then
        boomerang.draw(player, enemySet)
    end
    -- draw blocking map elements (rocks / trees) above characters
    if map and map.drawBlocking then map:drawBlocking() end
    camera:detach()

    -- Draw HUD elements in screen space
    love.graphics.print("Health: " .. player.health, 10, 10)
    love.graphics.print("XP: " .. player.xp, 10, 30)
    love.graphics.print("Projectiles: " .. #projectiles, 10, 50)
    
    -- Draw upgrade menu overlay when active
    if showUpgradeMenu and upgradeChoices then
        upgradeChoiceRects = uiUpgradeMenu.draw(width, height, upgradeChoices)
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
    if not showUpgradeMenu then
        camera:lookAt(player.x, player.y)
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
                projectile:update({dt=dt, player=player})
                if projectile.isExpired then
                    table.remove(projectiles, index)
                end
            end
        end
    end

    -- handle death / reset here so gameplay module doesn't need global state
    if player.health <= 0 then
        isAtTitleScreen = true
        player.health = 3
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