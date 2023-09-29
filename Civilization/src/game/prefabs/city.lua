local function ChooseRandomName(faction)
	return table.random(faction.cities)
end

local icon_scale = 1--0.3
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

local function add_hex_to_territory(tx, tz, map, t)
	local cx, cy = TrifoldToCartesian(tx, tz)
	table.insert(t, map:GetCell(cx, cy))
end

local function GetInitialTerritory(cx, cy, map)
	local ret = {}
	local tx, ty, tz = CartesianToTrifold(cx, cy)
	add_hex_to_territory(tx, tz, map, ret)
	add_hex_to_territory(tx-1, tz, map, ret)
	add_hex_to_territory(tx, tz-1, map, ret)
	add_hex_to_territory(tx+1, tz, map, ret)
	add_hex_to_territory(tx, tz+1, map, ret)
	add_hex_to_territory(tx-1, tz+1, map, ret)
	add_hex_to_territory(tx+1, tz-1, map, ret)
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
	for i,v in ipairs(self.territory) do
		v.owning_city = self
		v.owning_faction = self.owner
	end

	self.color1 = self.faction.color1 or COLORS.YELLOW
	self.color2 = self.faction.color2 or COLORS.PURPLE

	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)

	self.bg = Image(wx, wy, "hex", "tex")
	--self.bg2 = Image(wx, wy, "uniticon_military_unshaded", "tex")
	self.icon = Image(wx, wy, "Cities_Classical_Visible", "tex")
	self.icon.r = 255/3
	self.icon.g = 255/3
	self.icon.b = 255/3

	self.nameplate = Text(wx, wy - nameplate_offset, self.name, COLORS.BLACK, true, FONTS.DEFAULT_HUGE, DEFAULT_TEXT_WIDTH + 200)
	TheNameplateRenderer:RegisterNameplate(self.nameplate)

	self.population = 1
	self.stored_food = 0
	self.needed_food = self:GetNextGrowthThreshold()

	self.stored_culture = 0
	self.needed_culture = self:GetNextCultureGrowthThreshold()

	self.yields = {}

	self.buildings = {}

	--Citizen Management
	self.locked_in_cells = {}
	self.locked_off_cells = {}
	self.locked_job_count = 0
	self.last_locked_cell = nil
	self.citizen_statuses = nil

	self:OnCityBuilt()

	self:RecalcBorders()

	self:RecalcCitizenStatuses() -- TODO: Make a Recalc?
	self:RecalcYields()
	--self.max_hp = type.hp
	--self.max_mp = type.mp

	--self.mp = self.max_mp
	--self.hp = self.max_hp

	self.view = TUNING.DEFAULT_CITY_VIEW_RANGE --Add ability for variable view range?

	self.stored_production = 0
	self.production_target = nil
	self.production_queue = {}
	self.productions = {}

	self.layer = LAYERS.CITIES
end)

--
-- Save Data
--

function City:GetSaveData()
	local savedata = {}

	savedata.cx = self.cx
	savedata.cy = self.cy

	savedata.owner = self.owner

	savedata.name = self.name

	savedata.territory = {}
	for i=1,#self.territory do
		savedata.territory[i] = {
			cx = self.territory[i].x,
			cy = self.territory[i].y,
		}
	end

	savedata.population = self.population

	savedata.stored_food = self.stored_food
	savedata.stored_culture = self.stored_culture

	saveutil.save_registered_list(savedata, "buildings", self.buildings)

	savedata.locked_in_cells = {}

	savedata.stored_production = self.stored_production

	savedata.production_target = self.production_target and self.production_target.uid

	--TODO
	savedata.production_queue = {}
	savedata.productions = {}

	return savedata
end

function City:LoadSaveData(savedata)
	self.name = savedata.name
	self.nameplate:SetText(self.name)

	self.territory = {}
	for i=1,#savedata.territory do
		local cell = self.map:GetCell(savedata.territory[i].cx, savedata.territory[i].cy)
		self.territory[i] = cell

		cell.owning_city = self
		cell.owning_faction = self.owner --TODO: Not a faction?
	end


end

--
-- Other Stuff
--

function City:Update(dt)
	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)
	local t = (TheCamera.sx-MIN_ZOOM)/(MAX_ZOOM-MIN_ZOOM)
	self.bg.Transform:SetPosition(wx,wy)
	self.icon.Transform:SetPosition(wx,wy)
	self.nameplate.Transform:SetPosition(wx,wy-nameplate_fn(t))
	self.bg.Transform:SetScale(TheCamera.sx*bg_scale, TheCamera.sy*bg_scale)

	self.icon.Transform:SetScale(TheCamera.sx*icon_scale, TheCamera.sy*icon_scale)

	self.nameplate.Transform:SetScale(TheCamera.sx*nameplate_scale_fn(t)/2, TheCamera.sy*nameplate_scale_fn(t)/2)
end

--Destroy data, not literally razing
function City:Destroy()
	TheNameplateRenderer:RemoveNameplate(self.nameplate)
end

function City:Draw()
	local vis = self.map:GetCell(self.cx, self.cy).visibility[TheGameManager.player_num]
	if not vis or vis == 0 then return end

	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)

	--[[love.graphics.setColor(self.color2)
	love.graphics.polygon("fill", HexVerts(wx, wy, TheCamera.sx, TheCamera.sy))]]

	self.icon:Draw()

	--[[love.graphics.setColor(self.color1)
	love.graphics.setLineWidth(4)
	love.graphics.polygon("line", HexVerts(wx, wy, TheCamera.sx*0.92, TheCamera.sy*0.92))]]

	for i,v in ipairs(self.borders) do
		wx, wy = self.map:GetHexCenter(v.x1, v.y1)
		local verts = HexVerts(wx, wy, TheCamera.sx, TheCamera.sy)
		local nxt = v.i+1
		if nxt > 6 then nxt = 1 end

		love.graphics.setLineWidth(6)
		love.graphics.setColor(COLORS.BLACK)
		love.graphics.line(verts[((v.i-1)*2)+1], verts[((v.i-1)*2)+2], verts[((nxt-1)*2)+1], verts[((nxt-1)*2)+2])
	end

	for i,v in ipairs(self.borders) do
		wx, wy = self.map:GetHexCenter(v.x1, v.y1)
		local verts = HexVerts(wx, wy, TheCamera.sx, TheCamera.sy)
		local nxt = v.i+1
		if nxt > 6 then nxt = 1 end

		love.graphics.setLineWidth(4)
		love.graphics.setColor(self.color2)
		love.graphics.line(verts[((v.i-1)*2)+1], verts[((v.i-1)*2)+2], verts[((nxt-1)*2)+1], verts[((nxt-1)*2)+2])
	end
	love.graphics.setLineWidth(1)
	love.graphics.setColor(COLORS.WHITE)

	self.nameplate:Draw()
end

local offsets = {
	{ x=1, z=-1 },
	{ x=1, z=0 },
	{ x=0, z=1 },
	{ x=-1, z=1 },
	{ x=-1, z=0 },
	{ x=0, z=-1 },
}

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

	self:ChooseNewExpansionTarget()
end


function City:RecalcYields()
	self.yields = {}
	for i,v in ipairs(self.worked_tiles) do
		table.add(self.yields, v.yields)
	end
	table.add(self.yields, self:GetInternalYields())
end

--Recalculates visual geometry for border rendering
function City:RecalcBorders()
	self.borders = {}
	for i,v in ipairs(self.territory) do
		local tx, ty, tz = CartesianToTrifold(v.x, v.y)
		for i=1,6 do
			local cx, cy = TrifoldToCartesian(tx+offsets[i].x, tz+offsets[i].z)
			if not table.contains(self.territory, self.map:GetCell(cx, cy)) then
				--local x, y = CartesianToWorld(cx, cy)
				--p_print(tostring(x)..", "..tostring(y))
				--assert(false, tostring(cx).." "..tostring(cy).."\n"..tostring(x).." y: "..tostring(y))
				table.insert(self.borders, { x1=v.x, y1=v.y, i=i })
			end
		end
	end
end

--Just in case
function City:RecalcUI()
	if Screen_CityOverview.visible and Screen_CityOverview.DATA.city == self then
		Screen_CityOverview:LoadCity(self)
	end
end

function City:RecalcExpansionDistances()
	self.expansion_pools = { }
	for i=1,TUNING.CITY_EXPANSION_RANGE do self.expansion_pools[i] = {} end

	self.map:GetCell(self.cx, self.cy).distance_to_civilization = 0
	for r=0,TUNING.CITY_EXPANSION_RANGE do
		for _,v in ipairs(hex.ring(self.cx, self.cy, r)) do
			v = self.map:GetCell(v.x, v.y)
			if v then
				if v.owning_city then
					v.distance_to_civilization = 0
				else
					local best
					for _,vv in ipairs(hex.neighbors(v)) do
						if vv then
							if vv.owning_city then
								best = 0
							elseif vv.distance_to_civilization then
								best = math.min(best or TUNING.CITY_EXPANSION_RANGE, vv.distance_to_civilization)
							end
						end
					end
					if best then
						v.distance_to_civilization = best + 1
						table.insert(self.expansion_pools[v.distance_to_civilization], v)
					end
				end
			end
		end
	end
end

function City:ChooseNewExpansionTarget()
	self:RecalcExpansionDistances()

	for i=1,TUNING.CITY_EXPANSION_RANGE do
		if #(self.expansion_pools[i]) > 0 then
			self.expansion_target = table.random(self.expansion_pools[i])
			return
		end
	end
end

--
-- Getters
--

function City:GetWorkableTerritory()
	local ret = {}
	local center = { x=self.cx, y=self.cy }
	for i,v in ipairs(self.territory) do
		if hex.distance(center, { x=v.x, y=v.y }) <= TUNING.CITY_WORK_RANGE then
			table.insert(ret, v)
		end
	end
	return ret
end

function City:TryToggleLockOnJob(data)
	p_print("Toggle")
	p_print(self.locked_job_count)
	if data.type == "cell" then
		if self.locked_in_cells[data.data] then
			self.locked_in_cells[data.data] = false
			self.locked_off_cells[data.data] = true
			self.locked_job_count = self.locked_job_count - 1
		else
			self.locked_in_cells[data.data] = true
			self.locked_off_cells[data.data] = nil
			if self.locked_job_count == self.population then
				self.locked_in_cells[self.last_locked_cell] = false
			else
				self.locked_job_count = self.locked_job_count + 1
			end

			self.last_locked_cell = data.data
		end
	end
	p_print(self.locked_job_count)
end

function City:ClearLocks()
	for k,v in pairs(self.locked_in_cells) do
		if v then
			self.locked_job_count = self.locked_job_count - 1
		end
	end
	self.locked_in_cells = {}
	self.locked_off_cells = {}
end

--TODO: This should be a recalc
function City:RecalcCitizenStatuses()
	local ret = {}
	self.worked_tiles = {}
	local pool = self:GetWorkableTerritory()
	local yields = self:GetInternalYields()
	local workers = self.population
	local i = 1
	
	--Pass 1: Locked In Jobs and City Center
	repeat
		local v = pool[i]

		if v.x == self.cx and v.y == self.cy then
			ret[v] = CitizenStatus.CityCenter
			table.insert(self.worked_tiles, v)
			table.remove(pool, i)
			i = i - 1
		elseif self.locked_in_cells[v] then
			ret[v] = CitizenStatus.Locked
			table.insert(self.worked_tiles, v)
			workers = workers - 1
			table.remove(pool, i)
			i = i - 1
		end

		i = i + 1
	until i > #pool

	if workers > 0 then
		local priorities = table.copy(Yields)
		if self.priority_yield then table.move(priorities, self.priority_yield, 1) end

		--Pass 2+: Priorities
		table.sort(pool, function(a, b)
			for _,py in ipairs(priorities) do
				if (a.yields[py] or 0) > (b.yields[py] or 0) then
					return true
				elseif (a.yields[py] or 0) < (b.yields[py] or 0) then
					return false
				end
			end
			return false
		end)
		i = 1
		repeat
			local v = pool[i]

			if  self.locked_off_cells[v] then
				ret[v] = CitizenStatus.Disabled
			else
				ret[v] = CitizenStatus.Enabled
				table.insert(self.worked_tiles, v)
				workers = workers - 1
			end

			table.remove(pool, i)

			if workers == 0 then break end
		until i > #pool
	end

	--Final Disabled Pass
	for i,v in ipairs(pool) do
		ret[v] = CitizenStatus.Disabled
	end

	--Recalc Yields TODO: fix code flow
	self:RecalcYields()

	self.citizen_statuses = ret
end

function City:GetExpansionTarget()
	return self.expansion_target
end

function City:GetInternalYields()
	local ret = {}
	for k,v in pairs(self.buildings) do
		if v then
			table.add(ret, k.yields)
		end
	end

	table.add(ret, { sci=self.population*TUNING.GAMEPLAY.SCIENCE_PER_POP })

	return ret
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

function City:GetGrowthPercent()
	return self.stored_food / self.needed_food
end

function City:GetCultureGrowthPercent()
	return self.stored_culture / self.needed_culture
end


function City:GetNextGrowthThreshold()
	return 10 --TODO
end

function City:GetNextCultureGrowthThreshold()
	return 5 --TODO
end

--Adds to back of queue
function City:StartProducing(buildable)
	table.insert(self.production_queue, buildable)
	self.production_target = self.production_queue[1]
	if Screen_CityOverview.DATA.city == self then Screen_CityOverview:LoadCity(self) end
end

function City:StopProducing(i)
	table.remove(self.production_queue, i)
	self.production_target = self.production_queue[1]
	if Screen_CityOverview.DATA.city == self then Screen_CityOverview:LoadCity(self) end
end

function City:NextTurn(notick)
	self.map:Reveal(self.cx, self.cy, TUNING.CITY_VIEW_RANGE, self.owner) --TODO: Necessary?

	if not notick then
		--Food
		local food = self.yields.food or 0
		self:AddFood(food)

		--Production
		--No infinite stockpiling of production
		local prod = self.yields.prod or 0
		self:AddProduction(prod, true)
	end	

	--[[p_print("NextTurn")
	p_print(self.stored_production.."  "..prod)
	for k,v in pairs(self.productions) do
		p_print(tostring(k.name).."  "..tostring(v))
	end--]]
end

function City:RecalcAll()
	self:RecalcYields()
	self:RecalcBorders()

	self:RecalcExpansionDistances()

	self.needed_food = self:GetNextGrowthThreshold()

	self:RecalcCitizenStatuses()

	self:RecalcUI()
end

function City:AddFood(food)
	self.stored_food = self.stored_food + food
	if self.stored_food >= self.needed_food then
		self.population = self.population + 1
		self.stored_food = self.stored_food - self.needed_food
		self.needed_food = self:GetNextGrowthThreshold()

		local notif_data = {
			portrait = "portrait_alert",
			msg = string.format(STRINGS.UI.NOTIFICATIONS.CITY_GROWN, self.name),
			clickfn = function() TheCamera:Center(self.cx, self.cy) end
		}
		TheGameManager:PushNotification(self.owner, notif_data)
	end

	self:RecalcUI()
end

function City:AddProduction(prod, do_not_store)
	if self.production_target or (not do_not_store) then
		self.stored_production = self.stored_production + prod
	elseif do_not_store then
		self.stored_production = 0
	end
	if self.production_target then
		self.productions[self.production_target] = self.productions[self.production_target] or 0
		if self.productions[self.production_target] + self.stored_production >= self.production_target.cost then
			self.stored_production = self.stored_production - (self.production_target.cost - self.productions[self.production_target])
			self:Produce(self.production_target) 
		end
	end
end

function City:AddCulture(culture)
	self.stored_culture = self.stored_culture + culture
	if self.stored_culture >= self.needed_culture then

		table.insert(self.territory, self.expansion_target)
		self:ChooseNewExpansionTarget()

		self.stored_culture = self.stored_culture - self.needed_culture
		self.needed_culture = self:GetNextCultureGrowthThreshold()

		local notif_data = {
			portrait = "portrait_alert",
			msg = string.format(STRINGS.UI.NOTIFICATIONS.CITY_EXPANDED, self.name),
			clickfn = function() TheCamera:Center(self.cx, self.cy) end
		}
		TheGameManager:PushNotification(self.owner, notif_data)
	end

	self:RecalcUI()
end

function City:Produce(target)
	self.productions[target] = nil
	table.remove(self.production_queue, 1)
	self.production_target = self.production_queue[1]
	if target.build_type == "unit" then
		TheGameManager:SpawnUnit(self.cx, self.cy, target, self.owner)
	elseif target.build_type == "building" then
		self.buildings[target] = true
	end
	if Screen_CityOverview.DATA.city == self then Screen_CityOverview:LoadCity(self) end

	local notif_data = {
		portrait = target.portrait,
		msg = string.format(STRINGS.UI.NOTIFICATIONS.PRODUCTION_DONE, target.name, self.name),
		clickfn = function() TheCamera:Center(self.cx, self.cy) end,
	}
	TheGameManager:PushNotification(self.owner, notif_data)
end

return City