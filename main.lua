local lovesize = require("lovesize")
local bump = require("bump")

local cache = {}
local gamestate = { isPaused = false }
 map = { loaded = false } -- Map quad cache

-- Map keys based on quad keys
local map_layout = {""}

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
    map.loaded = true
end

local function reset()
    -- Map Size: 32x28
    local world = bump.newWorld(32)
    gamestate.world = world
    local wall_index = 0
    for i, v in ipairs(map_layout) do
        for i = 1, #v do
            local c = v:sub(i, i)
            print("wall" .. tostring(wall_index) .. " - " .. c)
            --world:add("wall" .. tostring(wall_index), 
            wall_index = wall_index + 1
        end
    end
end

function love.load()
    lovesize.set(395, 490)
    reset()
    cache.font = love.graphics.newFont("assets/consolas.ttf", 35)
    cache.spritesheet = love.graphics.newImage("assets/sprites.png")
    load_map() -- Load map related quads
end

function love.update(dt)
    if gamestate.isPaused then
        
    else
        
    end
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    lovesize.begin()
    
    local spritesheet = cache.spritesheet
    local wco = map.wall_corner_out
    for i = 0, 27 do
        for j = 0, 31 do
            love.graphics.draw(spritesheet, wco, 14*i, 14+14*j)
        end
    end
    love.graphics.rectangle('line', 0, 14, 28*14, 32*14)
    --love.graphics.draw(spritesheet, wco, 0, 0)
    
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
