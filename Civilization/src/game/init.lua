require "game/util/coords"
require "game/util/color"
require "game/util/math"
require "game/util/table"
require "game/util/hex"
require "game/util/geo"
require "game/util/saveutil"

require "game/customcolors"
require "game/util/renderutil"

require "game/widgets/icontext"

require "game/conf/enums"
require "game/conf/terrain"
require "game/conf/buildings"
require "game/conf/improvements"
require "game/conf/factions"
require "game/conf/units"
require "game/conf/techs"
require "game/conf/targetingmodes"

require "game/unitactions"
require "game/consolecommands"

require "game/worldgen/worldgen_common"
require "game/worldgen/continents"

--TODO: Move utils to engine

local Camera = require("game/prefabs/camera")
local HexGrid = require("game/prefabs/hexgrid")
local GameManager =  require("game/prefabs/gamemanager")
local SaveGameIndex =  require("game/prefabs/savegameindex")
local Pathfinder = require("game/prefabs/overlays/pathfinder")
local TargetingUI = require("game/prefabs/overlays/targetingui")
local YieldsRenderer = require("game/prefabs/overlays/yieldsrenderer")
local RoadsRenderer = require("game/prefabs/overlays/roadsrenderer")
local NameplateRenderer = require("game/prefabs/overlays/nameplaterenderer")
local FloatingTextRenderer = require("game/prefabs/overlays/floatingtextrenderer")
local HexSelector = require("game/prefabs/overlays/hexselector")

local UnitInfoBox = require("game/widgets/unitinfobox")
local TileInfoBox = require("game/widgets/tileinfobox")

--Screens
local CityOverviewScreen = require("game/screens/cityoverviewscreen")
local TechTreeScreen = require("game/screens/techtreescreen")
local ConsoleScreen = require("game/screens/consolescreen")
local PauseGameMenuScreen = require("game/screens/pausegamemenu/pausegamemenuscreen")

local TurnCounterPanel = require("game/widgets/turncounterpanel")
local NotificationFeed = require("game/widgets/notificationfeed")
local GlobalStatsBar = require("game/widgets/globalstatsbar")
local Tooltip = require("game/widgets/tooltip")

local function PickRandomLandCell()
	local cx, cy = math.floor(TheGrid.w/2), math.floor(TheGrid.h/2)
	repeat
		cx, cy = math.random(0, TheGrid.w), math.random(0, TheGrid.h)
		if (TheGrid:GetCell(cx,cy) and TheGrid:GetCell(cx,cy).biome.marine) or not TheGrid:GetCell(cx,cy) then
			cx = -1
		end
	until cx ~= -1
	return cx, cy
end

local function PickRandomSpawnPositions()
	local cx, cy = PickRandomLandCell()

	local pos = {}
	local i = 1
	while i <= 4 do
		local tx, tz = math.random(-2,2), math.random(-2,2)
		local x, y = TrifoldToCartesian(tx, tz)
		x = cx + x
		y = cy + y
		local invalid = false
		--p_print("CHECK "..i.." "..x.." "..y)
		if (not TheGrid:GetCell(x,y)) or TheGrid:GetCell(x,y).biome.marine then
			--p_print("WATER")
			invalid = true
		else
			for i,v in ipairs(pos) do
				if v.x == x and v.y == y then
					--p_print("DUPLICATE")
					invalid = true
				end
			end
		end
		if not invalid then
			--p_print("VALID")
			i = i + 1
			table.insert(pos,{ x=x, y=y })
		end
	end

	return pos
end

local function Init()
	FONTS = {}
	FONTS.DEFAULT = love.graphics.newFont("base/assets/fonts/bliz-quadrata.ttf")
	FONTS.DEFAULT_LARGE = love.graphics.newFont("base/assets/fonts/bliz-quadrata.ttf",20)
	FONTS.DEFAULT_HUGE = love.graphics.newFont("base/assets/fonts/bliz-quadrata.ttf",40)
	FONTS.DEFAULT_BOLD = love.graphics.newFont("base/assets/fonts/bliz-quadrata_bold.ttf")
	love.graphics.setFont(FONTS.DEFAULT_LARGE)

	SHADERS = {
		TWOCOLORS = love.graphics.newShader(require("game/shaders/twocolor")),
		TILESHADER = love.graphics.newShader(require("game/shaders/tileshader")),
	}

	RegisterInlineIcon("food", "civ_icons", "yield_food", 4, 0, 0)
	RegisterInlineIcon("prod", "civ_icons", "yield_prod", 4, 0, 0)
	RegisterInlineIcon("gold", "civ_icons", "yield_gold", 4, 0, 0)
	RegisterInlineIcon("sci", "civ_icons", "yield_sci", 4, 0, 0)
	RegisterInlineIcon("cult", "civ_icons", "yield_culture", 4, 0, 1)

	TheGrid = HexGrid(MID_X, MID_Y, GRID_WIDTH, GRID_HEIGHT)

	--Game Setup
	SimVars = {
		StartingTechs = { Techs.Agriculture },
		StartingUnits = { Units.Settler, Units.Builder, Units.Warrior },
		StartingBuildings = { Buildings.Monument },
	}

	ValidateTechs()

	--Game Manager and Player Setup
	TheGameManager = GameManager(TheGrid)
	TheGameManager:AddPlayer(Factions.Rome)
	TheGameManager:AddPlayer(Factions.America)
	TheGameManager:AddPlayer(Factions.France)
	TheGameManager:AddPlayer(Factions.Egypt)
	TheGameManager.current_player = TheGameManager.players[1]

	--SaveGameIndex

	TheSaveGameIndex = SaveGameIndex()

	--UI
	Screen_HUD = ROOT:AddChild(Screen())
	Screen_HUD.name = "HUD"
	ActiveScreen = Screen_HUD
	ActiveScreenLastUpdate = Screen_HUD
	
	Screen_CityOverview = ROOT:AddChild(CityOverviewScreen())
	Screen_CityOverview:Hide()

	Screen_TechTree = ROOT:AddChild(TechTreeScreen())
	Screen_TechTree:Hide()

	Screen_PauseGameMenu = ROOT:AddChild(PauseGameMenuScreen(false))
	Screen_PauseGameMenu:Hide()

	Screen_Console = ROOT:AddChild(ConsoleScreen(false))
	Screen_Console:Hide()

	--HUD
	UI_InfoBox_Unit = UnitInfoBox(0, WINDOW_HEIGHT-100*1.2)
	UI_InfoBox_Unit:Hide()
	UI_InfoBox_Unit.Show = function(self)
		UnitInfoBox.Show(self)
		UI_InfoBox_Tile:Hide()
	end
	Screen_HUD:AddChild(UI_InfoBox_Unit)

	UI_InfoBox_Tile = TileInfoBox(0, WINDOW_HEIGHT-100*1.2)
	UI_InfoBox_Tile:Hide()
	UI_InfoBox_Tile.Show = function(self)
		TileInfoBox.Show(self)
		UI_InfoBox_Unit:Hide()
	end
	Screen_HUD:AddChild(UI_InfoBox_Tile)

	UI_TurnCounter = TurnCounterPanel(WINDOW_WIDTH-160*1.2, WINDOW_HEIGHT-160*1.2)
	Screen_HUD:AddChild(UI_TurnCounter)

	UI_Notifications = NotificationFeed(WINDOW_WIDTH-120*1.2, 50*1.2)
	Screen_HUD:AddChild(UI_Notifications)

	UI_GlobalStatsBar = GlobalStatsBar(0, 0)
	Screen_HUD:AddChild(UI_GlobalStatsBar)
	UI_GlobalStatsBar:RecalcStats()

	UI_Tooltip = Tooltip()
	ROOT:AddChild(UI_Tooltip)
	UI_Tooltip.Transform:SetScale(1.5)

	--Overlays
	ThePathfinder = Pathfinder()

	TheTargetingUI = TargetingUI()
	TheTargetingUI.is_active = false

	TheYieldsRenderer = YieldsRenderer(TheGrid)

	TheRoadsRenderer = RoadsRenderer(TheGrid)

	TheHexSelector = HexSelector(TheGrid)

	TheNameplateRenderer = NameplateRenderer()

	TheFloatingTextRenderer = FloatingTextRenderer(TheGrid)

	--Camera

	TheCamera = Camera()
	TheCamera.minX = -TheGrid.ww/2
	TheCamera.maxX = TheGrid.ww/2
	TheCamera.minY = -TheGrid.wh/2
	TheCamera.maxY = TheGrid.wh/2

	--
	--Input Handling
	--

	--Scrolling

	InputHandler:AddKeypressHandler("+",function(isrepeat)
		local n = 1
		n = n / 10
		TheCamera.sx = math.clamp(TheCamera.sx + n, MIN_ZOOM, MAX_ZOOM)
		TheCamera.sy = math.clamp(TheCamera.sy + n, MIN_ZOOM, MAX_ZOOM)
	end)

	InputHandler:AddKeypressHandler("-",function(isrepeat)
		local n = -1
		n = n / 10
		TheCamera.sx = math.clamp(TheCamera.sx + n, MIN_ZOOM, MAX_ZOOM)
		TheCamera.sy = math.clamp(TheCamera.sy + n, MIN_ZOOM, MAX_ZOOM)
	end)

	InputHandler:AddScrollHandler(function(n)	
		local focus = ROOT:GetFocused(MX, MY)		
		if focus and focus.is_ui then
			if focus.scroll_master then focus = focus.scroll_master end
			if focus.scroll_fn then
				focus.scroll_fn(focus, n)
			end
			return
		end

		n = n / 10
		TheCamera.sx = math.clamp(TheCamera.sx + n, MIN_ZOOM, MAX_ZOOM)
		TheCamera.sy = math.clamp(TheCamera.sy + n, MIN_ZOOM, MAX_ZOOM)
	end)

	--Map Tweaks

	SHOW_YIELDS = false
	SHOW_GRID = false

	InputHandler:AddKeypressHandler("y",function(isrepeat)
		SHOW_YIELDS = not SHOW_YIELDS
	end)

	InputHandler:AddKeypressHandler("g",function(isrepeat)
		SHOW_GRID = not SHOW_GRID
	end)

	--Debug

	ACC = 0
	InputHandler:AddKeypressHandler("return",function(isrepeat)
		ACC = ACC + 1
		local notif_data = {
			portrait = "portrait_alert",
			msg = "#"..ACC..": A Builder finished being built in Antium.",
		}
		TheGameManager:PushNotification(TheGameManager.player_num, notif_data)
	end)

	InputHandler:AddKeypressHandler("backspace",function(isrepeat)
		ACC = ACC + 1
		local notif_data = {
			portrait = "portrait_alert",
			msg = "#"..ACC..": A Builder finished being built in Antium.",
		}
		TheGameManager:PushNotification(TheGameManager.player_num, notif_data)
	end)

	InputHandler:AddKeypressHandler("t",function(isrepeat)
		TheTargetingUI:EndSelection()
		Screen_TechTree:Show()
	end)

	InputHandler:AddKeypressHandler("r",function(isrepeat)
		if TheGrid.hovered then
			TheGrid.hovered.has_road = not TheGrid.hovered.has_road
		end
	end)

	InputHandler:AddKeypressHandler("`",function(isrepeat)
		if Screen_Console.visible then
			Screen_Console:Hide()
			TheCamera.locked = false
			ActiveScreen = Screen_HUD --TODO
		else
			Screen_Console:Show()
			TheCamera.locked = true
		end

		return true
	end, true)

	InputHandler:AddKeypressHandler("f1",function(isrepeat)
		if love.keyboard.isDown("lshift") then
			TheGrid:RevealAll(TheGameManager.player_num)
		end
	end, true)

	InputHandler:AddKeypressHandler("f2",function(isrepeat)
		p_print("F2 Callback")
		TheGrid:RecalcVision(TheGameManager.player_num)
	end, true)


	InputHandler:AddKeypressHandler("f3",function(isrepeat)
		if love.keyboard.isDown("lctrl") then
			DEBUG = not DEBUG
		end
		if love.keyboard.isDown("lshift") then
			DRAW_BOUNDS = not DRAW_BOUNDS
		end
	end, true)
	
	InputHandler:AddKeypressHandler("f4",function(isrepeat)
		p_clear()
	end, true)

	InputHandler:AddKeypressHandler("f9",function(isrepeat)
		love.event.quit()
	end, true)

	InputHandler:AddKeypressHandler("escape",function(isrepeat)
		if ActiveScreen == Screen_HUD then
			if TheTargetingUI.is_active then
				TheTargetingUI:EndSelection()
			else
				Screen_PauseGameMenu:Show()
			end
		else
			ActiveScreen:Hide()
			ActiveScreen = Screen_HUD
			TheCamera.locked = false
		end
	end, true)

	--Clicking

	--Honestly, it seems to work best when there's just one of these
	InputHandler:AddClickHandler(function(x, y, button)
		if LockClickHandlers then return end

		local focus = ROOT:GetFocused(MX, MY)

		--Clicks on UI are handled by the focused widget
		if focus and focus.is_ui then return end

		if ActiveScreenLastUpdate.prevent_input_handling then return end

		--Left Click
		if button == 1 then
			x,y = TheGrid:WorldToLocal(x,y)
			local cx,cy = WorldToCartesian(x,y)
			local oldSelection = TheGrid.selected

			--Shift+Left Click: Show Tile Info Box
			if love.keyboard.isDown("lshift") then
				TheTargetingUI:EndSelection()

				TheGrid.selected = TheGrid:GetCell(cx, cy)

				UI_InfoBox_Tile:Show()
				local hide_info = true --Checks whether the tile is unexplored
				if TheGrid.selected and (TheGrid.selected.visibility[TheGameManager.player_num] or 0) > 0 then hide_info = false end
				UI_InfoBox_Tile:LoadTile(TheGrid.selected, hide_info)
			else
				--Normal Left Click

				--If targeting for an action:
				--Trigger the action, but do not click the map
				local skip = false
				if TheTargetingUI.is_active then
					skip = true
					
					local cell = TheGrid:GetCell(cx, cy)
					if TheTargetingUI.valid_cells[cell] then
						TheTargetingUI.unit:DoAction(TheTargetingUI.uaction, cell)
					end

					TheTargetingUI:EndSelection()
				end

				--Click the map
				if not skip then
					--Change hex selection
					TheGrid.selected = TheGrid:GetCell(cx, cy)

					local unit = TheGrid:GetUnit(cx, cy)
					local city = TheGrid:GetCity(cx, cy)
					local owner = TheGrid:GetTileOwner(cx, cy)

					--If the City Overview is open, and you click on a tile not owned by the selected city:
					--Close the City Overview
					if (not city) and Screen_CityOverview.visible then
						if TheGrid:GetTileCity(cx, cy) ~= Screen_CityOverview.DATA.city then Screen_CityOverview:Hide() end
					end
					
					--If clicking on a city, or clicking for the second time on a garrisoned city:
					--Load the City Overview
					--TODO: Reorganize?
					if (not unit) or oldSelection == TheGrid.selected then
						if city then
							Screen_CityOverview:Show()
							Screen_CityOverview:LoadCity(city)

							--Begone, inferior UIs!
							UI_InfoBox_Tile:Hide()
							UI_InfoBox_Unit:Hide()
						end
					end

					--If the tile is a unit, open its Info Box
					if unit then
						UI_InfoBox_Unit:Show()
						UI_InfoBox_Unit:LoadUnit(unit)
					else
						--Otherwise, you clicked on an empty tile:
						--Hide the Info Boxes

						UI_InfoBox_Unit:Hide()
						UI_InfoBox_Tile:Hide()
					end
				end
			end
		elseif button == 2 then
			--Right Click

			--If you are targeting for an action, cancel it
			TheTargetingUI:EndSelectionDelayed()
		end
	end)

	InputHandler:AddGeneralKeypressHandler(function(key, isrepeat)
		if not isrepeat then
			if TheGrid.selected and UI_InfoBox_Unit.visible and not ActiveScreenLastUpdate.prevent_input_handling then
				local unit = TheGrid:GetUnit(TheGrid.selected.x,TheGrid.selected.y)
				if unit then
					--Check for unit ability callbacks
					unit:OnKeypress(key, love.keyboard.isDown("lctrl"))
				end
			end
		end
	end)

	--
	--Starting Unit Placement
	--

	local pos = PickRandomSpawnPositions()
	local firstPos = pos

	--Starting Units
	for i=1,4 do
		TheGameManager:SpawnUnit(pos[1].x, pos[1].y, Units.Settler, i)
		TheGameManager:SpawnUnit(pos[2].x, pos[2].y, Units.Warrior, i)
		TheGameManager:SpawnUnit(pos[3].x, pos[3].y, Units.Archer, i)
		TheGameManager:SpawnUnit(pos[4].x, pos[4].y, Units.Builder, i)

		pos = PickRandomSpawnPositions()
	end

	--Debug Spawn Cities
	--[[for i=1,4 do
		for j=1,4 do
			local x, y = PickRandomLandCell()
			TheGameManager:CreateCity(x, y, i)
		end
	end]]

	--Init First Turn (Mostly vision)
	TheGameManager:NextTurn()

	--Center Camera (Now covered by TheGameManager)
	--TheCamera:Center(firstPos[1].x, firstPos[1].y)
end

UpdateCallback = function(dt)
	--print("Screen_HUD:          "..tostring(Screen_HUD.visible))
	print("Screen_CityOverview: "..tostring(Screen_CityOverview.visible))

	local focus = ROOT:GetFocused(MX, MY)
	print("Focus: "..tostring(focus and focus.name or "nil"))
	print("is_ui: "..tostring((focus and focus.is_ui) or ((not focus) and "N/A")))
	print("SHOW_YIELDS: "..tostring(SHOW_YIELDS))
			
	print("Locked?")
	print(ActiveScreenLastUpdate.prevent_input_handling)

	print(ActiveScreen.name)

	ActiveScreenLastUpdate = ActiveScreen

	if (not focus) or (not focus.is_ui) then
		local x,y = TheGrid:WorldToLocal(MX,MY)
		local cx,cy = WorldToCartesian(x,y)
		if TheTargetingUI.is_active then TheTargetingUI.targetmode.selectdrawfn(TheTargetingUI.unit, TheGrid:GetCell(cx, cy)) end
	end
	if focus and focus.tooltip then
		UI_Tooltip:SetText(focus.tooltip.txt,focus.tooltip.w)
	else
		UI_Tooltip:Hide()
	end

	if not love.mouse.isDown(1) then LockClickHandlers = false end
end
		
PostPrefabDrawCallback = function()		
	--
end

function ValidateTechs()
	for k,v in pairs(Techs) do
		local broke, err = table.broken(v.units or {})
		assert(not broke, "Broken Unit List in Tech ["..k.."]; Element #"..tostring(err))
	end
end

return Init