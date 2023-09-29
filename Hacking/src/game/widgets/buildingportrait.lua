local width = 60*1.2
local height = 40*1.2
local thick = 2*1.2

local img_bg_radius = 16
local img_bg_thick = 3

local BuildingPortrait = Class(Widget, function(self, x, y, buildable)
	self.base._ctor(self, "BuildingPortrait", x, y)
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.img_bg = self:AddChild(Circle(0, 0, img_bg_radius, img_bg_thick, self.color1, self.color2))

	self.img = self:AddChild(Image(0, 0, buildable.portrait, "tex"))
	self.img.Transform:SetScale(0.5)

	self.img.tooltip = { txt=buildable.desc, w=200 }
end)

function BuildingPortrait:Update(dt)
	local mx, my = love.mouse:getPosition()
	self.Transform:SetPosition(mx, my)
end

function BuildingPortrait:IsFocused(mx, my)
	return false
end

return BuildingPortrait