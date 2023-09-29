local width = 60*1.2
local height = 40*1.2
local thick = 2*1.2

local img_bg_radius = 32
local img_bg_thick = 3

local text_x = 70

local BuildingPortrait = Class(Widget, function(self, x, y, buildable)
	self.base._ctor(self, "BuildingPortrait", x, y)
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.img_bg = self:AddChild(Circle(0, 0, img_bg_radius, img_bg_thick, self.color1, self.color2))

	self.img = self:AddChild(Image(0, 0, buildable.portrait, "tex"))
	self.img.Transform:SetScale(1.3)

	local tooltip_str = buildable.desc
	if buildable.yields and table.len(buildable.yields) > 0 then
		tooltip_str = tooltip_str.."\n"
		for k,v in pairs(buildable.yields) do
			tooltip_str = tooltip_str.."\n+"..v.."%"..k.."%"
		end
	end

	self.img.tooltip = { txt=tooltip_str or STRINGS.NO_DESC, w=200 }

	self.text = self:AddChild(Text(text_x, 0, buildable.name or STRINGS.NO_NAME, nil, true, FONTS.DEFAULT_LARGE))
	--self.text.Transform:SetScale(2)

	for i,v in ipairs(self.children) do v.is_ui = true end
end)

function BuildingPortrait:Draw()
	Widget.Draw(self)
end

return BuildingPortrait