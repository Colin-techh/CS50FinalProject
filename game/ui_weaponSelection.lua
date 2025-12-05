-- ui_weaponSelection.lua
-- Handles weapon selection overlay drawing and input.

local uiWeaponSelection = {}

function uiWeaponSelection.buildChoices(screenW, screenH, swordImg, boomImg, pistolImg)
    local choices = {
        { id = "sword", image = swordImg, title = "Sword" },
        { id = "boomerang", image = boomImg, title = "Boomerang" },
        { id = "pistol", image = pistolImg, title = "Pistol" }
    }
    local n = #choices
    local boxW = math.min(300, math.floor((screenW - 80 - (n-1)*20) / n))
    if boxW < 100 then boxW = 100 end
    local boxH = 160
    local gap = 20
    local startX = (screenW - (boxW * n + gap * (n - 1))) / 2
    local rects = {}
    for i, ch in ipairs(choices) do
        local bx = startX + (i-1) * (boxW + gap)
        local by = screenH/2 - boxH/2
        rects[i] = { x = bx, y = by, width = boxW, height = boxH, id = ch.id, image = ch.image, title = ch.title }
    end
    return choices, rects
end

function uiWeaponSelection.draw(screenW, screenH, rects)
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Choose your starting weapon!", 0, screenH/2 - 160, screenW, "center")
    for i, rect in ipairs(rects) do
        love.graphics.setColor(0.12,0.12,0.12,0.95)
        love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height, 8, 8)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(rect.title, rect.x, rect.y + 8, rect.width, "center")
        if rect.image then
            local iw, ih = rect.image:getWidth(), rect.image:getHeight()
            local scale = math.min((rect.width-40)/iw, (rect.height-60)/ih)
            love.graphics.draw(rect.image, rect.x + rect.width/2, rect.y + rect.height/2 + 8, 0, scale, scale, iw/2, ih/2)
        end
        love.graphics.print("("..i..")", rect.x + 8, rect.y + 8)
    end
end

-- Mouse selection (returns id or nil)
function uiWeaponSelection.handleMouse(rects, buffer, isClicking)
    if buffer and buffer > 0 then return nil end
    if not rects then return nil end
    for _, rect in ipairs(rects) do
        if isClicking(rect) then return rect.id end
    end
    return nil
end

-- Keyboard selection (returns id or nil)
function uiWeaponSelection.handleKey(key, rects, buffer)
    if buffer and buffer > 0 then return nil end
    if not rects then return nil end
    local n = tonumber(key)
    if n and rects[n] then return rects[n].id end
    if key:sub(1,2) == "kp" then
        local k = tonumber(key:sub(3))
        if k and rects[k] then return rects[k].id end
    end
    return nil
end

return uiWeaponSelection
