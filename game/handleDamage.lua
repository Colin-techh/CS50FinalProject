local collides = require("collisions")
local function damage(options)
    player, currentEnemy = options.player, options.enemy
    damage = currentEnemy.damage
    local knockbackAmount = currentEnemy.knockback

    -- Collision & knockback: if colliding and not invulnerable, apply damage and knockback
    if collides(player, currentEnemy) and not player.isInvulnerable then
        -- reduce health
        player.health = player.health - damage

        -- knockback displacement away from enemy
        local dx = player.x - currentEnemy.x
        local dy = player.y - currentEnemy.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist == 0 then dist = 0.0001 end
        player.x = player.x + (dx / dist) * knockbackAmount
        player.y = player.y + (dy / dist) * knockbackAmount

        -- start invulnerability frames
        player.isInvulnerable = true
        player.invulnTimer = player.invulnDuration or 1.0
    end
end
return damage