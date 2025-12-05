local Boomerang = {}

-- Configurable stats
local damage = 2           -- damage per hit
local range = 220          -- max distance before returning (pixels)
local size = 42            -- visual/hit size (pixels) (1.5x larger)
local speed = 140          -- travel speed (pixels/sec) -- slowed down
local spinSpeed = 6        -- radians per second for spinning -- slightly slower spin
local returnSpeed = 220    -- speed when returning (tracks player every frame)
local hitSizeMultiplier = 0.6 -- fraction of sprite size used for collision box
local waitAfterReturn = 1 -- seconds to wait at player before auto-launching again (configurable)

local image
local projectile = require("projectile")
local state = {
    mode = "idle", -- "idle", "out", "return"
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,
    angle = 0,
    dist = 0,
    hitEnemies = {},
    cooldownTimer = 0
}

-- use shared helper from projectile module

function Boomerang.load()
    -- load image if present, otherwise nil
    if love.filesystem.getInfo("assets/boomerang.png") then
        image = love.graphics.newImage("assets/boomerang.png")
    else
        image = nil
    end
    -- compute draw scale to make very large images render at a usable size
    local iw = image and image:getWidth() or size
    local ih = image and image:getHeight() or size
    local desired_display = size -- target largest dimension in pixels
    if iw and ih and math.max(iw, ih) > 0 then
        state.drawScale = desired_display / math.max(iw, ih)
    else
        state.drawScale = 1
    end
end

local function launchTowards(player, target)
    local px = player.x + (player.width or 0)/2
    local py = player.y + (player.height or 0)/2
    local tx, ty
    if target then
        tx = (target.x or 0) + (target.width or 0)/2
        ty = (target.y or 0) + (target.height or 0)/2
    else
        -- if no target, shoot in player's facing direction
        if player.facing == "right" then tx, ty = px + 1, py
        elseif player.facing == "left" then tx, ty = px - 1, py
        elseif player.facing == "up" then tx, ty = px, py - 1
        else tx, ty = px, py + 1 end
    end
    local dx = tx - px
    local dy = ty - py
    local d = math.sqrt(dx*dx + dy*dy)
    if d == 0 then d = 0.0001 end
    state.vx = (dx / d) * speed
    state.vy = (dy / d) * speed
    state.mode = "out"
    state.dist = 0
    state.hitEnemies = {}
end

-- Create and launch an extra boomerang for multi-projectile upgrade
local function launchExtraBoomerang(player, target, angleOffset)
    local px = player.x + (player.width or 0)/2
    local py = player.y + (player.height or 0)/2
    local tx, ty
    if target then
        tx = (target.x or 0) + (target.width or 0)/2
        ty = (target.y or 0) + (target.height or 0)/2
    else
        if player.facing == "right" then tx, ty = px + 1, py
        elseif player.facing == "left" then tx, ty = px - 1, py
        elseif player.facing == "up" then tx, ty = px, py - 1
        else tx, ty = px, py + 1 end
    end
    local dx = tx - px
    local dy = ty - py
    local baseAngle = math.atan2(dy, dx)
    local angle = baseAngle + angleOffset
    local vx = math.cos(angle) * speed
    local vy = math.sin(angle) * speed
    
    -- Create a new boomerang state object for this extra projectile
    local extraState = {
        mode = "out",
        x = px,
        y = py,
        vx = vx,
        vy = vy,
        angle = 0,
        dist = 0,
        hitEnemies = {},
        isExtraProjectile = true,
        drawScale = state.drawScale or 1
    }
    table.insert(projectiles, extraState)
end

function Boomerang.update(player, enemySet, dt)
    -- attach to player when idle
    local px = player.x + (player.width or 0)/2
    local py = player.y + (player.height or 0)/2

    if state.mode == "idle" then
        state.x = px
        state.y = py
        -- countdown cooldown before next auto-launch
        if state.cooldownTimer and state.cooldownTimer > 0 then
            state.cooldownTimer = state.cooldownTimer - dt
            if state.cooldownTimer < 0 then state.cooldownTimer = 0 end
            return
        end

        -- if cooldown expired and there are enemies, auto-launch toward closest immediately
        if state.cooldownTimer == 0 and enemySet and next(enemySet) ~= nil then
            local target = projectile.findClosestEnemy(player, enemySet)
            if target then
                launchTowards(player, target)
                
                -- spawn extra boomerangs if upgrade active
                local extraCount = player.extraProjectiles or 0
                if extraCount > 0 then
                    local angleOffset = math.pi / 6 -- 30 degrees between projectiles
                    for i = 1, extraCount do
                        launchExtraBoomerang(player, target, angleOffset * i)
                    end
                end
                
                state.cooldownTimer = 0
            end
        end
        return
    end

    -- Helper function to update a boomerang state object
    local function updateBoomerangState(bState)
        -- move
        bState.x = bState.x + (bState.vx or 0) * dt
        bState.y = bState.y + (bState.vy or 0) * dt
        bState.angle = bState.angle + spinSpeed * dt

        -- check for hitting enemies while flying (both out and return)
        if bState.mode ~= "idle" and enemySet then
            local iw = (image and image:getWidth() or size) * (bState.drawScale or 1)
            local ih = (image and image:getHeight() or size) * (bState.drawScale or 1)
            local w = iw * hitSizeMultiplier
            local h = ih * hitSizeMultiplier
            local attackBox = { x = bState.x - w/2, y = bState.y - h/2, width = w, height = h }
            local isColliding = require("collisions")
            for _, enemy in pairs(enemySet) do
                if enemy and not bState.hitEnemies[enemy] and isColliding(attackBox, enemy) then
                    -- calculate damage with critical hit chance
                    local baseDamage = 2 + (player.damage or 0)
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
                    -- knockback
                    local ex = (enemy.x or 0) + (enemy.width or 0)/2
                    local ey = (enemy.y or 0) + (enemy.height or 0)/2
                    local kdx = ex - bState.x
                    local kdy = ey - bState.y
                    local dist = math.sqrt(kdx*kdx + kdy*kdy)
                    if dist == 0 then dist = 0.0001 end
                    local kb = enemy.knockback or 20
                    enemy.x = enemy.x + (kdx / dist) * kb
                    enemy.y = enemy.y + (kdy / dist) * kb
                    bState.hitEnemies[enemy] = true
                end
            end
        end

        if bState.mode == "out" then
            -- accumulate distance traveled from player origin
            local dx = bState.x - px
            local dy = bState.y - py
            bState.dist = math.sqrt(dx*dx + dy*dy)

            if bState.dist >= range then
                -- start return; reset hit list so return can hit enemies again
                bState.hitEnemies = {}
                local rdx = px - bState.x
                local rdy = py - bState.y
                local rd = math.sqrt(rdx*rdx + rdy*rdy)
                if rd == 0 then rd = 0.0001 end
                bState.vx = (rdx / rd) * returnSpeed
                bState.vy = (rdy / rd) * returnSpeed
                bState.mode = "return"
            end
        elseif bState.mode == "return" then
            -- recompute return velocity each frame so boomerang tracks moving player
            local rdx = px - bState.x
            local rdy = py - bState.y
            local rd = math.sqrt(rdx*rdx + rdy*rdy)
            if rd == 0 then rd = 0.0001 end
            bState.vx = (rdx / rd) * returnSpeed
            bState.vy = (rdy / rd) * returnSpeed

            -- check arrival
            if rd <= 16 then
                -- reached player; mark as expired for extra boomerangs or return to idle for main
                if bState.isExtraProjectile then
                    bState.isExpired = true
                else
                    bState.mode = "idle"
                    bState.vx, bState.vy = 0, 0
                    bState.angle = 0
                    bState.cooldownTimer = waitAfterReturn
                    bState.x = px
                    bState.y = py
                end
            end
        end
    end

    -- Update main boomerang
    updateBoomerangState(state)
    
    -- Update extra boomerangs in projectiles table
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        if proj and proj.isExtraProjectile then
            updateBoomerangState(proj)
            if proj.isExpired then
                table.remove(projectiles, i)
            end
        end
    end
end

function Boomerang.draw(player, enemySet)
    -- If idle and no enemies exist, don't draw (invisible while waiting)
    if state.mode == "idle" then
        if not enemySet or next(enemySet) == nil then
            return
        end

        -- otherwise, draw attached boomerang at player's position
        local px = player.x + (player.width or 0)/2
        local py = player.y + (player.height or 0)/2
        if image then
            local iw, ih = image:getWidth(), image:getHeight()
            local scale = state.drawScale or 1
            love.graphics.draw(image, px, py, state.angle, scale, scale, iw/2, ih/2)
        else
            love.graphics.setColor(1,1,0)
            love.graphics.circle("fill", px, py, size/2)
            love.graphics.setColor(1,1,1)
        end
        return
    end

    -- draw flying boomerang (out or return)
    if image then
        local iw, ih = image:getWidth(), image:getHeight()
        local scale = state.drawScale or 1
        love.graphics.draw(image, state.x, state.y, state.angle, scale, scale, iw/2, ih/2)
    else
        love.graphics.setColor(1,1,0)
        love.graphics.circle("fill", state.x, state.y, size/2)
        love.graphics.setColor(1,1,1)
    end
    
    -- draw extra boomerangs
    for _, proj in pairs(projectiles) do
        if proj and proj.isExtraProjectile then
            if image then
                local iw, ih = image:getWidth(), image:getHeight()
                local scale = proj.drawScale or 1
                love.graphics.draw(image, proj.x, proj.y, proj.angle, scale, scale, iw/2, ih/2)
            else
                love.graphics.setColor(1,1,0)
                love.graphics.circle("fill", proj.x, proj.y, size/2)
                love.graphics.setColor(1,1,1)
            end
        end
    end
end

return Boomerang
