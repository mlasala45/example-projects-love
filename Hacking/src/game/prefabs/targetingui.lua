local thick = 5
local radius = HEX_RADIUS_SHORT - thick
local dot_radius = 5

local TargetingUI = Class(Prefab, function(self, x, y)
	self.base._ctor(self, x, y)

	self.pressed = false

	self.unit = nil

	self.data = {}
end)

function TargetingUI:Update(dt)
	if self.unit then
		--
	end
end

function TargetingUI:Draw(dt)
	--
end

function TargetingUI:TargetFromUnit(unit, targetmode)
	self.unit = unit
	self.targetmode = targetmode
end

function TargetingUI:EndSelection()
	self.unit = nil
end

return TargetingUI