local width = 200*1.2
local height = 40*1.2
local thick = 5*1.2

local button_offset = 68
local button_radius = 85*1.2 / 2
local button_thick = thick
local button_scale = 1.8

local button_acc_cap = 0.5

local Bar = require("game/widgets/bar")

local info_start = button_offset+button_radius+thick

local GlobalStatsBar = Class(Widget, function(self, x, y)
	self.base._ctor(self, "GlobalStatsBar", x, y)

	width = WINDOW_WIDTH
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.is_ui = true --clumsy

	self.nextturnbutton = self:AddChild(Button(button_offset, height/2, button_radius*2, button_radius*2, true, COLORS.WHITE, ntb_drawfn, ntb_clickfn))
end)

function GlobalStatsBar:Draw()
	local x, y = self.Transform:GetAbsolutePosition()
	geo.drawBorderedRectangle(x, y, width, height, thick, self.color1, self.color2)

	self.base.Draw(self)
end

--This is REALLY not how buttons are supposed to work; Refactor at some point?
function GlobalStatsBar:Update(dt)
	--
end

function GlobalStatsBar:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	--assert(false, tostring(mx).." "..tostring(my))
	local x, y = self.Transform:GetAbsolutePosition()
	return geo.inbounds(mx,my,x,y,x+width,y+height,self.Transform:GetRotation())
end

function GlobalStatsBar:GetBounds()
	local x, y = self.Transform:GetAbsolutePosition()
	return x,y,x+width,y+height
end

return GlobalStatsBar