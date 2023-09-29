--Position is irellevant, and does not affect rendering
local HexSelector = Class(Prefab, function(self, map)
	self.base._ctor(self, 0, 0)

	self.map = map

	self.layer = LAYERS.MAP_CONTROL
end)

function HexSelector:Draw()
	--Dynamic Selector
	if self.map.hovered then
		love.graphics.setColor(COLORS.HALF_BLACK)
		local wx, wy = self.map:GetHexCenter(self.map.hovered.x,self.map.hovered.y)
		love.graphics.setLineWidth(4)
		love.graphics.polygon("line", HexVerts(wx, wy, TheCamera.sx, TheCamera.sy))
		love.graphics.setLineWidth(1)
	end

	--Static Selector (After click)
	if self.map.selected then
		love.graphics.setColor(COLORS.WHITE)
		local wx, wy = self.map:GetHexCenter(self.map.selected.x,self.map.selected.y)
		love.graphics.setLineWidth(4)
		love.graphics.polygon("line", HexVerts(wx, wy, TheCamera.sx, TheCamera.sy))
		love.graphics.setLineWidth(1)
	end
end

return HexSelector