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
                state.cooldownTimer = 0
            end
        end
        return
    end

    -- move
    state.x = state.x + (state.vx or 0) * dt
    state.y = state.y + (state.vy or 0) * dt
    state.angle = state.angle + spinSpeed * dt

    -- check for hitting enemies while flying (both out and return)
    if state.mode ~= "idle" and enemySet then
        local iw = (image and image:getWidth() or size) * (state.drawScale or 1)
        local ih = (image and image:getHeight() or size) * (state.drawScale or 1)
        local w = iw * hitSizeMultiplier
        local h = ih * hitSizeMultiplier
        local attackBox = { x = state.x - w/2, y = state.y - h/2, width = w, height = h }
        local isColliding = require("collisions")
        for _, enemy in pairs(enemySet) do
            if enemy and not state.hitEnemies[enemy] and isColliding(attackBox, enemy) then
                -- apply damage
                if enemy.decreaseHealth then
                    enemy:decreaseHealth(damage)
                else
                    enemy.health = (enemy.health or 0) - damage
                end
                -- knockback
                local ex = (enemy.x or 0) + (enemy.width or 0)/2
                local ey = (enemy.y or 0) + (enemy.height or 0)/2
                local kdx = ex - state.x
                local kdy = ey - state.y
                local dist = math.sqrt(kdx*kdx + kdy*kdy)
                if dist == 0 then dist = 0.0001 end
                local kb = enemy.knockback or 20
                enemy.x = enemy.x + (kdx / dist) * kb
                enemy.y = enemy.y + (kdy / dist) * kb
                state.hitEnemies[enemy] = true
            end
        end
    end

    if state.mode == "out" then
        -- accumulate distance traveled from player origin
        local dx = state.x - px
        local dy = state.y - py
        state.dist = math.sqrt(dx*dx + dy*dy)

        if state.dist >= range then
            -- start return; reset hit list so return can hit enemies again
            state.hitEnemies = {}
            local rdx = px - state.x
            local rdy = py - state.y
            local rd = math.sqrt(rdx*rdx + rdy*rdy)
            if rd == 0 then rd = 0.0001 end
            state.vx = (rdx / rd) * returnSpeed
            state.vy = (rdy / rd) * returnSpeed
            state.mode = "return"
        end
    elseif state.mode == "return" then
        -- recompute return velocity each frame so boomerang tracks moving player
        local rdx = px - state.x
        local rdy = py - state.y
        local rd = math.sqrt(rdx*rdx + rdy*rdy)
        if rd == 0 then rd = 0.0001 end
        state.vx = (rdx / rd) * returnSpeed
        state.vy = (rdy / rd) * returnSpeed

        -- check arrival
        if rd <= 16 then
            -- reached player; become idle and start cooldown before next launch
            state.mode = "idle"
            state.vx, state.vy = 0, 0
            state.angle = 0
            state.cooldownTimer = waitAfterReturn
            -- place boomerang exactly at player's center
            state.x = px
            state.y = py
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
end

return Boomerang
