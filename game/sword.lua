local Sword = {}

local swordImage
local attackInterval = 1.5    -- seconds between automatic slashes
local attackDuration = 0.25   -- how long the slash is visible
local reach = 38              -- distance from player's center to sword center
damage = 5                    -- damage per hit

local state = {
    timer = 0,
    attacking = false,
    attackTimer = 0,
    dir = "down",
    drawScale = 1,
    hitEnemies = {}
}

function Sword.load()
    swordImage = love.graphics.newImage("assets/sword.png")
    -- compute a reasonable draw scale so huge assets (e.g. 5000x5000) render at a usable size
    local iw, ih = swordImage:getWidth(), swordImage:getHeight()
    local desired_display = 60 -- target size in pixels for the sword's largest dimension; tweak to taste
    if iw and ih and math.max(iw, ih) > 0 then
        state.drawScale = desired_display / math.max(iw, ih)
    else
        state.drawScale = 1
    end
end

-- Call this every frame. Pass the player so we can read facing.
function Sword.update(player, enemySet, dt)
    state.timer = state.timer + dt
    if state.attacking then
        state.attackTimer = state.attackTimer - dt
        if state.attackTimer <= 0 then
            state.attacking = false
            state.attackTimer = 0
        end
    else
        if state.timer >= attackInterval then
            state.timer = state.timer - attackInterval
            state.attacking = true
            state.attackTimer = attackDuration
            state.dir = player.facing or "down"
            -- reset hit list so each attack can hit enemies once
            state.hitEnemies = {}
        end
    end

    -- while attacking, check for hits against enemies
    if state.attacking and enemySet then
        local iw, ih = swordImage and swordImage:getWidth() or 8, swordImage and swordImage:getHeight() or 8
        local w, h = (iw * state.drawScale) * 0.6, (ih * state.drawScale) * 0.6
        local px = player.x + (player.width or 0)/2
        local py = player.y + (player.height or 0)/2
        local ax = px
        local ay = py
        if state.dir == "right" then
            ax = px + reach
            ay = py
        elseif state.dir == "left" then
            ax = px - reach
            ay = py
        elseif state.dir == "up" then
            ax = px
            ay = py - reach
        else
            ax = px
            ay = py + reach
        end

        local attackBox = { x = ax - w/2, y = ay - h/2, width = w, height = h }
        local isColliding = require("collisions")
        for _, enemy in pairs(enemySet) do
            if enemy and not state.hitEnemies[enemy] and isColliding(attackBox, enemy) then
                -- calculate damage with critical hit chance
                local baseDamage = 1 + (player.damage or 0)
                local critChance = player.criticalHitChance or 0
                local isCritical = math.random() < critChance
                local damageDealt = isCritical and (baseDamage * 2) or baseDamage
                
                if enemy.decreaseHealth then
                    enemy:decreaseHealth(damageDealt)
                else
                    enemy.health = (enemy.health or 0) - damageDealt
                end
                
                -- apply lifesteal
                if player.lifesteal and player.lifesteal > 0 then
                    player.health = math.min(player.health + damageDealt * player.lifesteal, player.maxHealth)
                end

                -- apply knockback to enemy away from attack center
                local dx = enemy.x + (enemy.width or 0)/2 - ax
                local dy = enemy.y + (enemy.height or 0)/2 - ay
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist == 0 then dist = 0.0001 end
                local kb = enemy.knockback or 20
                enemy.x = enemy.x + (dx / dist) * kb
                enemy.y = enemy.y + (dy / dist) * kb

                -- mark hit so same attack doesn't hit twice
                state.hitEnemies[enemy] = true
            end
        end
    end
end

-- Draw the sword slash relative to the player's position and facing.
function Sword.draw(player)
    if not state.attacking then return end
    if not swordImage then return end

    local iw, ih = swordImage:getWidth(), swordImage:getHeight()
    local ox, oy = iw/2, ih/2

    local px = player.x + (player.width or 0)/2
    local py = player.y + (player.height or 0)/2

    local sx = state.drawScale or 1
    local sy = sx
    local angle = 0
    local dx, dy = 0, 0

    -- Asset is oriented facing "up" (north). Use that as base (angle = 0).
    -- Rotate clockwise by pi/2 for right (east), pi for down (south), -pi/2 for left (west).
    if state.dir == "up" then
        angle = 0
        dx = 0
        dy = -reach
    elseif state.dir == "right" then
        angle = math.pi/2
        dx = reach
        dy = 0
    elseif state.dir == "down" then
        angle = math.pi
        dx = 0
        dy = reach
    else -- left
        angle = -math.pi/2
        dx = -reach
        dy = 0
    end

    love.graphics.draw(swordImage, px + dx, py + dy, angle, sx, sy, ox, oy)
end

return Sword
