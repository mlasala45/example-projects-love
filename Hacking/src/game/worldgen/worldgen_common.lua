worldgen = {}

local WorldGen_Legacy = require "game/worldgen/legacy"
local WorldGen_Continents = require "game/worldgen/continents"

function worldgen.gen(map, type)
	type.fn(map)
end

WORLDGEN_TYPE = {
	LEGACY = { fn = WorldGen_Legacy },
	CONTINENTS = { fn = WorldGen_Continents },
}


function hex.yieldpass(map)
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x, y)
			cell.yields = map:GetCellYields(cell)
		end
	end
end