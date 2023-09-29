local Unit = require("game/prefabs/unit")
local City = require("game/prefabs/city")

local GameManager = Class(Prefab, function(self, map)
	self.base._ctor(self, 0, 0)

	self.map = map

	self.players = {}

	self.units = {}

	self.cities = {}

	self.turn_num = 0
	self.player_num = 0
end)

--
-- Save Data
--

local function add_registry(savedata, name, registry)
	savedata[name] = {}
	for k,v in pairs(registry) do
		savedata[name][v.uid] = k
	end
end

function GameManager:GetSaveData()
	local savedata = {}

	savedata.registry = {}
	add_registry(savedata.registry, "biomes", Biomes)
	add_registry(savedata.registry, "factions", Factions)
	add_registry(savedata.registry, "techs", Techs)
	add_registry(savedata.registry, "units", Units)

	savedata.players = {}
	for i=1,#self.players do
		savedata.players[i] = self:GetPlayerSaveData(self.players[i])
	end

	savedata.units = {}
	for i=1,#self.units do
		savedata.units[i] = self.units[i]:GetSaveData()
	end

	savedata.cities = {}
	for i=1,#self.cities do
		savedata.cities[i] = self.cities[i]:GetSaveData()
	end

	savedata.turn_num = self.turn_num
	savedata.player_num = self.player_num

	savedata.map = self.map:GetSaveData()

	savedata.cam_x = TheCamera.x
	savedata.cam_y = TheCamera.y
	savedata.cam_sx = TheCamera.sx
	savedata.cam_sy = TheCamera.sy

	return savedata
end

function GameManager:GetPlayerSaveData(playerdata)
	local savedata = {}

	savedata.faction = playerdata.faction.uid
	savedata.techs = {}
	for i=1,#playerdata.techs do
		savedata.techs[i] = playerdata.techs[i].uid
	end

	--Global Stats

	return savedata
end

function GameManager:CleanUp()
	for i,v in ipairs(self.units) do
		v:Remove()
	end

	for i,v in ipairs(self.cities) do
		v:Destroy()
		v:Remove()
	end
end

function GameManager:LoadSaveData(savedata)
	self:CleanUp()

	self.players = {}
	for i=1,#savedata.players do
		self:LoadPlayerSaveData(savedata.players[i], savedata.registry)
	end

	self.turn_num = savedata.turn_num
	self.player_num = savedata.player_num - 1

	self.map:LoadSaveData(savedata.map, savedata.registry)

	self.units = {}
	for i=1,#savedata.units do
		self:LoadUnitSaveData(savedata.units[i], savedata.registry)
	end

	self.cities = {}
	for i=1,#savedata.cities do
		self:LoadCitySaveData(savedata.cities[i], savedata.registry)
	end

	TheCamera.sx = savedata.cam_sx
	TheCamera.sy = savedata.cam_sy

	TheCamera.x = savedata.cam_x
	TheCamera.y = savedata.cam_y

	self:NextTurn(true) --No Tick!
end

function GameManager:LoadPlayerSaveData(savedata, registry)
	local faction = Factions[registry.factions[savedata.faction]]
	local techs = {}
	for i=1,#savedata.techs do
		techs[i] = Techs[registry.techs[savedata.techs[i]]]
	end

	return self:AddPlayer(faction, techs)
end

function GameManager:LoadUnitSaveData(savedata, registry)
	local unit_type = Units[registry.units[savedata.type]]

	local unit = self:SpawnUnit(savedata.cx, savedata.cy, unit_type, savedata.owner)

	unit:LoadSaveData(savedata)
end

function GameManager:LoadCitySaveData(savedata, registry)
	local city = self:CreateCity(savedata.cx, savedata.cy, savedata.owner)

	city:LoadSaveData(savedata)
end

--
-- Other Stuff
--

function GameManager:NextTurn(notick)
	--Update Internal Vars
	self.player_num = self.player_num + 1
	if self.player_num > #self.players then
		self.player_num = 1
		self.turn_num = self.turn_num + 1
	end

	local current_player = self.players[self.player_num]
	self.current_player = current_player

	--Update Map
	self.map:NextTurn(notick)

	--Update Cities
	for i,v in ipairs(current_player.cities) do
		v:NextTurn(notick)
	end

	--Update Units
	for i,v in ipairs(current_player.units) do
		v:NextTurn(notick)
	end

	--Update Player Vars
	self:RecalcUnlocks(current_player)
	self:RecalcGlobalStats(current_player)
	if not notick then self:TickGlobalStats(current_player) end

	--Update UI
	UI_TurnCounter:SetTurn(self.turn_num, self.players[self.player_num])
	Screen_TechTree:LoadStatuses(current_player)
	UI_Notifications:RecalcNotifications(current_player.notifications)
	UI_GlobalStatsBar:RecalcStats()

	--Deselect units
	UI_InfoBox_Unit:Hide()

	if not self:CenterOnNextNecessaryAction() then
		--Center Camera on a unit or city
		local x, y
		if #current_player.units > 0 then
			x = current_player.units[1].cx
			y = current_player.units[1].cy
		elseif #current_player.cities > 0 then
			x = current_player.cities[1].cx
			y = current_player.cities[1].cy
		else
			return
		end
		TheCamera:Center(x, y, 0)
	end

	UI_TurnCounter:RecalcMessage()
end

function GameManager:CenterOnNextNecessaryAction(overtime)
	local action = self:RecalcNextNecessaryAction()
	if action then
		if action.type == "unit" then
			TheCamera:Center(action.unit.cx, action.unit.cy, overtime or 0)
			action.unit.map.selected = action.unit.map:GetCell(action.unit.cx, action.unit.cy)
			UI_InfoBox_Unit:Show()
			UI_InfoBox_Unit:LoadUnit(action.unit)
		elseif action.type == "city_setproduction" then
			TheCamera:Center(action.city.cx, action.city.cy, overtime or 0)
			action.city.map.selected = action.city.map:GetCell(action.city.cx, action.city.cy)
			Screen_CityOverview:Show()
			Screen_CityOverview:LoadCity(action.city)
			LockClickHandlers = true
		end
	end

	return action ~= nil
end

function GameManager:RecalcNextNecessaryAction()
	self.next_action = nil
	for i,v in ipairs(self.current_player.units) do
		if not v:IsDoneWithTurn() then
			self.next_action = {
				type="unit",
				unit=v
			}
			break
		end
	end
	if not self.next_action then
		for i,v in ipairs(self.current_player.cities) do
			if not v.production_target then
				self.next_action = {
					type="city_setproduction",
					city=v
				}
				break
			end
		end
	end

	UI_TurnCounter:RecalcMessage()
	return self.next_action
end

function GameManager:AddPlayer(faction, techs)
	local player = {
		faction=faction,
		units={},
		cities={},
		unlocked_units={},
		unlocked_buildings={},
		unlocked_wonders={},
		notifications={},
	}

	if techs then
		player.techs = techs
	else
		player.techs = table.copy(SimVars.StartingTechs)

		if faction.starting_techs then
			for i,v in ipairs(faction.starting_techs) do
				if not table.contains(player.techs, v) then table.insert(player.techs, v) end
			end
		end
	end
	self:RecalcTechStatuses(player)

	table.insert(self.players, player)

	self:RecalcUnlocks(player)
	self:RecalcGlobalStats(player)

	return self.players[#self.players]
end

--Assumes 'tech' is error-checked
--May introduce a stackoverflow if there are too many techs
function GameManager:UnlockTech(tech, playernum, wastenot)
	local player = self.players[playernum]
	table.insert(player.techs, tech)

	if tech.prereq then
		for i,v in ipairs(tech.prereq) do
			if not table.contains(player.techs, v) then
				self:UnlockTech(v, playernum, true)
			end
		end
	end

	if not wastenot then
		self:RecalcTechStatuses(player)
	end
end

function GameManager:RecalcTechStatuses(player)
	player.tech_statuses = {}
	for _,v in pairs(Techs) do player.tech_statuses[v] = 0 end
	for _,v in ipairs(player.techs) do player.tech_statuses[v] = 3 end
	for k,v in pairs(player.tech_statuses) do
		if v == 0 then
			local fail = false
			if k.prereq then
				for _,vv in ipairs(k.prereq) do
					if player.tech_statuses[vv] < 3 then
						fail = true
						break
					end
				end
			end
			if not fail then player.tech_statuses[k] = 1 end
		end
	end

	if player == self.current_player then
		Screen_TechTree:LoadStatuses(self.current_player)
	end
end

--Does not account for duplicate unlocks
function GameManager:RecalcUnlocks(player)
	player.unlocked_units = table.copy(SimVars.StartingUnits)
	player.unlocked_buildings = table.copy(SimVars.StartingBuildings)
	player.unlocked_wonders = {}
	player.unlocked_improvements = {}
	for i,tech in ipairs(player.techs) do
		if tech.units then
			for ii,vv in ipairs(tech.units) do
				table.insert(player.unlocked_units, vv)
			end
		end
		if tech.buildings then
			for ii,vv in ipairs(tech.buildings) do
				table.insert(player.unlocked_buildings, vv)
			end
		end
		if tech.wonders then
			for ii,vv in ipairs(tech.wonders) do
				table.insert(player.unlocked_wonders, vv)
			end
		end
		if tech.improvements then
			for ii,vv in ipairs(tech.improvements) do
				table.insert(player.unlocked_improvements, vv)
			end
		end
	end
end

function GameManager:RecalcGlobalStats(player) 
	player.global_science_gain = 0
	player.global_gold_gain = 0
	player.global_culture_gain = 0

	for i,v in ipairs(player.cities) do
		player.global_science_gain = player.global_science_gain + (v.yields.sci or 0)
		player.global_culture_gain = player.global_culture_gain + (v.yields.cult or 0)
		player.global_gold_gain = player.global_gold_gain + (v.yields.gold or 0)
	end

	player.global_gold = player.global_gold or 0
	player.global_science = player.global_science or 0
	player.global_culture = player.global_culture or 0
end

function GameManager:TickGlobalStats(player)
	player.global_gold = player.global_gold + player.global_gold_gain
	player.global_science = player.global_science + player.global_science_gain
	player.global_culture = player.global_culture + player.global_culture_gain
end

--TODO: Functions to destroy units and cities

function GameManager:SpawnUnit(x, y, unit, player)
	assert(table.contains(Units, unit), "Attempt to spawn unregistered unit: "..tostring(unit))
	local inst = Unit(x, y, TheGrid, unit, player)
	table.insert(self.units, inst)
	table.insert(self.players[player].units, inst)
	TheGrid.cells[x][y].unit = inst
	return inst
end

function GameManager:CreateCity(x, y, player)
	local inst = City(x, y, TheGrid, player)
	table.insert(self.cities, inst)
	table.insert(self.players[player].cities, inst)

	local cell = TheGrid:GetCell(x, y)
	cell.feature = { city=inst }
	cell.has_road = true

	TheGrid:RecalcVision(player)
	return inst
end

function GameManager:RemoveUnit(unit)
	--Remove from map
	unit.map:GetCell(unit.cx, unit.cy).unit = nil

	--Remove from player roster and units roster
	table.remove_from_list(self.players[unit.owner].units, unit)
	table.remove_from_list(self.units, unit)

	unit.map:RecalcVision(unit.owner)

	--Close UI if necessary
	if UI_InfoBox_Unit.unit == unit then UI_InfoBox_Unit:Hide() end

	--Destroy prefab
	unit:Remove()
end

function GameManager:RemoveCity(city)
	--Remove from map
	unit.map:GetCell(unit.cx, unit.cy).city = nil

	--TODO
end

function GameManager:GetFaction(num)
	assert(self.players[num], "Attempted to call GetFaction on a player that doesn't exist! ("..num..")")
	return self.players[num].faction
end

function GameManager:GetPlayer(num)
	assert(self.players[num], "Attempted to call GetPlayer on a player that doesn't exist! ("..num..")")
	return self.players[num]
end

function GameManager:GetCurrentPlayer()
	return self.players[self.current_player]
end

function GameManager:Update(dt)
	local mx,my = love.mouse:getPosition()
	print(mx..", "..my)
end

function GameManager:PushNotification(player, data)
	table.insert(self.players[player].notifications, data)
	if self.player_num == player then
		UI_Notifications:RecalcNotifications(self.players[player].notifications)
	end
end

function GameManager:DismissNotification(player, num)
	if player == nil then player = self.player_num end
	table.remove(self.players[player].notifications, num)
	if self.player_num == player then
		UI_Notifications:RecalcNotifications(self.players[player].notifications)
	end
end

return GameManager