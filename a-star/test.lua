
local astar = require "astar"

local graph = {}
graph [ 1 ] = {}
graph [ 1 ].id = 1
graph [ 1 ].x = 0
graph [ 1 ].y = 0
graph [ 1 ].player_id = 1

graph [ 2 ] = {}
graph [ 2 ].id = 2
graph [ 2 ].x = 200
graph [ 2 ].y = 200
graph [ 2 ].player_id = 1

graph [ 3 ] = {}
graph [ 3 ].id = 3
graph [ 3 ].x = -200
graph [ 3 ].y = 200
graph [ 3 ].player_id = 1

graph [ 4 ] = {}
graph [ 4 ].id = 4
graph [ 4 ].x = 200
graph [ 4 ].y = -200
graph [ 4 ].player_id = 2

graph [ 5 ] = {}
graph [ 5 ].id = 5
graph [ 5 ].x = -200
graph [ 5 ].y = -200
graph [ 5 ].player_id = 2

local valid_node_func = function ( node, neighbor )

	local MAX_DIST = 300

	if 	neighbor.player_id == node.player_id and
		astar.distance ( node.x, node.y, neighbor.x, neighbor.y ) < MAX_DIST then
		return true
	end
	return false
end

local path = astar.path ( graph [ 2 ], graph [ 3 ], graph, valid_node_func )

if not path then
	print ( "No valid path found" )
else
	for i, node in ipairs ( path ) do
		print ( "Step " .. i .. " >> " .. node.id )
	end
end