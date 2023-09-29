local width = 250*1.2
local height = 100*1.2
local thick = 5*1.2

local portrait_offset = 62
local portrait_radius = 85*1.2 / 2
local portrait_thick = thick
local portrait_scale = 1.8

local Bar = require("game/widgets/bar")

local info_start = portrait_offset+portrait_radius+thick

local TileInfoBox = Class(Widget, function(self, x, y)
	self.base._ctor(self, "TileInfoBox", x, y)
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.bg = self:AddChild(RoundedBox(0, 0, width, height, thick, self.color2, self.color1, 10))

	self.title = self:AddChild(Text(info_start, 20, "Title", COLORS.YELLOW, false))
	self.title.Transform:SetScale(1.5)

	self.portrait = self:AddChild(Image(portrait_offset, height/2, "portrait_plains", "tex"))
	self.portrait.Transform:SetScale(portrait_scale)
end)

function TileInfoBox:Draw()
	local x, y = self.Transform:GetAbsolutePosition()

	geo.drawBorderedCircle(x+portrait_offset, y+height/2, portrait_radius, portrait_thick, self.color1, self.color2)

	self.base.Draw(self)
end

local function determine_portrait(cell)
	if cell.terrain == "mountain" then return "portrait_mountain" end
	if cell.vegetation == "forest" then return "portrait_forest" end
	if cell.terrain == "hills" then return "portrait_hills" end
	return cell.biome.portrait
end

function TileInfoBox:LoadTile(cell, hide_info)
	local str = cell.biome.name.."("..cell.x..", "..cell.y..")"
	local say_terrain = (cell.terrain and cell.terrain~="flat")
	local say_vegetation = (cell.vegetation and cell.vegetation~="none")
	if say_terrain or say_vegetation then str = str.."\n" end
	if say_terrain then
		str = str..STRINGS.FEATURES[string.upper(cell.terrain)]
		if say_vegetation then str = str..", " end
	end
	if say_vegetation then str = str..STRINGS.FEATURES[string.upper(cell.vegetation)] end
	--[[str = str.."\nVisibility: "
	local vis = cell.visibility[TheGameManager.player_num]
	if vis == 2 then
		str = str.."Visible"
	elseif vis == 1 then
		str = str.."Explored"
	else
		str = str.."Unexplored"
	end]]

	if cell.worldgen then
		str = str.."\nHeat: "..cell.worldgen.heat
		str = str.."\nMoisture: "..cell.worldgen.moisture
	end

	if hide_info then
		self.title.text = "Unexplored ("..cell.x..", "..cell.y..")"
		self.portrait.atlas = "portrait_fogofwar"
	else
		self.title.text = str
		self.portrait.atlas = determine_portrait(cell)
	end

	self.title:Recalc()
end

return TileInfoBox