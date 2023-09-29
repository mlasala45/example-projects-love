local thick = 5
local radius = HEX_RADIUS_SHORT - thick
local dot_radius = 5

local YieldsRenderer = Class(Prefab, function(self, map)
	self.base._ctor(self, 0, 0)

	self.map = map

	self.layer = LAYERS.MAP_CONTROL
end)

function YieldsRenderer:Draw()
	if SHOW_YIELDS then
		self.map:DrawYields()
	end
end

return YieldsRenderer