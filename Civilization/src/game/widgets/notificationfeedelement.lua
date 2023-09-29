local width = 80
local height = 80

local radius = width/2

local text_offset = -210

local thick = 5

local NotificationFeedElement = Class(Widget, function(self, data, ui, color1, color2)
	self.base._ctor(self, "NotificationFeedElement", 0, 0)

	self.data = data
	self.ui = ui

	self.color1 = color1
	self.color2 = color2

	self.w = width
	self.h = height

	self.bg = self:AddChild(Circle(0, 0, radius, thick, self.color1, self.color2))
	self.bg.nobounds = true

	self.img = self:AddChild(Image(0, 0, data.portrait, "tex"))

	local w = self.img:GetWidth()
	local h = self.img:GetHeight()
	local s = (radius-thick)*2/math.min(w,h)
	self.img.Transform:SetScale(s)

	self.text = self:AddChild(Text(text_offset/2, 0, data.msg or STRINGS.UI.NOTIFICATIONS.DEFAULT_TEXT, COLORS.WHITE, true, FONTS.DEFAULT_LARGE, 200))
	self.text.Transform:SetScale(0.75)

	self.is_ui = true
	for i,v in ipairs(self.children) do
		v.is_ui = true
	end

	self.click_handler = InputHandler:AddClickHandler(function(mx, my, button)
		if self:IsFocused(mx, my) then self.ui:OnNotificationClicked(self.i, button) end
	end)
end)

function NotificationFeedElement:Destroy()
	InputHandler:RemoveClickHandler(self.click_handler)
end

return NotificationFeedElement