require "game/util/color"
require "game/util/math"
require "game/util/table"
require "game/util/hex"
require "game/util/geo"

require "game/util/renderutil"

--~/game Files

--Prefabs
local Camera = require("engine/prefabs/camera")

local GameManager = require("game/prefabs/gamemanager")
local NetMap = require("game/prefabs/netmap")

--Toggled Widgets

--Screens

--Hud
local Tooltip = require("game/widgets/tooltip")

local function Init()
	FONTS = {}
	FONTS.DEFAULT = love.graphics.newFont("base/assets/fonts/bliz-quadrata.ttf")
	FONTS.DEFAULT_LARGE = love.graphics.newFont("base/assets/fonts/bliz-quadrata.ttf",20)
	FONTS.DEFAULT_BOLD = love.graphics.newFont("base/assets/fonts/bliz-quadrata_bold.ttf")
	love.graphics.setFont(FONTS.DEFAULT_LARGE)

	SHADERS = {
		TWOCOLORS = love.graphics.newShader(require("game/shaders/twocolor")),
		TILESHADER = love.graphics.newShader(require("game/shaders/tileshader")),
	}

	--Map
	TheNetMap = NetMap(MID_X, MID_Y)

	--Progression?

	--Game Setup

	--Game Manager and Player Setup
	TheGameManager = GameManager()

	--UI
	Screen_HUD = ROOT:AddChild(Screen())

	--HUD
	PrefabHitBoxParent = ROOT:AddChild(Widget("PrefabHitBoxParent"))

	UI_Tooltip = Tooltip()
	ROOT:AddChild(UI_Tooltip)
	UI_Tooltip.Transform:SetScale(1.5)

	--Camera

	TheCamera = Camera()
	TheCamera.no_clamps = true
	--[[TheCamera.minX = -TheGrid.ww/2
	TheCamera.maxX = TheGrid.ww/2
	TheCamera.minY = -TheGrid.wh/2
	TheCamera.maxY = TheGrid.wh/2]]

	--Input Handling

	InputHandler:AddKeypressHandler("-",function(isrepeat)
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

	InputHandler:AddKeypressHandler("return",function(isrepeat)
		--[[local notif_data = {
			portrait = "portrait_alert",
			msg = "A Builder finished being built in Antium.",
		}
		TheGameManager:PushNotification(TheGameManager.player_num, notif_data)]]
	end)

	InputHandler:AddScrollHandler(function(n)
		n = n / 10
		TheCamera.sx = math.clamp(TheCamera.sx + n, MIN_ZOOM, MAX_ZOOM)
		TheCamera.sy = math.clamp(TheCamera.sy + n, MIN_ZOOM, MAX_ZOOM)
	end)

	InputHandler:AddClickHandler(function(x, y, button)
		local mx, my = love.mouse:getPosition()
		local focus = ROOT:GetFocused(mx, my)
		if focus and focus.is_ui then return end
		if button == 1 then
			--

			if love.keyboard.isDown("lshift") then
				--
			else
				--
			end
		end
	end)

	InputHandler:AddGeneralKeypressHandler(function(key, isrepeat)
		if not isrepeat then
			--
		end
	end)

	--Starting Units

	local node_root = TheNetMap:AddNode({ x=0, y=0, name="localhost" })

	local r = 5
	for i=1,4 do
		local theta1 = 360 * (i/4)
		local x1, y1 = math.polartocart(r, math.rad(theta1))
		local node_parent = TheNetMap:AddNode({ x=x1, y=y1, parent=node_root, name="192.168."..i..".0" })

		for j=1,3 do
			local variance = (360 / 4) * 0.5
			local theta2 = (variance * ((j-1)/2)) - (variance / 2)
			local x2, y2 = math.polartocart(r + 4, math.rad(theta1 + theta2))
			TheNetMap:AddNode({ x=x2, y=y2, parent = node_parent, name="192.168."..i.."."..j })
		end
	end

	--Debug Spawn Cities
	--[[for i=1,4 do
		for j=1,4 do
			local x, y = PickRandomLandCell()
			TheGameManager:CreateCity(x, y, i)
		end
	end]]

	--Init First Turn (Mostly vision)
	--TheGameManager:NextTurn()
end

local last_focused
UpdateCallback = function(dt)
	local mx, my = love.mouse:getPosition()
	local focus = ROOT:GetFocused(mx, my)
	print("Focus: "..tostring(focus and focus.name or "nil"))

	if last_focused then last_focused.hitbox_owner.is_focus = false end
	if focus and focus.hitbox_owner then
		print(tostring(focus.hitbox_owner.hover_acc))
		focus.hitbox_owner.is_focus = true
		last_focused = focus
	end

	if focus and focus.tooltip then
		UI_Tooltip:LoadTooltip(focus.tooltip)
	else
		UI_Tooltip:Hide()
	end
end

return Init