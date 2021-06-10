
project = "a-star-lua"

--description = "A* pathfinding algorithm for Lua"

description = [[
A clean, simple implementation of the A* pathfinding algorithm for Lua.

This implementation has no dependencies and has a simple interface. It
takes a table of nodes, a start and end point and a "valid neighbor"
function which makes it easy to adapt the module's behavior, especially
in circumstances where valid paths would frequently change.
]]

file = {
	"astar.lua",
}

examples = {
	"test.lua",
}

topics = {
	"README.md",
	"LICENSE.md",
}
