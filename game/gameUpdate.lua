-- Module for game world update logic
local gameUpdate = {}

-- Update health regeneration
local function updateHealthRegen(player, dt)
    if player.healthRegen and player.healthRegen > 0 then
        player.healthRegenTimer = (player.healthRegenTimer or 0) + dt
        if player.healthRegenTimer >= (player.healthRegenInterval or 10) then
            player.health = math.min(player.health + player.healthRegen, player.maxHealth)
            player.healthRegenTimer = 0
        end
    end
end

-- Update selected weapon
local function updateWeapon(selectedWeapon, player, enemySet, dt, sword, boomerang, pistol)
    if selectedWeapon == "sword" then
        sword.update(player, enemySet, dt)
    elseif selectedWeapon == "boomerang" then
        boomerang.update(player, enemySet, dt)
    elseif selectedWeapon == "pistol" then
        pistol.update(player, enemySet, dt)
    end
end

-- Update enemies (AI, collision, death)
local function updateEnemies(enemySet, player, dt)
    -- Collision and damage
    for index, enemy in pairs(enemySet) do
        require("handleDamage")({player = player, enemy = enemy})
    end
    
    -- Enemy AI update and death handling
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
end

-- Update projectiles
local function updateProjectiles(projectiles, player, dt)
    for index = #projectiles, 1, -1 do
        local projectile = projectiles[index]
        if projectile then
            -- Skip extra boomerang objects (they're handled in boomerang.update)
            if not projectile.isExtraProjectile then
                projectile:update({dt=dt, player=player})
                if projectile.isExpired then
                    table.remove(projectiles, index)
                end
            end
        end
    end
end

-- Spawn enemies based on game time
local function spawnEnemies(spawningFunctions, gameTimer, enemySet, gameRun, map, background, player, yaleEnemy, brownEnemy, dartmouthEnemy, cornellEnemy)
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

-- Main world update function
function gameUpdate.updateWorld(params)
    local player = params.player
    local dt = params.dt
    local camera = params.camera
    local selectedWeapon = params.selectedWeapon
    local enemySet = params.enemySet
    local projectiles = params.projectiles
    local gameTimer = params.gameTimer
    local sword = params.sword
    local boomerang = params.boomerang
    local pistol = params.pistol
    local playerMovement = params.playerMovement
    local key_mappings = params.key_mappings
    local spawningFunctions = params.spawningFunctions
    local gameRun = params.gameRun
    local map = params.map
    local background = params.background
    local yaleEnemy = params.yaleEnemy
    local brownEnemy = params.brownEnemy
    local dartmouthEnemy = params.dartmouthEnemy
    local cornellEnemy = params.cornellEnemy
    
    -- Camera follows player
    camera:lookAt(player.x, player.y)
    
    -- Health regeneration
    updateHealthRegen(player, dt)
    
    -- Player movement
    playerMovement.update(player, key_mappings, dt)
    
    -- Weapon update
    updateWeapon(selectedWeapon, player, enemySet, dt, sword, boomerang, pistol)
    
    -- Enemies
    updateEnemies(enemySet, player, dt)
    
    -- Projectiles
    updateProjectiles(projectiles, player, dt)
    
    -- Update timer
    gameTimer = gameTimer + dt
    
    -- Spawn enemies
    spawnEnemies(spawningFunctions, gameTimer, enemySet, gameRun, map, background, player, yaleEnemy, brownEnemy, dartmouthEnemy, cornellEnemy)
    
    return gameTimer
end

return gameUpdate
