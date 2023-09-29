local width = 60*1.2
local height = 40*1.2
local thick = 2*1.2

local Tooltip = Class(Widget, function(self, x, y)
	self.base._ctor(self, "Tooltip", x, y)
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.bg = self:AddChild(Box(0,0,width,height,thick,self.color1,self.color2))

	self.text = self:AddChild(Text(thick,thick,"",COLORS.WHITE, false))
end)

function Tooltip:Update(dt)
	local mx, my = love.mouse:getPosition()
	self.Transform:SetPosition(mx, my)
end

function Tooltip:LoadTooltip(data)
	self:SetText(data.txt, data.w)

	if data.oy then
		self.text.Transform.y = data.oy
	else
		self.text.Transform.y = thick
	end

	if data.no_box then
		self.bg:Hide()
	else
		self.bg:Show()
	end
end

function Tooltip:SetText(text, w)
	self:Show()

	if self.text.text == text then return end
	
	self.text.w = w
	self.text.ww = w or 0

	self.text:SetText(text)

	self.bg.w = self.text.drawable:getWidth() + thick*2
	self.bg.h = self.text.drawable:getHeight() + thick*2
end

function Tooltip:IsFocused(mx, my)
	return false
end

return Tooltip