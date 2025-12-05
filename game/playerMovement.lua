function update(player, key_mappings, dt)
    local input = {x = 0, y = 0}

    local isDown = function(mapping)
        if type(mapping) == "string" then
            return love.keyboard.isDown(mapping)
        elseif type(mapping) == "table" then
            for _, k in ipairs(mapping) do
                if love.keyboard.isDown(k) then return true end
            end
            return false
        end
        return false
    end

    if isDown(key_mappings.up) then input.y = -1 end
    if isDown(key_mappings.down) then input.y = 1 end
    if isDown(key_mappings.left) then input.x = -1 end
    if isDown(key_mappings.right) then input.x = 1 end

    -- Apply movement with collision against blocking map objects (axis-separated)
    local map = require("map")
    local dx = input.x * (player.speed or 0) * dt
    local dy = input.y * (player.speed or 0) * dt
    -- try horizontal move
    if dx ~= 0 then
        local newX = player.x + dx
        local testBox = { x = newX, y = player.y, width = player.width or 0, height = player.height or 0 }
        -- check map collision and boundary (0 to 5000)
        if not map:collidesWithBlocking(testBox) and newX >= 0 and newX + (player.width or 0) <= 5000 then
            player.x = newX
        end
    end
    -- try vertical move
    if dy ~= 0 then
        local newY = player.y + dy
        local testBox = { x = player.x, y = newY, width = player.width or 0, height = player.height or 0 }
        -- check map collision and boundary (0 to 5000)
        if not map:collidesWithBlocking(testBox) and newY >= 0 and newY + (player.height or 0) <= 5000 then
            player.y = newY
        end
    end

    -- Update facing based on last input (cardinal directions only)
    if input.x > 0 then
        player.facing = "right"
        player.lastHorizontalFacing = "right"
    elseif input.x < 0 then
        player.facing = "left"
        player.lastHorizontalFacing = "left"
    else
        -- only update vertical facing when there's no horizontal input
        if input.y < 0 then
            player.facing = "up"
        elseif input.y > 0 then
            player.facing = "down"
        end
    end

    -- Handle invulnerability timer
    if player.isInvulnerable then
        player.invulnTimer = player.invulnTimer - dt
        if player.invulnTimer <= 0 then
            player.isInvulnerable = false
            player.invulnTimer = 0
        end
    end

    
end

return {
    update = update
}