function update(player, yaleEnemy, key_mappings, dt)
    local input = {x = 0, y = 0}

    local isDown = love.keyboard.isDown

    if isDown(key_mappings.up) then input.y = -1 end
    if isDown(key_mappings.down) then input.y = 1 end
    if isDown(key_mappings.left) then input.x = -1 end
    if isDown(key_mappings.right) then input.x = 1 end

    player.x = player.x + input.x * player.speed * dt
    player.y = player.y + input.y * player.speed * dt

    vX = player.x - yaleEnemy.x
    vY = player.y - yaleEnemy.y

    yaleEnemy.x = yaleEnemy.x + (vX / math.sqrt(vX^2 + vY^2)) * yaleEnemy.speed * dt
    yaleEnemy.y = yaleEnemy.y + (vY / math.sqrt(vX^2 + vY^2)) * yaleEnemy.speed * dt
end
return {
    update = update
}