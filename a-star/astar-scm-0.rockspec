
package = "astar"
version = "scm-0"

source = {
   url = "https://github.com/lattejed/a-star-lua/archive/master.tar.gz",
}

description = {
	summary = "A* pathfinding algorithm for Lua.",
	detailed = [[
		A clean, simple implementation of the A* pathfinding algorithm for Lua.

		This implementation has no dependencies and has a simple interface. It
		takes a table of nodes, a start and end point and a "valid neighbor"
		function which makes it easy to adapt the module's behavior, especially
		in circumstances where valid paths would frequently change.
	]],
	homepage = "https://github.com/lattejed/a-star-lua",
	license = "MIT",
}

dependencies = {
	"lua >= 5.1, < 5.4",
}

build = {
	type = "builtin",
	modules = {
		["astar"] = "astar.lua",
	},
}
