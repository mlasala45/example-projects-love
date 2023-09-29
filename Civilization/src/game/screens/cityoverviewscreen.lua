local title_bg_w = 500
local title_bg_h = 60
local thick = 5
local ui_seperation = 10
local building_portrait_seperation = 10
local building_portrait_radius = 32

local pop_bg_w = 200
local pop_bg_h = 300

local buildings_bg_w = 200
local buildings_bg_h = 300
local buildings_list_y = 40

local yields_bg_w = 200
local yields_bg_h = 300
local yields_offset_x = -85
local yields_offset_y = 115
local yields_seperation = 20
local pop_text_offset = 20

local portrait_offset_x = -55
local portrait_offset_y = 45
local portrait_scale = 4
local portrait_radius = (95*1.18 / 2) * (portrait_scale/8)
local portrait_thick = thick

local culturegrowth_offset_y = 250
local culturegrowth_scale = 4
local culturegrowth_center_scale = 0.62

local production_bg_w = 400
local production_bg_h = 300

local ctzmng_w = 400
local ctzmng_button_h = 15

local text_color = COLORS.WHITE

local ProductionQueue = require("game/widgets/productionqueue")
local BuildingPortrait = require("game/widgets/buildingportrait")

local CityOverviewScreen = Class(Screen, function(self)
	Screen._ctor(self)

	self.name = "CityOverviewScreen"

	--Organization Framework; Improves Readability
	self.ORGANIZER = {}

	self.DATA = {}

	self.color1 = CITY_UI_COLOR_PRIMARY
	self.color2 = CITY_UI_COLOR_SECONDARY

	--Boxes
	local loc_org = {}
	loc_org.box1 = self:AddChild(RoundedBox(MID_X - title_bg_w/2, 0, title_bg_w, title_bg_h, thick, self.color1, self.color2)) --Title
	loc_org.box2 = self:AddChild(RoundedBox(WINDOW_WIDTH-pop_bg_w, 0, pop_bg_w, pop_bg_h, thick, self.color1, self.color2)) --Population
	loc_org.box3 = self:AddChild(RoundedBox(0, 0, yields_bg_w, yields_bg_h, thick, self.color1, self.color2)) --Yields
	loc_org.box4 = self:AddChild(RoundedBox(WINDOW_WIDTH-pop_bg_w, pop_bg_h + ui_seperation, buildings_bg_w, buildings_bg_h, thick, self.color1, self.color2)) --Buildings

	for i=1,4 do
		local name = "box"..i
		loc_org[name].is_ui = true

		self.ORGANIZER[name] = {}
		self.ORGANIZER[name]._inst = loc_org[name]
	end


	local title = self:AddChild(Text(MID_X, 30, "City Name", text_color, true, FONTS.DEFAULT_LARGE, 150))
	title.Transform:SetScale(2)

	self.ORGANIZER.title = { _inst=title }

	--
	--Box 1
	--

	local population = self:AddChild(Image(yields_bg_w/2+portrait_offset_x, portrait_offset_y, "citizen", "tex"))
	population.DoDraw = population.Draw --Must be a child of ROOT for Tooltip to register
	population.Draw = function() end
	population.Transform:SetScale(portrait_scale)

	self.ORGANIZER.box1.population = { _inst=population }

	--Yields
	local y_food_text       = self:AddChild(IconText(yields_bg_w/2+yields_offset_x, yields_offset_y                    , "Food: +0%food%", text_color, true, FONTS.DEFAULT_LARGE, 200))
	local y_production_text = self:AddChild(IconText(yields_bg_w/2+yields_offset_x, yields_offset_y+yields_seperation  , "Production: +0%prod%", text_color, true, FONTS.DEFAULT_LARGE, 200))
	local y_gold_text       = self:AddChild(IconText(yields_bg_w/2+yields_offset_x, yields_offset_y+yields_seperation*2, "Gold: +0%gold%", text_color, true, FONTS.DEFAULT_LARGE, 200))
	local y_science_text    = self:AddChild(IconText(yields_bg_w/2+yields_offset_x, yields_offset_y+yields_seperation*3, "Science: +0%sci%", text_color, true, FONTS.DEFAULT_LARGE, 200))
	local y_culture_text    = self:AddChild(IconText(yields_bg_w/2+yields_offset_x, yields_offset_y+yields_seperation*4, "Culture: +0%cult%", text_color, true, FONTS.DEFAULT_LARGE, 200))

	self.ORGANIZER.box1.yields = {}
	self.ORGANIZER.box1.yields.y_food_text       = { _inst=y_food_text }
	self.ORGANIZER.box1.yields.y_production_text = { _inst=y_production_text }
	self.ORGANIZER.box1.yields.y_gold_text       = { _inst=y_gold_text }
	self.ORGANIZER.box1.yields.y_science_text    = { _inst=y_science_text }
	self.ORGANIZER.box1.yields.y_culture_text    = { _inst=y_culture_text }


	local population_text = self:AddChild(Text(yields_bg_w/2, portrait_offset_y+portrait_radius+pop_text_offset, "Population: 1", text_color, true, FONTS.DEFAULT_LARGE, 200))

	self.ORGANIZER.box1.population_text = { _inst=population_text }


	local culturegrowth_border = self:AddChild(Image(yields_bg_w/2+portrait_offset_x, culturegrowth_offset_y, "culturegrowth_border", "tex"))
	culturegrowth_border.Transform:SetScale(culturegrowth_scale)
	
	self.ORGANIZER.box1.culturegrowth_border = { _inst=culturegrowth_border }

	--
	--Box 2
	--

	--self.ctzmng_dropdown_button = self:AddChild(Button(0, 0, ctzmng_w, ctzmng_button_h, false, nil, drawfn, clickfn))

	--
	--Box 3
	--

	local buildqueue = self:AddChild(ProductionQueue(0, WINDOW_HEIGHT-production_bg_h, production_bg_w, production_bg_h, self.color1, self.color2))

	self.ORGANIZER.box3.buildqueue = { _inst=buildqueue }

	--
	--Box 4
	--

	self.DATA.building_icons = {}

	--Citizen Management
	self.DATA.ctzmng_coins = {}

	for i,v in ipairs(self.children) do v.is_ui = true end
end)

function CityOverviewScreen:LoadCity(city)
	self.DATA.city = city

	self.ORGANIZER.title._inst:SetText(city.name)

	local population = self.ORGANIZER.box1.population._inst
	population.tooltip = {
		txt=("Growth Progress: "..city.stored_food.."/"..city.needed_food),
		w=200,
	}
	if (city.yields.food or 0) > 0 then
		population.tooltip.txt = population.tooltip.txt.."\nTurns Until Growth: "..math.ceil((city.needed_food-city.stored_food)/city.yields.food)
	end

	--Includes center bg; one image
	local culturegrowth_border = self.ORGANIZER.box1.culturegrowth_border._inst
	culturegrowth_border.tooltip = {
		txt=("Culture Progress: "..city.stored_culture.."/"..city.needed_culture),
		w=200,
	}
	if (city.yields.cult or 0) > 0 then
		culturegrowth_border.tooltip.txt = culturegrowth_border.tooltip.txt.."\nTurns Until Growth: "..math.ceil((city.needed_culture-city.stored_culture)/city.yields.cult)
	end

	self.ORGANIZER.box1.population_text._inst:SetText("Population: "..tostring(city.population))


	self:RecalcBuildings()

	self:RemakeCitizenCoins()
	self:RecalcCitizenCoins()

	--TODO: Negatives

	self:RecalcYields()

	--self.color1 = city.owner.color1
	--self.color2 = city.owner.color2

	self.ORGANIZER.box3.buildqueue._inst:LoadCity(city)

	--Overlays

	self.DATA.expansion_target = self.DATA.city:GetExpansionTarget()
end

function CityOverviewScreen:RecalcYields()
	local city = self.DATA.city
	self.ORGANIZER.box1.yields.y_food_text._inst:SetText("Food: +"..(city.yields.food or 0).."%food%")
	self.ORGANIZER.box1.yields.y_production_text._inst:SetText("Production: +"..(city.yields.prod or 0).."%prod%")
	self.ORGANIZER.box1.yields.y_gold_text._inst:SetText("Gold: +"..(city.yields.gold or 0).."%gold%")
	self.ORGANIZER.box1.yields.y_science_text._inst:SetText("Science: +"..(city.yields.sci or 0).."%sci%")
	self.ORGANIZER.box1.yields.y_culture_text._inst:SetText("Culture: +"..(city.yields.cult or 0).."%cult%")
end

--
-- Citizen Management
--

local CitizenCoin = require("game/widgets/citymanagement/citizencoin")

function CityOverviewScreen:RemakeCitizenCoins()
	--Remove old coins
	for i,v in ipairs(self.DATA.ctzmng_coins) do
		v:Remove()
	end
	self.DATA.ctzmng_coins = {}

	for i,v in ipairs(self.DATA.city:GetWorkableTerritory()) do
		local wx, wy = self.DATA.city.map:GetHexCenter(v.x, v.y)
		local coin = self:AddChild(CitizenCoin(wx, wy, v))
		coin.master = self

		table.insert(self.DATA.ctzmng_coins, coin)
	end
end

function CityOverviewScreen:RecalcCitizenCoins()
	self.DATA.city:RecalcCitizenStatuses()
	for i,v in ipairs(self.DATA.ctzmng_coins) do
		v:SetStatus(self.DATA.city.citizen_statuses[v.cell])
	end
end

function CityOverviewScreen:RecalcCitizenCoinPositions()
	local t = (TheCamera.sx-MIN_ZOOM)/(MAX_ZOOM-MIN_ZOOM)

	for i,v in ipairs(self.DATA.ctzmng_coins) do

		local wx, wy = self.DATA.city.map:GetHexCenter(v.cell.x, v.cell.y)
		local scale = TUNING.UI.CITY_MANAGEMENT.CITIZEN_COIN_SCALE

		v.Transform:SetPosition(wx, wy + (t*TUNING.UI.CITY_MANAGEMENT.CITIZEN_COIN_OFFSET_Y))
		v.Transform:SetScale(scale*TheCamera.sx, scale*TheCamera.sy)
	end
end

function CityOverviewScreen:OnCitizenCoinClicked(cell)
	if cell.x == self.DATA.city.cx and cell.y == self.DATA.city.cy then
		self.DATA.city:ClearLocks()
	else
		self.DATA.city:TryToggleLockOnJob({ type="cell", data=cell })
	end

	self:RecalcCitizenCoins()
	self:RecalcYields()
end

--
-- Box 4
--

function CityOverviewScreen:RecalcBuildings()
	for k,v in pairs(self.DATA.building_icons) do
		v:Remove()
	end

	local x = 40
	local y = buildings_list_y
	self.DATA.building_icons = {}
	for k,v in pairs(self.DATA.city.buildings) do
		if v then
			p_print(k.name)
			self.DATA.building_icons[k] = self.ORGANIZER.box4._inst:AddChild(BuildingPortrait(x, y, k))
			self.DATA.building_icons[k].is_ui = true
			y = y + building_portrait_radius + building_portrait_seperation
		end
	end
end

tacc = 0
function CityOverviewScreen:Draw()

	--geo.drawBorderedCircle(WINDOW_WIDTH-pop_bg_w/2, portrait_offset_y, portrait_radius, portrait_thick, self.color1, self.color2)

	--Production Queue
	--geo.drawBorderedRectangle(0, WINDOW_HEIGHT-production_bg_h, production_bg_w, production_bg_h, thick, self.color1, self.color2)

	--Exapansion Target

	local expansion_target = self.DATA.expansion_target
	if expansion_target then
		local wx, wy = self.DATA.city.map:GetHexCenter(expansion_target.x, expansion_target.y)
		local verts = HexVerts(wx, wy, TheCamera.sx*1, TheCamera.sy*1)
		love.graphics.setColor(CUSTOM_COLORS.EXPANSION_INDICATOR)
		love.graphics.setLineWidth(4)
		love.graphics.polygon("line", verts)
		love.graphics.setLineWidth(1)
	end

	--Citizen Management

	self:RecalcCitizenCoinPositions()

	--Normal Children Draw

	Screen.Draw(self)

	print("OVERVIEW DEBUG")
	print(self.DATA.city.stored_food)
	print(self.DATA.city.needed_food)
--
	--Citizen Portrait Background
	geo.drawMeteredGeometry(yields_bg_w/2+portrait_offset_x, portrait_offset_y, portrait_radius*2, portrait_radius*2, self.DATA.city:GetGrowthPercent(), function(x, y, t)
		love.graphics.setColor(COLORS.DARK_GREEN)
		love.graphics.circle("fill",x,y,portrait_radius)
	end)

	--Culture Growth
	local x, y = self.ORGANIZER.box1.culturegrowth_border._inst.Transform:GetAbsolutePosition()
	geo.drawMeteredGeometry(x, y, portrait_radius*2, portrait_radius*2, self.DATA.city:GetCultureGrowthPercent(), function(x, y, t)
		love.graphics.setColor(CUSTOM_COLORS.CULTURE)
		local s = culturegrowth_center_scale
		local verts = HexVerts(x, y, TheCamera.sx*s, TheCamera.sy*s)
		love.graphics.polygon("fill", verts)
	end)

	self.ORGANIZER.box1.population._inst:DoDraw()
end

function CityOverviewScreen:Update(dt)
	tacc = tacc + dt
	if tacc > 1 then tacc = tacc - 1 end

	Screen.Update(self, dt)
end

return CityOverviewScreen