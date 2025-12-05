-- map.lua
-- Randomly place trees, rocks (blocking) and grass (non-blocking) across the playfield.

local map = {}
local isColliding = require("collisions")

-- configuration defaults
local WORLD_W, WORLD_H = 800, 600
-- fewer decorations by default so the map isn't crowded
-- defaults reflect a fairly sparse distribution for smaller areas (these will be scaled when loading
-- a very large world). You can override `counts` when calling map.load()
local DEFAULT_COUNTS = { trees = 4, rocks = 3, grass = 12 }

map.objects = {} -- list of objects: {x,y,width,height,image,type,blocking}

-- how big should object hitboxes be relative to the drawn image
local HITBOX_SCALE = 0.25

local function newObj(imgPath, x, y, w, h, typ, blocking)
    local obj = { x = x, y = y, width = w, height = h, type = typ, blocking = blocking }
    if imgPath and love.filesystem.getInfo(imgPath) then
        obj.image = love.graphics.newImage(imgPath)
    else
        obj.image = nil
    end
    -- build a smaller centered hitbox (so collisions feel tighter than the full artwork)
    local hw, hh = math.floor(w * HITBOX_SCALE), math.floor(h * HITBOX_SCALE)
    obj.hitbox = { x = x + (w - hw) / 2, y = y + (h - hh) / 2, width = hw, height = hh }
    return obj
end

-- helper to test collision between a box and any blocking object
function map:collidesWithBlocking(box)
    for _, obj in ipairs(self.objects) do
        if obj.blocking then
            -- prefer the smaller, centered hitbox for gameplay collisions
            local hb = obj.hitbox or { x = obj.x, y = obj.y, width = obj.width, height = obj.height }
            if isColliding(box, hb) then
                return obj
            end
        end
    end
    return nil
end

-- helper to test overlap with any object (used when placing objects / spawning entities)
function map:overlapsAny(box)
    for _, obj in ipairs(self.objects) do
        -- this checks visual overlap against the full artwork rectangle (used during placement/spawning)
        if isColliding(box, obj) then return obj end
    end
    return nil
end

-- draw layers: grass (non-blocking) first so it appears beneath characters, then blocking objects
function map:drawGrass()
    -- draw grass first (under characters)
    for _, obj in ipairs(self.objects) do
        if obj.type == "grass" then
            if obj.image then
                love.graphics.draw(obj.image, obj.x, obj.y, 0, (obj.width / obj.image:getWidth()), (obj.height / obj.image:getHeight()))
            else
                love.graphics.setColor(0.2,0.8,0.2)
                love.graphics.rectangle("fill", obj.x, obj.y, obj.width, obj.height)
                love.graphics.setColor(1,1,1)
            end
        end
    end
end

function map:drawBlocking()
    -- draw blocking objects after characters
    for _, obj in ipairs(self.objects) do
        if obj.blocking then
            if obj.image then
                love.graphics.draw(obj.image, obj.x, obj.y, 0, (obj.width / obj.image:getWidth()), (obj.height / obj.image:getHeight()))
            else
                love.graphics.setColor(0.5,0.3,0.2)
                love.graphics.rectangle("fill", obj.x, obj.y, obj.width, obj.height)
                love.graphics.setColor(1,1,1)
            end
        end
    end
end

-- Fill the map with randomly positioned objects. We ensure objects don't overlap heavily when placed.
function map:generate(opts)
    opts = opts or {}
    local w = opts.width or WORLD_W
    local h = opts.height or WORLD_H
    local counts = opts.counts or DEFAULT_COUNTS
    self.objects = {}

    local safeZones = opts.safeZones or {}

    local function overlapsSafeZones(box)
        for _, s in ipairs(safeZones) do
            -- safe zone is {x,y,width,height}
            if isColliding(box, s) then return true end
        end
        return false
    end

    -- utility to try placing an object without overlapping others or safe zones
    local function place(typeName, imgPath, count, minSize, maxSize, blocking)
        local tries = 0
        for i=1,count do
            local placed = false
            local size = math.random(minSize, maxSize)
            while not placed and tries < 300 do
                tries = tries + 1
                local x = math.random(0, math.max(0, w - size))
                local y = math.random(0, math.max(0, h - size))
                local box = { x = x, y = y, width = size, height = size }
                -- avoid placing on top of safe zones (e.g. player start) or the center area as a fallback
                if not overlapsSafeZones(box) and not (x > w/2 - 40 and x < w/2 + 40 and y > h/2 - 40 and y < h/2 + 40) then
                    if not self:overlapsAny(box) then
                        table.insert(self.objects, newObj(imgPath, x, y, size, size, typeName, blocking))
                        placed = true
                    end
                end
            end
            tries = 0
        end
    end

    -- place grass first (non-blocking, small tufts)
    place("grass", "assets/grass.png", counts.grass or DEFAULT_COUNTS.grass, 18, 36, false)
    -- place rocks
    place("rock", "assets/rock.png", counts.rocks or DEFAULT_COUNTS.rocks, 28, 48, true)
    -- place trees
    place("tree", "assets/tree.png", counts.trees or DEFAULT_COUNTS.trees, 48, 96, true)
end

-- load helper: generate with world size and counts
function map.load(opts)
    opts = opts or {}
    WORLD_W = opts.width or WORLD_W
    WORLD_H = opts.height or WORLD_H
    map:generate(opts)
end

return map
