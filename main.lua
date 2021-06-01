--[[ Pacman
A recreation of pacman in love2d.

Todo:
- Ghosts
  - Blinky
  - Pinky
  - Inky
  - Clyde
- Dying
- Level count display
- Life count display
- Cheats (accessed using the Konami code)
  - Noclip (snap to grid when disabling)
- Transitions
  - Countdown before starting
- Menu
- Highscores
- Don't animate pacman when at wall

Notes:
- A lot of sprites will need to be offset by 7 to fix rotation
- bump.lua may not end up being used
- Consolas.ttf may not end up being used
]]

local lovesize = require("lovesize")

local cache = {}
local gamestate = { isPaused = false, score = 0, lives = 3, level = 1 }
local map = { loaded = false } -- Map quad cache
local animation = {pacman = {}, blinky = {{}, {}, {}, {}}}

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
                               {outer_wall, 2},
                               {outer_wall, 4},
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
                               {outer_wall, 2},
                               {outer_wall, 4},
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
                               {outer_wall, 2},
                               {outer_wall, 4},
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
                               {outer_wall_corner_out, 4},
                               {outer_wall_corner_out, 3},
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
                               {cage_door, 1},
                               {cage_door, 1},
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
    table.insert(map_layout, { {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {pellet, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {cage, 2},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {cage, 2},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {pellet, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1}, {blank, 1} }) -- Extra blank to prevent the movement system from crashing when going thru tunnel
    table.insert(map_layout, { {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall_corner_out, 2},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall_corner_out, 2},
                               {blank, 1},
                               {cage, 2},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {blank, 1},
                               {cage, 2},
                               {blank, 1},
                               {wall_corner_out, 1},
                               {wall_corner_out, 2},
                               {pellet, 1},
                               {outer_wall_corner_out, 1},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3} })
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
                               {cage_corner, 4},
                               {cage, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage, 1},
                               {cage_corner, 3},
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
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_out, 2},
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
    table.insert(map_layout, { {outer_wall_corner_in, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall, 1},
                               {outer_wall_corner_out, 3},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall_corner_out, 3},
                               {blank, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_in, 2},
                               {wall_corner_in, 1},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {blank, 1},
                               {wall_corner_out, 4},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {outer_wall_corner_out, 4},
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
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall_corner_in, 2},
                               {wall, 2},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {wall, 4},
                               {wall_corner_in, 1},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall, 4},
                               {power_pellet, 1},
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
                               {blank, 1},
                               {blank, 1},
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
                               {power_pellet, 1},
                               {outer_wall, 2} })
    table.insert(map_layout, { {outer_wall_corner_in, 4},
                               {outer_wall, 3},
                               {outer_wall_corner_out, 2},
                               {pellet, 1},
                               {wall, 4},
                               {wall, 2},
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
                               {wall, 4},
                               {wall, 2},
                               {pellet, 1},
                               {outer_wall_corner_out, 1},
                               {outer_wall, 3},
                               {outer_wall_corner_in, 3} })
    table.insert(map_layout, { {outer_wall_corner_in, 1},
                               {outer_wall, 1},
                               {outer_wall_corner_out, 3},
                               {pellet, 1},
                               {wall_corner_out, 4},
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
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {outer_wall_corner_out, 4},
                               {outer_wall, 1},
                               {outer_wall_corner_in, 2} })
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
    table.insert(map_layout, { {outer_wall, 4},
                               {pellet, 1},
                               {wall_corner_out, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall, 1},
                               {wall_corner_in, 3},
                               {wall_corner_in, 4},
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
                               {wall_corner_in, 3},
                               {wall_corner_in, 4},
                               {wall, 1},
                               {wall, 1},
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
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall_corner_out, 3},
                               {pellet, 1},
                               {wall_corner_out, 4},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
                               {wall, 3},
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
    table.insert(map_layout, { {outer_wall_corner_in, 4},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall, 3},
                               {outer_wall_corner_in, 3} })
    
    map_layout[15][0] = {blank, 1} -- Again, to prevent the movement system from completely freaking out
    
    for y, r in ipairs(map_layout) do
        for x, c in ipairs(r) do
            if c[1] == wall_corner_out or c[1] == wall_corner_in or c[1] == wall or c[1] == cage_corner or c[1] == cage or c[1] == outer_wall_corner_out or c[1] == outer_wall_corner_in or c[1] == outer_wall or c[1] == cage_door then
                c[4] = c[3]
                c[3] = true
            else
                c[4] = c[3]
                c[3] = false
            end
        end
    end
end
create_layout()

local map_key

local buffer

local debugEnabled = true
local ultraVerbose = false

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
    table.insert(animation.pacman, love.graphics.newQuad(20, 1, 12, 13, w, h))
    table.insert(animation.pacman, love.graphics.newQuad(4, 1, 9, 13, w, h))
    table.insert(animation.blinky[1], love.graphics.newQuad(4, 65, 14, 14, w, h)) -- Right
    table.insert(animation.blinky[1], love.graphics.newQuad(20, 65, 14, 14, w, h))
    table.insert(animation.blinky[2], love.graphics.newQuad(100, 65, 14, 14, w, h)) -- Down
    table.insert(animation.blinky[2], love.graphics.newQuad(116, 65, 14, 14, w, h))
    table.insert(animation.blinky[3], love.graphics.newQuad(36, 65, 14, 14, w, h)) -- Left
    table.insert(animation.blinky[3], love.graphics.newQuad(52, 65, 14, 14, w, h))
    table.insert(animation.blinky[4], love.graphics.newQuad(68, 65, 14, 14, w, h)) -- Up
    table.insert(animation.blinky[4], love.graphics.newQuad(84, 65, 14, 14, w, h))
    map.loaded = true
end

local function align(x, y)
    return math.floor(x/14)*14, math.floor(y/14)*14
end

local function getTile(x, y)
    return math.floor(x/14), math.floor(y/14)-1
end

-- OOP Style Stuff

local function newMovable(x, y, direction)
    local movable = {}
    movable.x = x or 0
    movable.y = y or 0
    movable.direction = direction or 0
    return movable
end

local function newPacman(x, y, direction)
    x = x or 196
    y = y or 343
    direction = direction or 0
    local pacman = newMovable(x, y, direction)
    pacman.new_direction = pacman.direction
    pacman.animframe = 0
    function pacman:update()
        local speed = 1
        local tilex, tiley = getTile(self.x, self.y)
        if tilex == 28 and tiley == 14 and self.direction == 0 then
            self.x = -7 -- teleport him to the other side
            self.new_direction, self.direction = 0, 0
        elseif tilex == -1 and tiley == 14 and self.direction == 2 then
            self.x = 28*14+7 -- teleport him to the other side
            self.new_direction, self.direction = 2, 2
        elseif self:check_pos() then
            local vel = self:dirToVel()
            self.x = self.x + vel.x * speed
            self.y = self.y + vel.y * speed
        end
    end
    function pacman:check_pos()
        local vel = self:dirToVel()
        local turn = self:ndirToVel()
        if (self.x-7)%14 == 0 and (self.y-7)%14 == 0 then
            -- Check for pellets on current tile
            local curpos = {}
            curpos.x, curpos.y = getTile(self.x, self.y)
            
            if map_layout[curpos.y+1][curpos.x+1][1] == 9 then -- pellet
                map_layout[curpos.y+1][curpos.x+1][1] = 12 -- blank
                gamestate.score = gamestate.score + 10
            elseif map_layout[curpos.y+1][curpos.x+1][1] == 10 then -- power pellet
                map_layout[curpos.y+1][curpos.x+1][1] = 12 -- blank
                gamestate.score = gamestate.score + 10
                -- scare ghosts
            end

            local newpos = {}
            newpos.x, newpos.y = getTile(self.x, self.y)
            newpos.x, newpos.y = newpos.x + turn.x, newpos.y + turn.y
            
            if map_layout[newpos.y + 1][newpos.x + 1][3] then
                if map_layout[curpos.y + vel.y + 1][curpos.x + vel.x + 1][3] then
                    return false
                else
                    return true
                end
            else
                self.direction = self.new_direction
                return true
            end
        else
            if (self.direction-self.new_direction)%2 == 0 then
                self.direction = self.new_direction
            end
            local tx, ty = getTile(self.x, self.y)
            if map_layout[ty+1][tx+1][1] == 9 then -- pellet
                map_layout[ty+1][tx+1][1] = 12 -- blank
                gamestate.score = gamestate.score + 10
            elseif map_layout[ty+1][tx+1][1] == 10 then -- power pellet
                map_layout[ty+1][tx+1][1] = 12 -- blank
                gamestate.score = gamestate.score + 10
            end
            return true
        end
    end
    function pacman:draw()
        love.graphics.draw(cache.spritesheet, animation.pacman[math.floor(self.animframe)%2+1], self.x, self.y, self.direction*0.5*3.14159, 1, 1, 7, 7)
    end
    function pacman:dirToVel()
        local vel = {x = 0, y = 0}
        if self.direction == 0 then
            vel.x = 1
        elseif self.direction == 1 then
            vel.y = 1
        elseif self.direction == 2 then
            vel.x = -1
        else
            vel.y = -1
        end
        return vel
    end
    function pacman:ndirToVel()
        local vel = {x = 0, y = 0}
        if self.new_direction == 0 then
            vel.x = 1
        elseif self.new_direction == 1 then
            vel.y = 1
        elseif self.new_direction == 2 then
            vel.x = -1
        else
            vel.y = -1
        end
        return vel
    end
    return pacman
end

local function newGhost(x, y, direction)
    local ghost = newMovable(x, y, direction)
    function ghost:update() end
    function ghost:draw() end
    return ghost
end

local function newBlinky(x, y, direction)
    x = x or 14*14-7
    y = y or 12*14
    local ghost = newGhost(x, y, direction)
    function ghost:draw()
        love.graphics.draw(cache.spritesheet, animation.blinky[self.direction+1][1], self.x, self.y)
    end
    return ghost
end

local function reset()
    gamestate.player = newPacman()
    gamestate.blinky = newBlinky()
    gamestate.ghostmode = 0 -- Chase mode
end

local function reset_game()
    map_layout = {}
    create_layout()
    reset()
end

function love.load()
    lovesize.set(395, 476)
    buffer = love.graphics.newCanvas(395, 490)
    reset()
    cache.font = love.graphics.newFont("assets/consolas.ttf", 35)
    cache.spritesheet = love.graphics.newImage("assets/sprites.png")
    load_map() -- Load map related quads
    map_key = {map.wall_corner_out, map.wall_corner_in, map.wall, map.cage_corner, map.cage, map.outer_wall_corner_out, map.outer_wall_corner_in, map.outer_wall, map.pellet, map.power_pellet, map.cage_door, map.blank}
end

local function update()
    if gamestate.isPaused then
        
    else
        if gamestate.score == 2440 * gamestate.level then
            reset_game()
            gamestate.level = gamestate.level + 1
        end
        gamestate.player:update()
    end
end

do
    local time_past = 0
    function love.update(dt)
        time_past = time_past + dt
        if time_past > 3 then
            time_past = 0
        end
        while time_past >= 0.016 do -- 0.016 is approx. 1/60 (game should run at 60 fps)
            time_past = time_past - 0.016
            update()
        end
    end
end

function love.draw()
    love.graphics.setCanvas(buffer)
    love.graphics.clear(0, 0, 0)
    local spritesheet = cache.spritesheet
    for i, v in ipairs(map_layout) do
        for j, v in ipairs(v) do
            if v[1] == 12 then
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle('fill', 14*j-14, 14*i, 14, 14)
                love.graphics.setColor(1, 1, 1, 1)
            else
                local ox, oy = 0, 0
                if v[1] == 1 and v[4] then oy = -1 end
                love.graphics.draw(spritesheet, map_key[v[1]], 14*j-7+ox, 14*i+7+oy, 3.14159*0.5*(v[2]-1), 1, 1, 7, 7)
            end
        end
    end
    --love.graphics.rectangle('line', 189, 336, 14, 14)
    if debugEnabled then
        local ax, ay = align(gamestate.player.x, gamestate.player.y)
        love.graphics.rectangle('line', ax, ay, 14, 14)
        local vel = gamestate.player:dirToVel()
        local turn = gamestate.player:ndirToVel()
        ax, ay = align(gamestate.player.x + vel.x*14, gamestate.player.y + vel.y*14)
        love.graphics.rectangle('line', ax, ay, 14, 14)
        ax, ay = align(gamestate.player.x + turn.x*14, gamestate.player.y + turn.y*14)
        love.graphics.rectangle('line', ax, ay, 14, 14)
        ax, ay = align(gamestate.blinky.x, gamestate.blinky.y)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('line', ax, ay, 14, 14)
        love.graphics.setColor(1, 1, 1, 1)
    end
    gamestate.player:draw()
    gamestate.blinky:draw()
    --love.graphics.rectangle('line', 0, 14, 28*14, 31*14)
    love.graphics.setCanvas()
    lovesize.begin()
    love.graphics.draw(buffer)
    
    if gamestate.isPaused then
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle('fill', 0, 0, 395, 476)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('fill', 160, 200, 25, 81)
        love.graphics.rectangle('fill', 210, 200, 25, 81)
    else
        gamestate.player.animframe = gamestate.player.animframe + 0.1
    end
    
    lovesize.finish()
    
    love.graphics.rectangle('fill', 10, 10, 10, 30)
    love.graphics.rectangle('fill', 30, 10, 10, 30)
    
    if debugEnabled then
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 0, 50)
        love.graphics.print("X: " .. tostring(gamestate.player.x), 0, 60)
        love.graphics.print("Y: " .. tostring(gamestate.player.y), 0, 70)
        local x, y = align(gamestate.player.x, gamestate.player.y)
        love.graphics.print("Align: " .. tostring(x) .. ", " .. tostring(y), 0, 80)
        x, y = getTile(gamestate.player.x, gamestate.player.y)
        love.graphics.print("Block: " .. tostring(x) .. ", " .. tostring(y), 0, 90)
        love.graphics.print("Score: " .. tostring(gamestate.score), 0, 100)
    end
end

function love.keypressed(k)
    if ultraVerbose then
        print("Keypress: " .. k)
    end
    if k == 'escape' then
        gamestate.isPaused = not gamestate.isPaused
    elseif not gamestate.isPaused then
        if k == "right" or k == "d" or k == "l" then
            gamestate.player.new_direction = 0
        elseif k == "down" or k == "s" or k == "k" then
            gamestate.player.new_direction = 1
        elseif k == "left" or k == "a" or k == "j" then
            gamestate.player.new_direction = 2
        elseif k == "up" or k == "w" or k == "i" then
            gamestate.player.new_direction = 3
        end
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if ultraVerbose then
        print("Mouseup - Button " .. tostring(button) .. " (" .. tostring(x) .. ", " .. tostring(y) .. ") Is touch? " .. tostring(istouch) .. " Presses: " .. tostring(presses))
    end
    if button == 1 and gamestate.isPaused then
        gamestate.isPaused = false
    elseif button == 1 and not gamestate.isPaused and x < 50 and y < 50 then
        gamestate.isPaused = true
    end
end

function love.resize(w, h)
    lovesize.resize(w, h)
end

function love.focus(f)
    if not f then
        gamestate.isPaused = true
        if ultraVerbose then
            print("Focus lost, pausing")
        end
    end
end

function love.quit()
    -- Confirmation dialog?
end
