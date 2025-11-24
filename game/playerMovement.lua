function update(player, yaleEnemy, key_mappings, dt)
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

    -- Apply regular movement
    player.x = player.x + input.x * player.speed * dt
    player.y = player.y + input.y * player.speed * dt

    -- Handle invulnerability timer
    if player.isInvulnerable then
        player.invulnTimer = player.invulnTimer - dt
        if player.invulnTimer <= 0 then
            player.isInvulnerable = false
            player.invulnTimer = 0
        end
    end

    -- Collision & knockback: if colliding and not invulnerable, apply damage and knockback
    local collides = require("collisions")(player, yaleEnemy)
    if collides and not player.isInvulnerable then
        -- reduce health
        player.health = player.health - 1

        -- knockback displacement away from enemy
        local dx = player.x - yaleEnemy.x
        local dy = player.y - yaleEnemy.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist == 0 then dist = 0.0001 end
        local knockbackAmount = 48 -- pixels, tweak this value
        player.x = player.x + (dx / dist) * knockbackAmount
        player.y = player.y + (dy / dist) * knockbackAmount

        -- start invulnerability frames
        player.isInvulnerable = true
        player.invulnTimer = player.invulnDuration or 1.0
    end
end

return {
    update = update
}