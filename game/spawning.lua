spawningFunctions = {}

local lastTimeSpawned = 0
function spawningFunctions.spawnEnemy(options)
    local currentGameTime = options.gameTime or 0

    -- spawn enemies randomly over time, increasing with gameTime and increasing in health and damage
    local spawnInterval = math.max(1, 5 - math.floor(currentGameTime / 30)) -- spawn more frequently over time
    
    -- function runs every frame, only spawn maximum once per second
    if currentGameTime - lastTimeSpawned >= spawnInterval then
        lastTimeSpawned = currentGameTime
        local enemyTypeRoll = math.random()
        local enemyType = nil
        if enemyTypeRoll < 0.5 then
            enemyType = options.yaleEnemy
        elseif enemyTypeRoll < 0.8 then
            enemyType = options.brownEnemy
        else
            enemyType = options.dartmouthEnemy
        end

        local ex, ey = options.findSpawnSafe()
        local newEnemy = enemyType:new(ex, ey)

        -- scale health and damage with game time
        newEnemy.health = newEnemy.health + math.floor(currentGameTime / 10)
        newEnemy.damage = newEnemy.damage + math.floor(currentGameTime / 20)

        table.insert(options.enemySet, newEnemy)
    end
end

return spawningFunctions