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
    playerImage = love.graphics.newImage("assets/player1.png")
    -- sword (automatic slash)
    sword = require("sword")
    sword.load()
        -- boomerang (auto-launch toward nearest enemy when returned)
        boomerang = require("boomerang")
        boomerang.load()
    -- pistol (player weapon)
    pistol = require("pistol")
    pistol.load()

    -- UI selection images (reuse assets)
    selectionSwordImage = love.graphics.newImage("assets/sword.png")
    selectionBoomerangImage = love.graphics.newImage("assets/boomerang.png")
    selectionPistolImage = love.graphics.newImage("assets/pistol.png")
    
    key_mappings = {
        up    = {"w", "up"},
        left  = {"a", "left"},
        down  = {"s", "down"},
        right = {"d", "right"},
    }
    -- Enemy setup
    require("yale")
    require("brown")

    enemySet = {}

    for i=1,5 do
        local enemy = yaleEnemy:new(math.random(0, 800), math.random(0, 600))
        addEnemy(enemy)
    end
    for i=1,5 do
        local enemy = brownEnemy:new(math.random(0, 800), math.random(0, 600))
        addEnemy(enemy)
    end
    -- Player
    player = { 
        x = 300,
        y = 300,
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
        -- level up while accumulated XP meets or exceeds the next threshold
        while self.xp >= (self.xpToNext or 10) do
            self:levelUp()
        end
    end
    function player:levelUp()
        self.level = (self.level or 1) + 1
        -- cumulative threshold: level * 10 XP to reach that level
        self.xpToNext = (self.level) * 10
        -- show upgrade menu
        upgrades = require("upgrades")
        upgradeChoices = upgrades.getRandomChoices(3, self.level)
        showUpgradeMenu = true
    end

    -- Projectiles
    projectiles = {}
end

function love.draw()
    if isAtTitleScreen then
        -- Draw play button
        love.graphics.setBlendMode("alpha")
        love.graphics.draw(startImage, width/2 - startImage:getWidth()/8, height/2 - startImage:getHeight()/8, 0, 0.25, 0.25)
        player.x = 300
        player.y = 300
        
        return
    end

    -- weapon selection UI (screen-space)
    if isChoosingWeapon and weaponChoices and weaponChoiceRects then
        love.graphics.setColor(0,0,0,0.6)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Choose your starting weapon!", 0, height/2 - 160, width, "center")
        for i, rect in ipairs(weaponChoiceRects) do
            love.graphics.setColor(0.12,0.12,0.12,0.95)
            love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height, 8, 8)
            love.graphics.setColor(1,1,1)
            love.graphics.printf(rect.title, rect.x, rect.y + 8, rect.width, "center")
            if rect.image then
                local iw, ih = rect.image:getWidth(), rect.image:getHeight()
                local scale = math.min((rect.width-40)/iw, (rect.height-60)/ih)
                love.graphics.draw(rect.image, rect.x + rect.width/2, rect.y + rect.height/2 + 8, 0, scale, scale, iw/2, ih/2)
            end
            love.graphics.print("("..i..")", rect.x + 8, rect.y + 8)
        end
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
    camera:detach()

    -- Draw HUD elements in screen space
    love.graphics.print("Health: " .. player.health, 10, 10)
    love.graphics.print("XP: " .. player.xp, 10, 30)
    love.graphics.print("Projectiles: " .. #projectiles, 10, 50)
    
    -- Draw upgrade menu overlay when active
    if showUpgradeMenu and upgradeChoices then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1, 1, 1)
        -- header text
        local header = "Level Up! use mouse or number keys to select your upgrade"
        local headerY = height/2 - 160
        love.graphics.printf(header, 0, headerY, width, "center")
        local desiredBoxW, boxH = 300, 120
        local gap = 20
        local margin = 20
        local n = #upgradeChoices
        -- compute box width so choices always fit within window (respecting margins)
        local totalNeeded = desiredBoxW * n + gap * (n - 1)
        local boxW = desiredBoxW
        local startX = 0
        if totalNeeded <= (width - 2 * margin) then
            startX = (width - totalNeeded) / 2
        else
            boxW = math.floor((width - 2 * margin - gap * (n - 1)) / n)
            if boxW < 80 then boxW = 80 end
            startX = margin
        end
        upgradeChoiceRects = {}
        for i, up in ipairs(upgradeChoices) do
            local bx = startX + (i - 1) * (boxW + gap)
            local by = height / 2 - boxH / 2
            love.graphics.setColor(0.12, 0.12, 0.12, 0.95)
            love.graphics.rectangle("fill", bx, by, boxW, boxH, 8, 8)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(up.name, bx + 12, by + 10)
            -- wrap description text to stay inside the choice box
            local descX = bx + 12
            local descY = by + 36
            local descWidth = boxW - 24
            love.graphics.printf(up.desc, descX, descY, descWidth, "left")
            -- draw number label for keyboard selection
            local numLabel = "(" .. i .. ")"
            love.graphics.print(numLabel, bx + boxW - 28, by + 10)
            upgradeChoiceRects[i] = { x = bx, y = by, width = boxW, height = boxH }
        end
    end
end

function love.keypressed(key)
    -- weapon selection via number keys
    if isChoosingWeapon and weaponChoiceRects and weaponChoices then
        -- block key selection while the initial click buffer is active
        if not weaponSelectionBuffer or weaponSelectionBuffer <= 0 then
            local n = tonumber(key)
            if n and weaponChoiceRects[n] then
                selectedWeapon = weaponChoiceRects[n].id
                isChoosingWeapon = false
                weaponChoiceRects = nil
                weaponChoices = nil
                return
            end
            if key:sub(1,2) == "kp" then
                local k = tonumber(key:sub(3))
                if k and weaponChoiceRects[k] then
                    selectedWeapon = weaponChoiceRects[k].id
                    isChoosingWeapon = false
                    weaponChoiceRects = nil
                    weaponChoices = nil
                    return
                end
            end
        end
    end
    -- allow number key selection when upgrade menu is active
    if showUpgradeMenu and upgradeChoices then
        -- accept both main row and numpad keys ("1", "2", "3")
        local n = tonumber(key)
        if n and upgradeChoices[n] then
            local chosen = upgradeChoices[n]
            if chosen and chosen.apply then chosen.apply(player) end
            showUpgradeMenu = false
            upgradeChoices = nil
            upgradeChoiceRects = nil
            return
        end
        -- also accept keypad keys like "kp1" etc
        if key:sub(1,2) == "kp" then
            local k = tonumber(key:sub(3))
            if k and upgradeChoices[k] then
                local chosen = upgradeChoices[k]
                if chosen and chosen.apply then chosen.apply(player) end
                showUpgradeMenu = false
                upgradeChoices = nil
                upgradeChoiceRects = nil
                return
            end
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
        -- prepare weapon choices and rects for input (positions computed once)
        local choices = {
            { id = "sword", image = selectionSwordImage, title = "Sword" },
            { id = "boomerang", image = selectionBoomerangImage, title = "Boomerang" },
            { id = "pistol", image = selectionPistolImage, title = "Pistol" }
        }
        local n = #choices
        local boxW = math.min(300, math.floor((width - 80 - (n-1)*20) / n))
        if boxW < 100 then boxW = 100 end
        local boxH = 160
        local gap = 20
        local startX = (width - (boxW * n + gap * (n - 1))) / 2
        weaponChoiceRects = {}
        weaponChoices = choices
        for i, ch in ipairs(choices) do
            local bx = startX + (i-1) * (boxW + gap)
            local by = height/2 - boxH/2
            weaponChoiceRects[i] = { x = bx, y = by, width = boxW, height = boxH, id = ch.id, image = ch.image, title = ch.title }
        end
    end

    if isAtTitleScreen then
        return
    end

    -- if weapon selection is active, skip world updates but continue so input (mouse/key) is processed
    if isChoosingWeapon then
        -- tick down the selection buffer so accidental input right after pressing Start is ignored
        if weaponSelectionBuffer and weaponSelectionBuffer > 0 then
            weaponSelectionBuffer = math.max(0, weaponSelectionBuffer - dt)
        end
        -- do nothing else here; later code will handle input for selection
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
                projectile:update(dt)
                if projectile.isExpired then
                    table.remove(projectiles, index)
                end
            end
        end
    end

    -- weapon selection input handling (mouse click)
    if isChoosingWeapon and weaponChoiceRects then
        -- only allow selection after the buffer expires to avoid accidental immediate clicks
        if not weaponSelectionBuffer or weaponSelectionBuffer <= 0 then
            for i, rect in ipairs(weaponChoiceRects) do
                if isClicking(rect) then
                    selectedWeapon = rect.id
                    isChoosingWeapon = false
                    weaponChoiceRects = nil
                    weaponChoices = nil
                    break
                end
            end
        end
    end

    -- handle death / reset here so gameplay module doesn't need global state
    if player.health <= 0 then
        isAtTitleScreen = true
        player.health = 3
        player.x = 300
        player.y = 300
        for index, enemy in pairs(enemySet) do
            enemy:setPosition(math.random(0, 800), math.random(0, 600))
        end
    end

    -- handle upgrade menu input (click to choose)
    if showUpgradeMenu and upgradeChoiceRects and upgradeChoices then
        for i, rect in ipairs(upgradeChoiceRects) do
            if isClicking(rect) then
                local chosen = upgradeChoices[i]
                if chosen and chosen.apply then
                    chosen.apply(player)
                end
                -- clear menu state and resume gameplay
                showUpgradeMenu = false
                upgradeChoices = nil
                upgradeChoiceRects = nil
                break
            end
        end
    end
end

function addEnemy(enemy)
    table.insert(enemySet, enemy)
end