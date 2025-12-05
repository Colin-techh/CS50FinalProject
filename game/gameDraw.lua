-- Module for drawing the game world
local gameDraw = {}

-- Draw the game world (background, map, player, enemies, projectiles)
function gameDraw.drawWorld(params)
    local camera = params.camera
    local background = params.background
    local map = params.map
    local player = params.player
    local selectedWeapon = params.selectedWeapon
    local enemySet = params.enemySet
    local projectiles = params.projectiles
    local sword = params.sword
    local boomerang = params.boomerang
    local pistol = params.pistol
    
    -- Attach camera so the view follows the player
    camera:attach()

    -- Draw the background image at the top-left corner (world coordinates)
    love.graphics.draw(background, 0, 0)
    
    -- Draw background map elements (grass) underneath characters
    if map and map.drawGrass then 
        map:drawGrass() 
    end

    -- Draw player
    player:draw()

    -- Draw selected weapon on player
    if selectedWeapon == "pistol" then
        pistol.draw(player)
    elseif selectedWeapon == "sword" then
        sword.draw(player)
    elseif selectedWeapon == "boomerang" then
        boomerang.draw(player, enemySet)
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw enemies
    for index, enemy in pairs(enemySet) do
        enemy:draw()
    end
    
    -- Draw projectiles
    for index, projectile in pairs(projectiles) do
        -- Skip extra boomerang objects (they're drawn in boomerang.draw)
        if not projectile.isExtraProjectile then
            projectile:draw()
        end
    end
    
    -- Draw blocking map elements (rocks / trees) above characters
    if map and map.drawBlocking then 
        map:drawBlocking() 
    end
    
    camera:detach()
end

return gameDraw
