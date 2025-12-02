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

    
end

return {
    update = update
}