-- ui_upgradeMenu.lua
-- Handles drawing and input for the upgrade selection overlay.

local uiUpgradeMenu = {}

function uiUpgradeMenu.draw(screenW, screenH, upgradeChoices)
    local rects = {}
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    love.graphics.setColor(1, 1, 1)
    local header = "Level Up! use mouse or number keys to select your upgrade"
    local headerY = screenH/2 - 160
    love.graphics.printf(header, 0, headerY, screenW, "center")

    local desiredBoxW, boxH = 300, 120
    local gap = 20
    local margin = 20
    local n = #upgradeChoices
    local totalNeeded = desiredBoxW * n + gap * (n - 1)
    local boxW = desiredBoxW
    local startX = 0
    if totalNeeded <= (screenW - 2 * margin) then
        startX = (screenW - totalNeeded) / 2
    else
        boxW = math.floor((screenW - 2 * margin - gap * (n - 1)) / n)
        if boxW < 80 then boxW = 80 end
        startX = margin
    end

    for i, up in ipairs(upgradeChoices) do
        local bx = startX + (i - 1) * (boxW + gap)
        local by = screenH / 2 - boxH / 2
        love.graphics.setColor(0.12, 0.12, 0.12, 0.95)
        love.graphics.rectangle("fill", bx, by, boxW, boxH, 8, 8)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(up.name, bx + 12, by + 10)
        local descX = bx + 12
        local descY = by + 36
        local descWidth = boxW - 24
        love.graphics.printf(up.desc, descX, descY, descWidth, "left")
        local numLabel = "(" .. i .. ")"
        love.graphics.print(numLabel, bx + boxW - 28, by + 10)
        rects[i] = { x = bx, y = by, width = boxW, height = boxH }
    end
    return rects
end

function uiUpgradeMenu.handleMouse(rects, upgradeChoices, isClicking)
    if not rects or not upgradeChoices then return nil end
    for i, rect in ipairs(rects) do
        if isClicking(rect) then
            return upgradeChoices[i]
        end
    end
    return nil
end

function uiUpgradeMenu.handleKey(key, upgradeChoices)
    if not upgradeChoices then return nil end
    local n = tonumber(key)
    if n and upgradeChoices[n] then
        return upgradeChoices[n]
    end
    if key:sub(1,2) == "kp" then
        local k = tonumber(key:sub(3))
        if k and upgradeChoices[k] then
            return upgradeChoices[k]
        end
    end
    return nil
end

return uiUpgradeMenu
