local lovesize = require("lovesize")
local bump = require("bump")

local cache = {}
local gamestate = { isPaused = false }
 map = { loaded = false } -- Map quad cache

-- Map keys based on quad indexes
local map_layout = {}
local function create_layout()
    local wall_corner_out = 1
    local wall_corner_in = 2
    local wall = 3
    local cage_corner = 4
    local cage = 5
    local outer_wall_corner_out = 6
    local outer_wall_corner_in = 7
    local outer_wall = 8
    local pellet = 9
    local power_pellet = 10
    local cage_door = 11
    local blank = 12
    
    table.insert(map_layout, { {outer_wall_corner_in, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall_corner_in, 2},
                               {outer_wall_corner_in, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall_corner_in, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {power_pellet, 1},
                               {wall, 4},
                               {blank, 1},
                               {blank, 1},
                               {wall, 2},
                               {pellet, 1},
                               {wall, 4},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {wall, 2},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {wall, 4},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {wall, 2},
                               {pellet, 1},
                               {wall, 4},
                               {blank, 1},
                               {blank, 1},
                               {wall, 2},
                               {power_pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {pellet, 1},
                               {wall_corner_out, 4, true},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 3, true},
                               {pellet, 1},
                               {wall_corner_out, 4, true},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 3, true},
                               {pellet, 1},
                               {wall_corner_out, 4, true},
                               {wall_corner_out, 3, true},
                               {pellet, 1},
                               {wall_corner_out, 4, true},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 3, true},
                               {pellet, 1},
                               {wall_corner_out, 4, true},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 3, true},
                               {pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_in, 2},
                               {wall_corner_in, 1},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall_corner_in, 4},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall_corner_out, 2},
                               {pellet, 1},
                               {wall, 4},
                               {wall_corner_in, 4},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
                               {blank, 1},
                               {wall, 4},
                               {wall, 2},
                               {blank, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_in, 3},
                               {wall, 2},
                               {pellet, 1},
                               {outer_wall_corner_out, 1},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall_corner_in, 3} })
    table.insert(map_layout, { {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {outer_wall, 4},
                               {pellet, 1},
                               {wall, 4},
                               {wall_corner_in, 1},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {blank, 1},
                               {wall_corner_out, 4},
                               {wall_corner_out, 3},
                               {blank, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_in, 2},
                               {wall, 2},
                               {pellet, 1},
                               {outer_wall, 2},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1} })
    table.insert(map_layout, { {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {outer_wall, 4},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {outer_wall, 2},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1} })
    table.insert(map_layout, { {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {outer_wall, 4},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
                               {blank, 1},
                               {cage_corner, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage_corner, 2},
                               {blank, 1},
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {outer_wall, 2},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1} })
    table.insert(map_layout, { {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall_corner_out, 3},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall_corner_out, 3},
                               {blank, 1},
                               {cage, 4},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {cage, 2},
                               {blank, 1},
                               {wall_corner_out, 4},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {outer_wall_corner_out, 4},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1} })
end
create_layout()

local map_key

local buffer

local debugEnabled = true

local function load_map()
    if map.loaded then
        return
    end
    -- Only 1/4 of the wall textures in the spritesheet is actually used
    -- The rest of the wall textures are different rotations, but since
    -- I'm using Love2d there's no point in having multiple quads of the
    -- same thing when I could just use the rotation parameter of love.graphics.draw()
    
    -- Load size of the spritesheet into local variables
    local w, h = cache.spritesheet:getDimensions()
    
    map.wall_corner_out = love.graphics.newQuad(132, 97, 14, 14, w, h)
    map.wall_corner_in = love.graphics.newQuad(164, 97, 14, 14, w, h)
    map.wall = love.graphics.newQuad(132, 129, 14, 14, w, h)
    map.cage_corner = love.graphics.newQuad(100, 129, 14, 14, w, h)
    map.cage = love.graphics.newQuad(196, 65, 14, 14, w, h)
    map.outer_wall_corner_out = love.graphics.newQuad(164, 129, 14, 14, w, h)
    map.outer_wall_corner_in = love.graphics.newQuad(196, 129, 14, 14, w, h)
    map.outer_wall = love.graphics.newQuad(196, 97, 14, 14, w, h)
    map.pellet = love.graphics.newQuad(164, 49, 14, 14, w, h)
    map.power_pellet = love.graphics.newQuad(180, 49, 14, 14, w, h)
    map.cage_door = love.graphics.newQuad(196, 49, 14, 14, w, h)
    map.blank = love.graphics.newQuad(212, 49, 14, 14, w, h) -- This shouldn't ever be rendered but I'm adding it here just in case something bugs out
    map.loaded = true
end

local function reset()
    -- Map Size: 32x28
    local world = bump.newWorld(32)
    gamestate.world = world
    local wall_index = 0
    for i, v in ipairs(map_layout) do
        for i, v in ipairs(v) do
            print("wall" .. tostring(wall_index) .. " - " .. tostring(v[1]) .. " r " .. tostring(v[2]))
            --world:add("wall" .. tostring(wall_index), 
            wall_index = wall_index + 1
        end
    end
end

function love.load()
    lovesize.set(395, 490)
    buffer = love.graphics.newCanvas(395, 490)
    reset()
    cache.font = love.graphics.newFont("assets/consolas.ttf", 35)
    cache.spritesheet = love.graphics.newImage("assets/sprites.png")
    load_map() -- Load map related quads
    map_key = {map.wall_corner_out, map.wall_corner_in, map.wall, map.cage_corner, map.cage, map.outer_wall_corner_out, map.outer_wall_corner_in, map.outer_wall, map.pellet, map.power_pellet, map.cage_door, map.blank}
end

function love.update(dt)
    if gamestate.isPaused then
        
    else
        
    end
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    --lovesize.begin()
    
    love.graphics.setCanvas(buffer)
    local spritesheet = cache.spritesheet
    for i = 0, 27 do
        for j = 0, 31 do
            love.graphics.draw(spritesheet, map_key[(i+j)%11+1], 14*i, 14+14*j)
        end
    end
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 395, 490)
    love.graphics.setColor(1, 1, 1, 1)
    for i, v in ipairs(map_layout) do
        for j, v in ipairs(v) do
            if v[1] == 12 then
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle('fill', 14*j-14, 14*i, 14, 14)
                love.graphics.setColor(1, 1, 1, 1)
            else
                local ox, oy = 0, 0
                if v[1] == 1 and v[3] then oy = -1 end
                love.graphics.draw(spritesheet, map_key[v[1]], 14*j-7+ox, 14*i+7+oy, 3.14159*0.5*(v[2]-1), 1, 1, 7, 7)
            end
        end
    end
    love.graphics.rectangle('line', 0, 14, 28*14, 32*14)
    --love.graphics.draw(spritesheet, wco, 0, 0)
    love.graphics.setCanvas()
    lovesize.begin()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 800, 600)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(buffer)
    
    lovesize.finish()
    
    if debugEnabled then
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()))
    end
end

function love.resize(w, h)
    lovesize.resize(w, h)
end

function love.focus(f)
    if not f then
        gamestate.isPaused = true
        if debugEnabled then
            print("[DEBUG] Focus lost, pausing")
        end
    end
end

function love.quit()
    -- Confirmation dialog?
end
