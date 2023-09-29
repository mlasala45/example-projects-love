local function ChooseRandomName(faction)
	return faction.cities[math.random(1, #faction.cities)]
end

local icon_scale = 0.3
local bg_scale = 4.0
local nameplate_scale_min = 1.5
local nameplate_scale_max = 3.0
local nameplate_offset = 80

local function nameplate_fn(t)
	return t*nameplate_offset
end

local function nameplate_scale_fn(t)
	local s = 1/TheCamera.sx
	if s > 1 then
		return nameplate_scale_min+((s-1)/(MAX_ZOOM-1)*(nameplate_scale_max-nameplate_scale_min))
	else
		return nameplate_scale_min
	end
end

local function AddHexToTerritory(tx, tz, map, t)
	local cx, cy = TrifoldToCartesian(tx, tz)
	table.insert(t, map:GetCell(cx, cy))
end

local function GetInitialTerritory(cx, cy, map)
	local ret = {}
	local tx, ty, tz = CartesianToTrifold(cx, cy)
	AddHexToTerritory(tx, tz, map, ret)
	AddHexToTerritory(tx-1, tz, map, ret)
	AddHexToTerritory(tx, tz-1, map, ret)
	AddHexToTerritory(tx+1, tz, map, ret)
	AddHexToTerritory(tx, tz+1, map, ret)
	AddHexToTerritory(tx-1, tz+1, map, ret)
	AddHexToTerritory(tx+1, tz-1, map, ret)
	return ret
end

local City = Class(Prefab, function(self, cx, cy, map, owner)
	self.base._ctor(self, 0, 0)

	self.cx = cx
	self.cy = cy

	self.map = map

	self.owner = owner
	self.faction = TheGameManager:GetFaction(self.owner)

	self.name = ChooseRandomName(self.faction)

	--TODO: Implement conditional faction-wide territory registration
	self.territory = GetInitialTerritory(cx, cy, map)

	self.color1 = self.faction.color1 or COLORS.YELLOW
	self.color2 = self.faction.color2 or COLORS.PURPLE

	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)

	self.bg = Image(wx, wy, "hex", "tex")
	--self.bg2 = Image(wx, wy, "uniticon_military_unshaded", "tex")
	self.icon = Image(wx, wy, "icon_city", "tex")
	self.icon.r = 255/3
	self.icon.g = 255/3
	self.icon.b = 255/3

	self.nameplate = Text(wx, wy - nameplate_offset, self.name, COLORS.BLACK, true, FONTS.DEFAULT_LARGE, DEFAULT_TEXT_WIDTH)

	self.yields = {}

	self:RecalcTerritory()
	--self.max_hp = type.hp
	--self.max_mp = type.mp

	--self.mp = self.max_mp
	--self.hp = self.max_hp

	self.view = TUNING.DEFAULT_CITY_VIEW_RANGE --Add ability for variable view range?

	self.stored_production = 0
	self.production_target = nil
	self.production_queue = {}
	self.productions = {}

	self.buildings = {}

	self:OnCityBuilt()
end)

function City:Update(dt)
	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)
	local t = (TheCamera.sx-MIN_ZOOM)/(MAX_ZOOM-MIN_ZOOM)
	self.bg.Transform:SetPosition(wx,wy)
	self.icon.Transform:SetPosition(wx,wy)
	self.nameplate.Transform:SetPosition(wx,wy-nameplate_fn(t))
	self.bg.Transform:SetScale(TheCamera.sx*bg_scale, TheCamera.sy*bg_scale)

	self.icon.Transform:SetScale(TheCamera.sx*icon_scale, TheCamera.sy*icon_scale)

	self.nameplate.Transform:SetScale(TheCamera.sx*nameplate_scale_fn(t), TheCamera.sy*nameplate_scale_fn(t))
end

function City:Draw()
	local vis = self.map:GetCell(self.cx, self.cy).visibility[TheGameManager.player_num]
	if not vis or vis == 0 then return end

	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)

	love.graphics.setColor(self.color2)
	love.graphics.polygon("fill", HexVerts(wx, wy, TheCamera.sx, TheCamera.sy))

	self.icon:Draw()

	love.graphics.setColor(self.color1)
	love.graphics.setLineWidth(4)
	love.graphics.polygon("line", HexVerts(wx, wy, TheCamera.sx*0.92, TheCamera.sy*0.92))

	renderutil.drawbordersegments(self.map, self.borders, COLORS.BLACK, 6)
	renderutil.drawbordersegments(self.map, self.borders, self.color2, 4)

	self.nameplate:Draw()
end

--[[local corners_i = HexVerts(0, 0, 1, 1)
local corners = {}
for i=1,6 do
	corners[i] = { x=corners_i[((i-1)*2)+1], y=corners_i[((i-1)*2)+2] }
	p_print(corners[i].x..", "..corners[i].y)
end]]

--Called when the city is initially constructed, after init
function City:OnCityBuilt()
	--Currently Starting Buildings are just hardcoded
	self.buildings[Buildings.Palace] = true
end


function City:RecalcYields()
	self.yields = {}
	for i,v in ipairs(self.territory) do
		table.add(self.yields, v.yields)
	end
end

function City:RecalcTerritory()
	self.borders = renderutil.createbordersegmenttable(self.map, self.territory)

	self:RecalcYields()
end

function City:GetBuildOptions()
	local ret = {}
	local player = TheGameManager:GetPlayer(self.owner)
	for i,v in ipairs(player.unlocked_units) do
		table.insert(ret, v)
	end
	for i,v in ipairs(player.unlocked_buildings) do
		if not self.buildings[v] then
			table.insert(ret, v)
		end
	end
	for i,v in ipairs(player.unlocked_wonders) do
		table.insert(ret, v)
	end

	return ret
end

--Adds to back of queue
function City:StartProducing(buildable)
	table.insert(self.production_queue, buildable)
	self.production_target = self.production_queue[1]
	if Screen_CityOverview.city == self then Screen_CityOverview:LoadCity(self) end
end

function City:StopProducing(i)
	table.remove(self.production_queue, i)
	self.production_target = self.production_queue[1]
	if Screen_CityOverview.city == self then Screen_CityOverview:LoadCity(self) end
end

function City:NextTurn()
	self.map:Reveal(self.cx, self.cy, TUNING.CITY_VIEW_RANGE, self.owner)

	--Production
	--No infinite stockpiling of production
	local prod = self.yields.prod or 0
	if self.production_target then
		self.stored_production = self.stored_production + prod
	else
		self.stored_production = 0
	end
	if self.production_target then
		self.productions[self.production_target] = self.productions[self.production_target] or 0
		if self.productions[self.production_target] + self.stored_production >= self.production_target.cost then
			self.stored_production = self.stored_production - (self.production_target.cost - self.productions[self.production_target])
			self:Produce(self.production_target) 
		end
	end

	p_print("NextTurn")
	p_print(self.stored_production.."  "..prod)
	for k,v in pairs(self.productions) do
		p_print(tostring(k.name).."  "..tostring(v))
	end
end

function City:Produce(target)
	self.productions[target] = nil
	table.remove(self.production_queue, 1)
	self.production_target = self.production_queue[1]
	if target.build_type == "unit" then
		TheGameManager:SpawnUnit(self.cx, self.cy, target, self.owner)
	elseif target.type == "building" then
		self.buildings[target.building] = true
	end
	if Screen_CityOverview.city == self then Screen_CityOverview:LoadCity(self) end

	local notif_data = {
		portrait = target.portrait,
		msg = string.format(STRINGS.UI.NOTIFICATIONS.PRODUCTION_DONE, target.name, self.name),
		clickfn = function() TheCamera:Center(self.cx, self.cy) end,
	}
	TheGameManager:PushNotification(self.owner, notif_data)
end

return City