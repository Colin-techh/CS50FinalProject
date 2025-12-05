local isClicking = function(obj)
    if love.mouse.isDown(1) then
        local mouseX, mouseY = love.mouse.getPosition()
        if mouseX >= obj.x and mouseX <= obj.x + obj.width and
           mouseY >= obj.y and mouseY <= obj.y + obj.height then
            return true
        end
    end
    return false
end
return isClicking