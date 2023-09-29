local radius = 25
local thick = 2
local portrait_scale = 7
local border_scale_ratio = 0.95

local CitizenCoin = Class(Widget, function(self, x, y, cell)
	self.base._ctor(self, "CitizenCoin", x, y)
	
	self.portrait = self:AddChild(Image(0, 0, "citizencoin_center_disabled", "tex"))
	self.portrait.Transform:SetScale(portrait_scale)

	self.cell = cell

	local width = self.portrait:GetWidth()

	local drawfn = function(inst)
		if inst:IsFocused(MX, MY) then
			local x, y = inst.Transform:GetAbsolutePosition()
			love.graphics.setColor(COLORS.HALF_WHITE)
			love.graphics.circle("fill", x, y, inst:GetWidth()/2)

			print("Coin Status:")
			print(self.status)
			print("LI:")
			print(self.master.DATA.city.locked_in_cells[self.cell])
			print("LO:")
			print(self.master.DATA.city.locked_off_cells[self.cell])
		end
	end

	local clickfn = function(inst)
		self.master:OnCitizenCoinClicked(self.cell)
	end

	self.button = self:AddChild(Button(0, 0, width, width, true, nil, drawfn, clickfn))


	self.border = self:AddChild(Image(0, 0, "citizencoin_border", "tex"))
	self.border.Transform:SetScale(portrait_scale * border_scale_ratio)

	self:SetStatus(0)

	self.is_ui = true
	for i,v in ipairs(self.children) do v.is_ui = true end
end)

-- 0: Not Worked
-- 1: Worked by Automatic Decision
-- 2: Locked In
-- 3: Worked by City Center
function CitizenCoin:SetStatus(num)
	self.status = num
	if num == CitizenStatus.Disabled then
		self.portrait.atlas = "citizencoin_center_disabled"
		--self.color = CUSTOM_COLORS.CITIZEN_DISABLED
	elseif num == CitizenStatus.Enabled then
		self.portrait.atlas = "citizencoin_center_enabled"
		--self.color = CUSTOM_COLORS.CITIZEN_ENABLED
	elseif num == CitizenStatus.Locked then
		self.portrait.atlas = "citizencoin_center_locked"
		--self.color = CUSTOM_COLORS.CITIZEN_ENABLED
	elseif num == CitizenStatus.CityCenter then
		self.portrait.atlas = "citizencoin_center_citycenter"
		--self.color = CUSTOM_COLORS.CITIZEN_ENABLED
	end
end

function CitizenCoin:Draw()
	local x, y = self.Transform:GetAbsolutePosition()

	self.base.Draw(self)
end

return CitizenCoin