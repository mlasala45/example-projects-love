--Attack

local function uafn_attack(unit, cell)
	if unit.mp == 0 then return end

	if cell.unit then
		cell.unit:DealDamage(30)
	end
	if not cell.unit then
		unit:MoveAlong({ unit.cell, cell })
	end
end

local function uifn_attack(unit)
	TheTargetingUI:TargetFromUnit(unit, TargetingModes.MeleeAttack, UnitActions.Attack)
end

local function cellfn_attack(unit)
	local inrange = hex.neighbors(unit.map:GetCell(unit.cx, unit.cy))
	local valid = {}
	for i,v in ipairs(inrange) do
		if v.unit and v.unit ~= unit and true then--v.unit.owner ~= unit.owner then
			valid[v] = true
		end
	end
	return valid
end

--Bombard

local function uafn_bombard(unit, cell)
	p_print("DBG_3")
	if cell.unit then
		p_print("DBG_4")
		cell.unit:DealDamage(30) --TODO: Damage sources, combat power
	end
end

local function uifn_bombard(unit)
	TheTargetingUI:TargetFromUnit(unit, TargetingModes.RangedAttack, UnitActions.Bombard)
end

local function cellfn_bombard(unit)
	local inrange = unit.map:GetTilesInViewRange(unit.cx, unit.cy, unit.view, false)
	local valid = {}
	for i,v in ipairs(inrange) do
		if v.unit and v.unit ~= unit and true then--v.unit.owner ~= unit.owner then
			valid[v] = true
		end
	end
	return valid
end

--Build Improvements

local function build_improvement(unit, improvement)
	local cell = unit.map:GetCell(unit.cx, unit.cy)
	if improvement.is_activity then
		improvement.oncomplete(cell)
	else
		cell.improvement = improvement
		cell.yields = unit.map:GetCellYields(cell)
	end
end

local function make_improvement_uafn(improvement)
	return function(unit)
		build_improvement(unit, improvement)
	end
end

--Disband

local function uafn_disband(unit)
	TheGameManager:RemoveUnit(unit)
end

--Fortify

local function uafn_fortify(unit)
	unit.standing_orders = Enum_StandingOrders.FORTIFY
	UI_InfoBox_Unit:Hide()
	unit.map.selected = nil
end

--FoundCity

local function uafn_foundcity(unit)
	--assert(unit.type == Units.Settler)

	--Requires Initiative
	if unit.mp == 0 then return end

	--Cannot found too close to another city
	local x,y = unit.cx, unit.cy
	local map = unit.map
	for i,v in ipairs(hex.range(x,y,TUNING.SETTLEMENT_SPACING)) do
		if map:GetCity(v.x, v.y) then return end
	end

	--Remove the unit and create the city
	TheGameManager:RemoveUnit(unit)
	if UI_InfoBox_Unit.unit == unit then UI_InfoBox_Unit:Hide() end
	local city = TheGameManager:CreateCity(x,y,unit.owner)

	--Push new city notification
	local notif_data = {
		portrait = "portrait_alert",
		msg = string.format(STRINGS.UI.NOTIFICATIONS.CITY_FOUNDED, city.name),
		clickfn = function() TheCamera:Center(x, y) end
	}
	TheGameManager:PushNotification(unit.owner, notif_data)

	--Recalc Yields
	TheGameManager:RecalcGlobalStats(TheGameManager:GetPlayer(unit.owner))
	UI_GlobalStatsBar:RecalcStats()

	TheGameManager:RecalcNextNecessaryAction()
end

--Garrison

local function uafn_garrison(unit)
	uafn_fortify(unit)
end

--Heal

local function uafn_heal(unit)
	unit.standing_orders = Enum_StandingOrders.HEAL
	UI_InfoBox_Unit:Hide()
	unit.map.selected = nil
end

--Move

local function uafn_move(unit)
	unit:MoveAlong(ThePathfinder.path)
end

local function uifn_move(unit)
	TheTargetingUI:TargetFromUnit(unit, TargetingModes.MotionRange, UnitActions.Move)
end

local function cellfn_move(unit)
	local inrange = unit.map:GetTilesInMoveRange(unit.cx, unit.cy, unit.mp)
	local ret = {}
	for i,v in ipairs(inrange) do
		local valid = true
		if v.unit then
			if v.unit.owner == unit.owner then
				valid = false --For now, no civilian units
			end
		end
		if valid then
			ret[v] = true
		end
	end
	TheTargetingUI.data.cells = inrange --To avoid repeated calls of GetTilesInMoveRange
	return ret
end

--Skip

local function uafn_skip(unit)
	unit.standing_orders = Enum_StandingOrders.SKIP
	UI_InfoBox_Unit:Hide()
	unit.map.selected = nil
end

--
--UTILITY FUNCTIONS
--

local function utilfn_alwaystrue() return true end

--
--SHOW FUNCTIONS
--

local function showfn_attack(unit)
	return (not unit.type.civilian) and (not unit.type.ranged)
end

local function showfn_bombard(unit)
	return unit.type.ranged
end

local function showfn_fortify(unit)
	return (not TheGrid:GetCity(unit.cx, unit.cy))
end

local function showfn_foundcity(unit)
	return unit.type == Units.Settler
end

local function showfn_garrison(unit)
	return unit.hp == unit.max_hp and TheGrid:GetCity(unit.cx, unit.cy) ~= nil
end

local function showfn_heal(unit)
	return unit.hp < unit.max_hp
end

--
--DEFINITIONS
--

UnitActions = {
	Attack = { name=STRINGS.UNITACTIONS.ATTACK, atlas="ua_attack", key="a", ctrl=true, fn=uafn_attack, uifn=uifn_attack, cellfn=cellfn_attack },
	Bombard = { name=STRINGS.UNITACTIONS.BOMBARD, atlas="ua_bombard", key="b", fn=uafn_bombard, uifn=uifn_bombard, cellfn=cellfn_bombard },
	Disband = { name=STRINGS.UNITACTIONS.DISBAND, atlas="ua_disband", key="delete", fn=uafn_disband, notarget=true },
	Fortify = { name=STRINGS.UNITACTIONS.FORTIFY, atlas="ua_fortify", key="f", fn=uafn_fortify, notarget=true },
	FoundCity = { name=STRINGS.UNITACTIONS.FOUNDCITY, atlas="ua_found_city", key="b", fn=uafn_foundcity, notarget=true },
	Garrison = { name=STRINGS.UNITACTIONS.GARRISON, atlas="ua_garrison", key="g", fn=uafn_garrison, notarget=true },
	Heal = { name=STRINGS.UNITACTIONS.HEAL, atlas="ua_heal", key="h", fn=uafn_heal, notarget=true },
	Move = { name=STRINGS.UNITACTIONS.MOVE, atlas="ua_move", key="m", fn=uafn_move, uifn=uifn_move, cellfn=cellfn_move },
	Skip = { name=STRINGS.UNITACTIONS.SKIP, atlas="ua_skip", key="space", fn=uafn_skip, notarget=true },
}

for k,v in pairs(Improvements) do
	local key = k
	if not v.is_activity then key = "Build"..k end
	UnitActions[key] = {
		name=string.format(STRINGS.UNITACTIONS.BUILD_IMPROVEMENT, v.name),
		atlas=v.action_atlas,
		key=v.action_key,
		ctrl=(v.action_ctrl or false),
		fn=make_improvement_uafn(v),
		notarget=true,

		sortvalue = 5,

		showfn = function(unit)
			return unit.type.builds_improvements and v.testfn(unit:GetCell())
		end
	}
end

UnitActions.Attack.consumes_attack = true
UnitActions.Bombard.consumes_attack = true

UnitActions.Move.keep_ui = true

for k,v in pairs(UnitActions) do
	v.image = "tex"
end

UnitActions.Attack.showfn = showfn_attack
UnitActions.Bombard.showfn = showfn_bombard
UnitActions.Disband.showfn = utilfn_alwaystrue
UnitActions.Fortify.showfn = showfn_fortify
UnitActions.FoundCity.showfn = showfn_foundcity
UnitActions.Garrison.showfn = showfn_garrison
UnitActions.Heal.showfn = showfn_heal
UnitActions.Move.showfn = utilfn_alwaystrue --For Now
UnitActions.Skip.showfn = utilfn_alwaystrue

UnitActions.Attack.sortvalue = 1
UnitActions.FoundCity.sortvalue = 1
UnitActions.Bombard.sortvalue = 1
UnitActions.Move.sortvalue = 2
UnitActions.Skip.sortvalue = 3
UnitActions.Fortify.sortvalue = 4
UnitActions.Heal.sortvalue = 4
UnitActions.Garrison.sortvalue = 4
UnitActions.Disband.sortvalue = 10