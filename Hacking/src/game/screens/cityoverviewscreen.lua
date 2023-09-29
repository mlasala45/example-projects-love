local title_bg_w = 500
local title_bg_h = 60
local thick = 5
local ui_seperation = 10
local building_portrait_seperation = 10
local building_portrait_radius = 16

local pop_bg_w = 200
local pop_bg_h = 300

local buildings_bg_w = 200
local buildings_bg_h = 300
local buildings_list_y = 20

local yields_bg_w = 200
local yields_bg_h = 300
local yields_offset = 195
local yields_seperation = 20
local pop_text_offset = 30

local portrait_offset = 80
local portrait_radius = 95*1.18 / 2
local portrait_scale = 1.8
local portrait_thick = thick

local production_bg_w = 400
local production_bg_h = 300

local text_color = COLORS.WHITEs

local ProductionQueue = require("game/widgets/productionqueue")
local BuildingPortrait = require("game/widgets/buildingportrait")

local CityOverviewScreen = Class(Screen, function(self)
	Screen._ctor(self)

	self.color1 = CITY_UI_COLOR_PRIMARY
	self.color2 = CITY_UI_COLOR_SECONDARY

	--Boxes
	self.box1 = self:AddChild(Box(MID_X - title_bg_w/2, 0, title_bg_w, title_bg_h, thick, self.color1, self.color2)) --Title
	self.box2 = self:AddChild(Box(WINDOW_WIDTH-pop_bg_w, 0, pop_bg_w, pop_bg_h, thick, self.color1, self.color2)) --Population
	self.box3 = self:AddChild(Box(0, 0, yields_bg_w, yields_bg_h, thick, self.color1, self.color2)) --Yields
	self.box4 = self:AddChild(Box(WINDOW_WIDTH-pop_bg_w, pop_bg_h + ui_seperation, buildings_bg_w, buildings_bg_h, thick, self.color1, self.color2)) --Buildings

	for i=1,4 do self["box"..i].is_ui = true end

	self.title = self:AddChild(Text(MID_X, 30, "City Name", text_color, true, FONTS.DEFAULT_LARGE, 150))
	self.title.Transform:SetScale(2)

	self.population = self:AddChild(Image(yields_bg_w/2, portrait_offset, "citizen", "tex"))
	self.population.Transform:SetScale(8)

	--Yields
	self.y_food_text       = self:AddChild(Text(yields_bg_w/2, yields_offset                    , "Food: 0", text_color, true, FONTS.DEFAULT_LARGE, 150))
	self.y_production_text = self:AddChild(Text(yields_bg_w/2, yields_offset+yields_seperation  , "Production: 0", text_color, true, FONTS.DEFAULT_LARGE, 150))
	self.y_gold_text       = self:AddChild(Text(yields_bg_w/2, yields_offset+yields_seperation*2, "Gold: 0", text_color, true, FONTS.DEFAULT_LARGE, 150))
	self.y_science_text    = self:AddChild(Text(yields_bg_w/2, yields_offset+yields_seperation*3, "Science: 0", text_color, true, FONTS.DEFAULT_LARGE, 150))
	self.y_culture_text    = self:AddChild(Text(yields_bg_w/2, yields_offset+yields_seperation*4, "Culture: 0", text_color, true, FONTS.DEFAULT_LARGE, 150))

	self.population_text = self:AddChild(Text(yields_bg_w/2, portrait_offset+portrait_radius+pop_text_offset, "Population: 1", text_color, true, FONTS.DEFAULT_LARGE, 150))

	self.buildqueue = self:AddChild(ProductionQueue(0, WINDOW_HEIGHT-production_bg_h, production_bg_w, production_bg_h, self.color1, self.color2))

	self.building_icons = {}
end)

function CityOverviewScreen:LoadCity(city)
	self.city = city

	self.title:SetText(city.name)

	self.population_text = "Population: "..tostring(city.population)

	self.y_food_text:SetText("Food: "..(city.yields.food or 0))
	self.y_production_text:SetText("Production: "..(city.yields.prod or 0))
	self.y_gold_text:SetText("Gold: "..(city.yields.gold or 0))
	self.y_science_text:SetText("Science: "..(city.yields.sci or 0))
	self.y_culture_text:SetText("Culture: "..(city.yields.cult or 0))

	--self.color1 = city.owner.color1
	--self.color2 = city.owner.color2

	self:RecalcBuildings()

	self.buildqueue:LoadCity(city)
end

function CityOverviewScreen:RecalcBuildings()
	for k,v in pairs(self.building_icons) do
		v:Remove()
	end

	local x = WINDOW_WIDTH - buildings_bg_w / 2
	local y = buildings_list_y
	self.building_icons = {}
	for k,_ in pairs(self.city.buildings) do
		self.building_icons[k] = self:AddChild(BuildingPortrait(x, y, k))
		y = y + building_portrait_radius + building_portrait_seperation 
	end
end

function CityOverviewScreen:Draw()

	--geo.drawBorderedCircle(WINDOW_WIDTH-pop_bg_w/2, portrait_offset, portrait_radius, portrait_thick, self.color1, self.color2)

	--Citizen Portrait Background
	love.graphics.setColor(COLORS.DARK_GREEN)
	love.graphics.circle("fill", yields_bg_w/2, portrait_offset,portrait_radius)
	love.graphics.setColor(COLORS.WHITE)

	--Production Queue
	--geo.drawBorderedRectangle(0, WINDOW_HEIGHT-production_bg_h, production_bg_w, production_bg_h, thick, self.color1, self.color2)

	Screen.Draw(self)
end

return CityOverviewScreen