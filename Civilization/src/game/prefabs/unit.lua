local icon_scale = 4.3
local bg_scale = 4.0

local bar_w = 4
local bar_h = 32
local bar_x = -20
local bar_y = -bar_h/2

icon_scale = icon_scale * TUNING.UNITS_SCALE
bg_scale = bg_scale * TUNING.UNITS_SCALE

local action_length = 0.25 --Seconds

local Bar = require("game/widgets/bar")

local Unit = Class(Prefab, function(self, cx, cy, map, type, owner)
	self.base._ctor(self, 0, 0)

	self.layer = LAYERS.UNITS

	self.cx = cx
	self.cy = cy

	self.map = map

	self.type = type
	self.name = self.type.name

	self.owner = owner --INTEGER
	self.faction = TheGameManager:GetFaction(self.owner)

	self.color1 = self.faction.color1 or COLORS.YELLOW
	self.color2 = self.faction.color2 or COLORS.PURPLE

	self.max_hp = type.hp
	self.max_mp = type.mp

	self.view = type.view

	self.mp = self.max_mp
	self.hp = self.max_hp

	self.actionqueue = {}
	self.action_acc = 0
	self.active = false --Tracks whether action can proceed, so it doesn't need to be checked every frame

	self.standing_orders = nil


	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)

	self.bg = Image(wx, wy, "uniticon_military", "tex")
	self.bg2 = Image(wx, wy, "uniticon_military_unshaded", "tex")
	self.icon = Image(wx, wy, self.type.icon, "tex")
	self.icon.r = self.color1[1]
	self.icon.g = self.color1[2]
	self.icon.b = self.color1[3]

	self.hp_bar = Bar(wx+(bar_x*TheCamera.sx), wy+((-bar_h/2)*TheCamera.sy), bar_w, bar_h, self.max_hp, self.max_hp, TUNING.HP_BAR_BG, TUNING.HP_BAR_FG, true)
end)

--
-- Save Data
--

function Unit:GetSaveData()
	local savedata = {}

	savedata.cx = self.cx
	savedata.cy = self.cy

	savedata.type = self.type.uid

	savedata.owner = self.owner

	if self.name ~= self.type.name then
		savedata.name = self.name
	end

	savedata.hp = self.hp
	savedata.mp = self.mp

	savedata.actionqueue = {}
	for i=1,#self.actionqueue do
		savedata.actionqueue[i] = {
			action = self.actionqueue[i].action,
			target = {
				cx=self.actionqueue[i].target.x,
				cy=self.actionqueue[i].target.y
			}
		}
	end

	savedata.standing_orders = self.standing_orders --TODO: Registry?

	return savedata
end

function Unit:LoadSaveData(savedata)
	if savedata.name then
		self.name = savedata.name
	end

	self.hp = savedata.hp
	self.mp = savedata.mp

	self.actionqueue = {}
	for i=1,#savedata.actionqueue do
		local actiondata = savedata.actionqueue[i]
		self.actionqueue[i] = {
			action = actiondata.action,
			target = self.map:GetCell(actiondata.target.cx, actiondata.target.cy)
		}
	end

	self.standing_orders = savedata.standing_orders
end

--
-- Other Stuff
--

function Unit:Update(dt)
	if self.active then
		self.action_acc = self.action_acc + dt
		if self.action_acc >= action_length then
			--Finish EXE
			local data = self.actionqueue[1]
			if data.action == "move" then
				self:MoveTo(data.target)
			end

			--Remove from queue
			table.remove(self.actionqueue, 1)

			--Check self.active
			self.active = self:CanAct()

			if not self.active then self.actionqueue = {} end --Makes other code redundant?

			--Reset timer
			self.action_acc = 0
		end
	end

	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)
	local x, y
	if self.active and self.actionqueue[1].action == "move" and not JUTTER then
		local target = self.actionqueue[1].target
		local wx2, wy2 = self.map:GetHexCenter(target.x, target.y)
		local t = self.action_acc/action_length
		x = math.lerp(wx, wx2, t)
		y = math.lerp(wy, wy2, t)
	else
		x = wx
		y = wy
	end
	self.bg.Transform:SetPosition(x,y) --Widgets really shouldn't have transforms EDIT: Too late now! *shrugs*
	self.bg2.Transform:SetPosition(x,y)
	self.icon.Transform:SetPosition(x,y)
	self.hp_bar.Transform:SetPosition(x+(bar_x*TheCamera.sx),y+((-bar_h/2)*TheCamera.sy))
	self.bg.Transform:SetScale(TheCamera.sx*bg_scale, TheCamera.sy*bg_scale)
	--self.bg.Transform:SetScale(TheCamera.sx, TheCamera.sy) --*
	self.bg2.Transform:SetScale(TheCamera.sx*bg_scale, TheCamera.sy*bg_scale)
	self.icon.Transform:SetScale(TheCamera.sx*icon_scale, TheCamera.sy*icon_scale)
	self.hp_bar.Transform:SetScale(TheCamera.sx,TheCamera.sy)

	self.hp_bar:SetValues(self.hp, self.max_hp)
end

function Unit:DealDamage(dmg)
	self.hp = math.max(0, self.hp - dmg)
	self.hp_bar:SetValues(self.hp, self.max_hp)
	p_print("DBG_4 "..self.hp)

	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)
	local text = Text(wx + TUNING.UI.DAMAGEFLOATER_OFFSET_X, wy, tostring(-dmg), COLORS.RED)
	TheFloatingTextRenderer:AddObj(text)

	if self.hp == 0 then
		TheGameManager:RemoveUnit(self)
	end
end

function Unit:DoHealing(amt)
	amt = math.min(amt, self.max_hp - self.hp)
	self.hp = self.hp + amt
	local wx, wy = self.map:GetHexCenter(self.cx, self.cy)
	if amt > 0 then
		local text = Text(wx + TUNING.UI.DAMAGEFLOATER_OFFSET_X, wy, tostring(amt), COLORS.GREEN)
		TheFloatingTextRenderer:AddObj(text)
	end
end

-- 'cell' parameter is optional
function Unit:DoAction(action, cell)
	self.standing_orders = nil
	action.fn(self, cell)

	if not action.keep_ui then
		UI_InfoBox_Unit:Hide()
		self.map.selected = nil
	end

	if action.consumes_attack then
		self.has_attacked = true
		self.mp = 0
	end

	TheGameManager:RecalcNextNecessaryAction()
end

function Unit:GetCell()
	return self.map:GetCell(self.cx, self.cy)
end

function Unit:Draw()
	local vis = self.map:GetCell(self.cx, self.cy).visibility[TheGameManager.player_num]
	if not vis or vis == 0 then return end

	--local wx, wy = self.map:GetHexCenter(self.cx, self.cy)
	--assert(false,tostring(love.graphics.getShader()))
	love.graphics.setShader(SHADERS.TWOCOLORS)
	SHADERS.TWOCOLORS:send("fg_color", { self.color1[1], self.color1[2], self.color1[3], (self.color1[4] or 255) })
	SHADERS.TWOCOLORS:send("bg_color", { self.color2[1], self.color2[2], self.color2[3], (self.color2[4] or 255) })
	self.bg:Draw()
	love.graphics.setShader()
	--self.bg2:Draw()
	--geo.drawBorderedCircle(wx,wy,20*TheCamera.sx,3*TheCamera.sx,self.color1,self.color2)

	self.icon:Draw()

	if self.hp < self.max_hp then self.hp_bar:Draw() end

	--[[love.graphics.setColor(self.color1)
	love.graphics.circle("fill",wx,wy,20*TheCamera.sx)
	love.graphics.setColor(self.color2)
	love.graphics.circle("fill",wx,wy,16*TheCamera.sx)
	love.graphics.setColor(COLORS.BLACK)
	love.graphics.circle("line",wx,wy,20*TheCamera.sx)
	--love.graphics.circle("line",wx,wy,17*TheCamera.sx)
	love.graphics.setColor(COLORS.WHITE)]]
end

--Could feasibly be local
function Unit:CanAct()
	if #self.actionqueue == 0 then return false end

	local data = self.actionqueue[1]
	if data.action=="move" then
		return self.mp > 0 and (not data.target.unit)
	end
	return true
end

function Unit:MoveAlong(path)
	self.actionqueue = {}
	local fix = false
	for i=2,#path do
		table.insert(self.actionqueue, { action="move", target=path[i] })
		if path[i].unit then fix = true end
	end
	if fix then self:FixMovePath() end
	self.active = self:CanAct()
end

function Unit:FixMovePath()
	-- body
end

--If MP < movecost (but nonzero), motion still works (design choice)
function Unit:MoveTo(cell)
	if self.mp > 0 then
		if cell.unit then
			self.actionqueue = {}
			self.active = false
		else
			self.map:GetCell(self.cx, self.cy).unit = nil
			if self.map.selected == self.map:GetCell(self.cx, self.cy) then
				self.map.selected = cell
			end
			self.cx = cell.x
			self.cy = cell.y
			self.map:GetCell(self.cx, self.cy).unit = self
			--TODO: Account for other units

			self.mp = math.max(self.mp - cell.movecost, 0)
			self:OnStatChange()

			self.map:RecalcVision(self.owner)
		end
	end
end

function Unit:GetUnitActions()
	local actions = {}

	for k,v in pairs(UnitActions) do
		if v.showfn(self) then
			table.insert(actions, v)
		end
	end
	table.sort(actions, function(a, b) return a.sortvalue < b.sortvalue end)

	return actions
end

function Unit:IsAttackable(attacker)
	return attacker.owner ~= self.owner
end

function Unit:IsDoneWithTurn()
	if self.has_attacked then return true end
	if self.mp == 0 then return true end
	if self.standing_orders then return true end

	return false
end

function Unit:NextTurn(notick)
	if not notick then
		if self.mp == self.max_mp then
			self:DoHealing(TUNING.GAMEPLAY.HEAL_PER_TURN)
		else
			self.mp = self.max_mp
		end
	end

	--self.map:Reveal(self.cx, self.cy, self.view, self.owner) --TODO: Investigate

	if not notick then
		if self.standing_orders then
			if self.standing_orders == Enum_StandingOrders.SKIP then
				self.standing_orders = nil
			elseif self.standing_orders == Enum_StandingOrders.HEAL then
				if self.hp == self.max_hp then
					self.standing_orders = nil
				end
			end
		end
	end
end

function Unit:OnStatChange()
	if UI_InfoBox_Unit.visible and UI_InfoBox_Unit.unit == self then
		UI_InfoBox_Unit:LoadUnit(self)
	end

	--Shouldn't ever not happen... yet
	if TheGameManager:GetPlayer(self.owner) == TheGameManager.current_player then
		TheGameManager:RecalcNextNecessaryAction()
	end
end

function Unit:OnKeypress(key, ctrl)
	for i,v in ipairs(self:GetUnitActions()) do
		if v.key == key and (v.ctrl or false) == ctrl then
			if v.uifn then
				v.uifn(self)
			else
				self:DoAction(v)
			end
		end
	end
end

return Unit