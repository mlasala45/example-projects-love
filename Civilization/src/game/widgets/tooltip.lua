local width = 60*1.2
local height = 40*1.2
local thick = 2*1.2

local Tooltip = Class(Widget, function(self, x, y)
	self.base._ctor(self, "Tooltip", x, y)
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.bg = self:AddChild(Box(0,0,width,height,thick,self.color1,self.color2))

	self.text = self:AddChild(IconText(thick,thick,"",COLORS.WHITE, false))
end)

function Tooltip:Update(dt)
	local excess_x = (MX + self.bg.w) - WINDOW_WIDTH
	local excess_y = (MY + self.bg.h) - WINDOW_HEIGHT
	if excess_x > 0 then MX = WINDOW_WIDTH - (self.bg.w) end
	if excess_y > 0 then MY = WINDOW_HEIGHT - (self.bg.h) end

	self.Transform:SetPosition(MX, MY)
end

function Tooltip:SetText(text, w)
	self:Show()

	if self.text.text == text then return end
	
	self.text.w = w
	self.text.ww = w

	self.text:SetText(text)

	self.bg.w = self.text:GetWidth() + thick*2
	self.bg.h = self.text:GetHeight() + thick*2
end

function Tooltip:IsFocused(mx, my)
	return false
end

return Tooltip