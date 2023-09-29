local thick = 5
local radius = HEX_RADIUS_SHORT - thick
local dot_radius = 5

local RoadsRenderer = Class(Prefab, function(self, map)
	self.base._ctor(self, 0, 0)

	self.map = map

	self.layer = LAYERS.ROADS
end)

function RoadsRenderer:Draw()
	self.map:DrawRoads()
end

return RoadsRenderer