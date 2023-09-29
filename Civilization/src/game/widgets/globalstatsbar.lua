local width = 200*1.2
local height = 40*1.2
local thick = 5*1.2
local icon_width = 25

local sci_x = 10
local gold_x = 70
local cult_x = 170

local Bar = require("game/widgets/bar")

local GlobalStatsBar = Class(Widget, function(self, x, y)
	self.base._ctor(self, "GlobalStatsBar", x, y)

	width = WINDOW_WIDTH
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.bg = self:AddChild(RoundedBox(0, 0, width, height, thick, self.color2, self.color1, 10))

	--self.science_stat_icon = self:AddChild(Image(sci_x, height/2, "civ_icons", "yield_sci"))
	--self.science_stat_icon.Transform:SetScale(4)
	self.science_stat_text = self:AddChild(IconText(sci_x, height/2, "%sci%%sep%+118", nil, true, FONTS.DEFAULT_LARGE))
	self.science_stat_text.color = CUSTOM_COLORS.SCIENCE

	--self.gold_stat_icon = self:AddChild(Image(gold_x, height/2, "civ_icons", "yield_gold"))
	--self.gold_stat_icon.Transform:SetScale(4)

	--Ye gods this gets unreadable
	self.gold_stat_text = self:AddChild(IconText(gold_x, height/2, "%gold%%sep%".."437 ".."%oy:-2%( ".."%oy:1%+ ".."%oy:0%42".."%oy:-2% )", nil, true, FONTS.DEFAULT_LARGE))
	self.gold_stat_text.color = CUSTOM_COLORS.GOLD

	self.culture_stat_text = self:AddChild(IconText(cult_x, height/2, "%cult%%sep%+118", nil, true, FONTS.DEFAULT_LARGE))
	self.culture_stat_text.color = CUSTOM_COLORS.CULTURE

	self:RecalcStats()

	self.is_ui = true --clumsy
end)

function GlobalStatsBar:RecalcStats()
	local sci_gain = TheGameManager.current_player.global_science_gain
	local gold_gain = TheGameManager.current_player.global_gold_gain
	local cult_gain = TheGameManager.current_player.global_culture_gain

	local gold = TheGameManager.current_player.global_gold

	local science_tooltip = "SCIENCE!"
	self.science_stat_text:SetText("%sci%%sep%+"..sci_gain)

	self.gold_stat_text:SetText("%gold%%sep%"..gold.." %oy:-2%( ".."%oy:1%+ ".."%oy:0%"..gold_gain.."%oy:-2% )")

	self.culture_stat_text:SetText("%cult%%sep%+"..cult_gain)
	--self.science_stat_icon.tooltip = science_tooltip
end

function GlobalStatsBar:Draw()
	local x, y = self.Transform:GetAbsolutePosition()

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