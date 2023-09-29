local thick = 5
local radius = HEX_RADIUS_SHORT - thick
local dot_radius = 5

local TargetingUI = Class(Prefab, function(self)
	self.base._ctor(self, 0, 0)

	self.pressed = false

	self.unit = nil

	self.data = {}

	self.valid_cells = {}

	self.layer = LAYERS.UNIT_CONTROL
end)

function TargetingUI:Update(dt)
	if self.wait_to_end_selection and not love.mouse.isDown(2) then
		self.wait_to_end_selection = false
		self:EndSelection()
	end
	if self.unit then
		--
	end
end

function TargetingUI:Draw(dt)
	if self.is_active then
		print("TargetingUI - "..self.targetmode.name)
		print(self.str)

		self.targetmode.maindrawfn(self.unit)
	end
end

function TargetingUI:TargetFromUnit(unit, targetmode, uaction)
	self.unit = unit
	self.targetmode = targetmode
	self.is_active = true
	ThePathfinder:SetLock(true)

	p_print("TargetFromUnit")
	self.uaction = uaction
	self.valid_cells = uaction.cellfn(unit)
	self.targetmode.onstartfn(unit)
end

function TargetingUI:OnClick(x, y, button)
	self.str = x.." "..y.." "..button
end

function TargetingUI:OnClickTarget(cell)
	self.unit = unit
	self.targetmode = targetmode
end

function TargetingUI:EndSelection()
	self.unit = nil
	self.is_active = false
	self.data = {}
	ThePathfinder.target = nil
	ThePathfinder:SetLock(false)
end

function TargetingUI:EndSelectionDelayed()
	self.wait_to_end_selection = true
end

return TargetingUI