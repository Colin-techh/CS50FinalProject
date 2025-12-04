local Sword = {}

local swordImage
local attackInterval = 1.5    -- seconds between automatic slashes
local attackDuration = 0.25   -- how long the slash is visible
local reach = 38              -- distance from player's center to sword center

local state = {
    timer = 0,
    attacking = false,
    attackTimer = 0,
    dir = "down",
    drawScale = 1
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
function Sword.update(player, dt)
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
