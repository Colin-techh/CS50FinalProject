-- gameRun.lua
-- Handles creating a fresh run: map generation, player positioning, and enemy spawning.

local gameRun = {}

local function computeCounts(mapW, mapH)
    local baseArea = 800 * 600
    local areaRatio = (mapW * mapH) / baseArea
    local scaleFactor = 0.60 -- density multiplier (tune here)
    return {
        trees = math.max(2, math.floor(4 * areaRatio * scaleFactor)),
        rocks = math.max(2, math.floor(3 * areaRatio * scaleFactor)),
        grass = math.max(8, math.floor(12 * areaRatio * scaleFactor)),
    }
end

-- Finds a spawn position away from the player and not colliding with map objects.
local function makeSpawnFinder(map, mapW, mapH, player)
    local minDistanceFromPlayer = 120
    return function()
        local tries = 0
        while tries < 500 do
            tries = tries + 1
            local x = math.random(0, mapW)
            local y = math.random(0, mapH)
            local box = { x = x, y = y, width = 32, height = 32 }
            if not map:collidesWithBlocking(box) and not map:overlapsAny(box) then
                local dx = (player.x + player.width/2) - (x + box.width/2)
                local dy = (player.y + player.height/2) - (y + box.height/2)
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist > minDistanceFromPlayer then
                    return x, y
                end
            end
        end
        return math.floor(mapW/2), math.floor(mapH/2)
    end
end

function gameRun.newRun(state)
    -- reseed randomness for each run
    math.randomseed(os.time())
    math.random()

    local background = state.background
    local map = state.map
    local player = state.player
    local enemySet = state.enemySet
    local projectiles = state.projectiles
    local yaleEnemy = state.yaleEnemy
    local brownEnemy = state.brownEnemy

    local mapW, mapH = background:getWidth(), background:getHeight()
    local counts = computeCounts(mapW, mapH)

    -- center player and reset health
    player.x = math.floor(mapW / 2 - (player.width or 0) / 2)
    player.y = math.floor(mapH / 2 - (player.height or 0) / 2)
    player.health = player.maxHealth or player.health

    -- clear world objects
    for k in pairs(projectiles) do projectiles[k] = nil end
    for k in pairs(enemySet) do enemySet[k] = nil end

    -- generate map
    map.load({ width = mapW, height = mapH, counts = counts, safeZones = { { x = player.x, y = player.y, width = player.width, height = player.height } } })

    -- spawn enemies
    local findSpawnSafeLocal = makeSpawnFinder(map, mapW, mapH, player)
    for i=1,5 do
        local ex, ey = findSpawnSafeLocal()
        table.insert(enemySet, yaleEnemy:new(ex, ey))
    end
    for i=1,5 do
        local ex, ey = findSpawnSafeLocal()
        table.insert(enemySet, brownEnemy:new(ex, ey))
    end
    for i=1,5 do
        local ex, ey = findSpawnSafeLocal()
        table.insert(enemySet, dartmouthEnemy:new(ex, ey))
    end
end

return gameRun
