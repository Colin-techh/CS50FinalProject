-- Module for managing game state variables and initialization
local gameState = {}

-- Initialize all game state variables
function gameState.init()
    return {
        isAtTitleScreen = true,
        isChoosingWeapon = false,
        isPaused = false,
        selectedWeapon = nil,
        weaponSelectionBuffer = 0,
        showUpgradeMenu = false,
        upgradeChoices = nil,
        upgradeChoiceRects = nil,
        weaponChoices = nil,
        weaponChoiceRects = nil,
        gameTimer = 0,
        enemySet = {},
        projectiles = {}
    }
end

-- Reset player stats for new run
function gameState.resetPlayer(player)
    player.health = 3
    player.maxHealth = 3
    player.xp = 0
    player.level = 1
    player.xpToNext = 10
    player.xpIncrement = 10
    player.xpMultiplier = 1.0
    player.attackSpeedMultiplier = 1.0
    player.rangeMultiplier = 1.0
    player.damage = nil
    player.criticalHitChance = nil
    player.lifesteal = nil
    player.healthRegen = nil
    player.healthRegenTimer = 0
    player.healthRegenInterval = 10
    player.extraProjectiles = nil
    player.speed = 100
    player.knockbackResist = 0
    player.invulnDuration = 1.0
end

return gameState
