local border_thick = 10

local title_x = 30
local title_y = 20

local tech_x_start = 63
local tech_y_start = 32
local tech_width = 272
local tech_height = 62
local tech_spacing_x = 94
local tech_spacing_y = 6

local scroll_x = border_thick
local scroll_y = border_thick
local scroll_w = WINDOW_WIDTH - border_thick*2
local scroll_h = WINDOW_HEIGHT - border_thick*2

local text_color = COLORS.WHITE

local ScrollArea = require("game/widgets/scrollarea")
local TechBubble = require("game/widgets/techbubble")
local BuildingPortrait = require("game/widgets/buildingportrait")

local TechTreeScreen = Class(Screen, function(self)
	Screen._ctor(self)

	self.name = "TechTreeScreen"

	self.color1 = CITY_UI_COLOR_PRIMARY
	self.color2 = CITY_UI_COLOR_SECONDARY

	self.bg = self:AddChild(Image(0, 0, "bg_tech", "tex"))
	self.bg.Transform:SetScale(8)
	self.bg_border = self:AddChild(Box(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, border_thick, self.color1))

	self.title = self:AddChild(Text(title_x, title_y, STRINGS.UI.TECH_TREE.TITLE, text_color, false, FONTS.DEFAULT_LARGE, 200))
	self.title.Transform:SetScale(1.5)

	self.scroll_area = self:AddChild(ScrollArea(scroll_x,scroll_y,scroll_w,scroll_h))

	self.bubble_anchor = self:AddChild(Widget("TechTreeScreen Bubble Anchor", 0, 0))
	self.tech_bubbles = {}

	self:LoadTechs()

	for i,v in ipairs(self.children) do v.is_ui = true end
end)

function TechTreeScreen:LoadTechs()
	self.columns = {}

	for k,v in pairs(Techs) do
		local x = tech_x_start + ((tech_width + tech_spacing_x) * v.column)
		local y = tech_y_start + ((tech_height + tech_spacing_y) * (v.row-1))
		
		local tech_bubble = self.bubble_anchor:AddChild(TechBubble(x, y, v))
		self.tech_bubbles[v] = tech_bubble

		if not self.columns[v.column] then self.columns[v.column] = {} end
		table.insert(self.columns[v.column], tech_bubble)
	end
	for k,v in pairs(self.tech_bubbles) do
		v:RecalcConnectors(self.tech_bubbles)
	end
end

function TechTreeScreen:LoadStatuses(player)
	self.player = player
	for k,v in pairs(player.tech_statuses) do
		self.tech_bubbles[k]:SetStatus(v)
	end
end

function TechTreeScreen:Draw()
	Screen.Draw(self)
end

return TechTreeScreen