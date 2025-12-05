local upgrades = {}

local pool = {
    {
        id = "max_health",
        name = "Max Health +1",
        desc = "Increase your maximum health by 1 and heal 1 HP.",
        apply = function(player)
            player.maxHealth = (player.maxHealth or 3) + 1
            player.health = math.min(player.health + 1, player.maxHealth)
        end
    },
    {
        id = "speed",
        name = "Speed +10%",
        desc = "Increase movement speed by 10%.",
        apply = function(player)
            player.speed = (player.speed or 100) * 1.10
        end
    },
    {
        id = "xp_gain",
        name = "XP Gain +20%",
        desc = "Gain 20% more XP from kills.",
        apply = function(player)
            player.xpMultiplier = (player.xpMultiplier or 1) * 1.20
        end
    },
    {
        id = "invuln_duration",
        name = "Shorter Invulnerability",
        desc = "Reduce invulnerability frame duration by 15%.",
        apply = function(player)
            player.invulnDuration = math.max(0.1, (player.invulnDuration or 1.0) * 0.85)
        end
    },
    {
        id = "heal_on_level",
        name = "Heal on Level",
        desc = "Heal 50% of max health when you level up.",
        apply = function(player)
            player.healOnLevel = true
        end
    },
    {
        id = "knockback_resist",
        name = "Knockback Resist",
        desc = "Reduce incoming knockback by 20%.",
        apply = function(player)
            player.knockbackResist = (player.knockbackResist or 0) + 0.20
        end
    }
}

-- Return n unique random choices from pool. We don't strictly use 'level' now but keep for future weighting.
function upgrades.getRandomChoices(n, level)
    local choices = {}
    local copy = {}
    for i, v in ipairs(pool) do copy[i] = v end
    math.randomseed(os.time() + math.floor(love.timer.getTime() * 1000))
    for i=1,math.min(n, #copy) do
        local idx = math.random(1, #copy)
        table.insert(choices, copy[idx])
        table.remove(copy, idx)
    end
    return choices
end

return upgrades
