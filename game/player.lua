local player = {}
function player.load()
    player.x = 0
    player.y = 0
    player.speed = 100
    player.width = 32
    player.height = 32
    player.maxHealth = 3
    player.health = 3
    player.xp = 0
    player.xpMultiplier = 1.0
    player.attackSpeedMultiplier = 1.0
    player.rangeMultiplier = 1.0
    player.level = 1
    player.xpToNext = 10
    player.xpIncrement = 10
    player.healOnLevel = false
    player.knockbackResist = 0
    player.isInvulnerable = false
    player.invulnTimer = 0
    player.invulnDuration = 1.0
    player.facing = "down"
    player.lastHorizontalFacing = "right"
end
function player:addXP(amount)
    amount = (amount or 0) * (self.xpMultiplier or 1)
    self.xp = (self.xp or 0) + amount
    while self.xp >= (self.xpToNext or 10) do
        self:levelUp()
    end
end
function player:levelUp()
    self.level = (self.level or 1) + 1
    local currentIncrement = self.xpIncrement or 10
    local nextIncrement = math.ceil(currentIncrement * 1.05)
    self.xpIncrement = nextIncrement
    self.xpToNext = (self.xpToNext or 0) + nextIncrement
    upgrades = require("upgrades")
    upgradeChoices = upgrades.getRandomChoices(3, self.level)
    showUpgradeMenu = true
end
function player:draw()
    if player.isInvulnerable then
        local flashOn = math.floor(love.timer.getTime() * 10) % 2 == 0
        if flashOn then
            love.graphics.setColor(1, 1, 1, 0.35) 
        end
    end

    love.graphics.draw(sprites["player"], player.x, player.y)
end
function player:update()
    if player.health <= 0 then
        isAtTitleScreen = true
        -- reset all player stats for new run
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
        if background then
            player.x = math.floor(background:getWidth() / 2 - (player.width or 0) / 2)
            player.y = math.floor(background:getHeight() / 2 - (player.height or 0) / 2)
        else
            player.x = 300
            player.y = 300
        end
    end
end
return player