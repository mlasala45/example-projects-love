local width = 250*1.2
local height = 100*1.2
local thick = 5*1.2

local unitactions_h = 45
local unitactions_w = width
local unitactions_y = -unitactions_h

local ua_x = 25
local ua_y = unitactions_h / 2
local ua_size = 35
local ua_seperation =  10
local ua_scale = 2.5

local portrait_offset = 62
local portrait_radius = 85*1.18 / 2
local portrait_thick = thick
local portrait_scale = 1.8

local Bar = require("game/widgets/bar")

local info_start = portrait_offset+portrait_radius+thick


--Todo: Decide on color scheme
local UnitInfoBox = Class(Widget, function(self, x, y)
	self.base._ctor(self, "UnitInfoBox", x, y)
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	--Title

	self.title = self:AddChild(Text(info_start, 20, "Title", COLORS.YELLOW, false))
	self.title.Transform:SetScale(1.5)
	
	--Portrait

	self.portrait_bg = self:AddChild(Image(portrait_offset, height/2, "portrait_plains", "tex"))
	self.portrait_bg.Transform:SetScale(portrait_scale)
	
	self.portrait = self:AddChild(Image(portrait_offset, height/2, "portrait_warrior", "tex"))
	self.portrait.Transform:SetScale(portrait_scale)

	--Stats
	
	self.hp = 100
	self.maxhp = 100

	self.hp_bar = self:AddChild(Bar(info_start+5, 45, 150, 15, 0, self.hp, self.maxhp, COLORS.YELLOW, COLORS.PURPLE, COLORS.YELLOW))

	self.hp_text = self:AddChild(Text(info_start, 60, "100 / 100 HP", COLORS.YELLOW, false))
	self.mp_text = self:AddChild(Text(info_start, 75, "3 / 3 MP", COLORS.YELLOW, false))

	--Unit Actions

	self.unitactions_bg = self:AddChild(Box(0, unitactions_y, unitactions_w, unitactions_h, thick, self.color1, self.color2))
	self.ua_buttons = {}
end)

function UnitInfoBox:Draw()
	local x, y = self.Transform:GetAbsolutePosition()
	geo.drawBorderedRectangle(x, y, width, height, thick, self.color1, self.color2)

	geo.drawBorderedCircle(x+portrait_offset, y+height/2, portrait_radius, portrait_thick, self.color1, self.color2)

	self.base.Draw(self)
end

function UnitInfoBox:LoadUnit(unit)
	self.unit = unit

	self.title.text = unit.name or "ERROR"
	self.portrait.atlas = unit.type.portrait
	self.portrait_bg.atlas = unit.map:GetCell(unit.cx, unit.cy).biome.portrait

	self.mp_text:SetText(unit.mp.." / "..unit.max_mp.." MP")

	self.title:Recalc()
	self:RecalcUnitActions()
end

function UnitInfoBox:RecalcUnitActions()
	for i,v in ipairs(self.ua_buttons) do
		v:Remove()
	end
	self.ua_buttons = {}

	local ua_list = self.unit:GetUnitActions()
	local x = ua_x
	for i,v in ipairs(ua_list) do
		local clickfn = function()
			self:OnActionClicked(v)
		end
		local inst = self.unitactions_bg:AddChild(Button(x, ua_y, ua_size, ua_size, true, nil, nil, clickfn))
		local img = inst:AddChild(Image(0, 0, v.atlas, v.image))
		img.Transform:SetScale(ua_scale)
		img.tooltip = { txt=v.name, w=200 }
		table.insert(self.ua_buttons, inst)
		x = x + ua_size + ua_seperation
	end
end

function UnitInfoBox:OnActionClicked(action)
	action.fn(self.unit)
end

function UnitInfoBox:Update(dt)
	if self.visible and self.unit then
		self:LoadUnit(self.unit)
	end
end

return UnitInfoBox