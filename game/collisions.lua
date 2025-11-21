isColliding = function(obj1, obj2)
    -- Get the bounding boxes of both objects
    local x1, y1, w1, h1 = obj1.x, obj1.y, obj1.width, obj1.height
    local x2, y2, w2, h2 = obj2.x, obj2.y, obj2.width, obj2.height

    -- Check for overlap
    if x1 < x2 + w2 and
       x1 + w1 > x2 and
       y1 < y2 + h2 and
       y1 + h1 > y2 then
        return true
    else
        return false
    end
end
return isColliding