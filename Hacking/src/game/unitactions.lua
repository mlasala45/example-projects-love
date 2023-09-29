--Attack

local function uafn_attack(unit)
	--
end

local function uifn_attack(unit)
	TheTargetingUI:TargetFromUnit(unit, TargetingModes.MeleeAttack)
end

--Bombard

local function uafn_bombard(unit)
	--
end

local function uifn_bombard(unit)
	TheTargetingUI:TargetFromUnit(unit, TargetingModes.RangedAttack)
end

--Disband

local function uafn_disband(unit)
	--
end

--Fortify

local function uafn_disband(unit)
	--
end

--FoundCity

local function uafn_foundcity(unit)
	local x,y = unit.cx, unit.cy
	local map = unit.map
	for i,v in ipairs(hex.range(x,y,TUNING.SETTLEMENT_SPACING)) do
		if map:GetCity(v.x, v.y) then return end
	end

	TheGameManager:RemoveUnit(unit)
	local city = TheGameManager:CreateCity(x,y,unit.owner)

	local notif_data = {
		portrait = "portrait_alert",
		msg = string.format(STRINGS.UI.NOTIFICATIONS.CITY_FOUNDED, city.name),
		clickfn = function() TheCamera:Center(x, y) end
	}
	TheGameManager:PushNotification(unit.owner, notif_data)
end

--Garrison

local function uafn_garrison(unit)
	--
end

--Heal

local function uafn_heal(unit)
	--
end

--Move

local function uafn_move(unit)
	--
end

local function uifn_move(unit)
	--
end

--Skip

local function uafn_skip(unit)
	--
end

--
--UTILITY FUNCTIONS
--

local function utilfn_alwaystrue() return true end

--
--SHOW FUNCTIONS
--

local function showfn_attack(unit)
	return not unit.type.ranged
end

local function showfn_bombard(unit)
	return unit.type.ranged
end

local function showfn_fortify(unit)
	return (not TheGrid:GetCity(unit.cx, unit.cy)) and unit.hp == unit.max_hp
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
	Attack = { name=STRINGS.UNITACTIONS.ATTACK, atlas="ua_attack", fn=uafn_attack, uifn=uifn_attack },
	Bombard = { name=STRINGS.UNITACTIONS.BOMBARD, atlas="ua_bombard", fn=uafn_bombard, uifn=uifn_bombard },
	Disband = { name=STRINGS.UNITACTIONS.DISBAND, atlas="ua_disband", fn=uafn_disband, notarget=true },
	Fortify = { name=STRINGS.UNITACTIONS.FORTIFY, atlas="ua_fortify", fn=uafn_fortify, notarget=true },
	FoundCity = { name=STRINGS.UNITACTIONS.FOUNDCITY, atlas="ua_found_city", fn=uafn_foundcity, notarget=true },
	Garrison = { name=STRINGS.UNITACTIONS.GARRISON, atlas="ua_garrison", fn=uafn_garrison, notarget=true },
	Heal = { name=STRINGS.UNITACTIONS.HEAL, atlas="ua_heal", fn=uafn_heal, notarget=true },
	Move = { name=STRINGS.UNITACTIONS.MOVE, atlas="ua_move", fn=uafn_move, uifn=uifn_move },
	Skip = { name=STRINGS.UNITACTIONS.SKIP, atlas="ua_skip", fn=uafn_skip, notarget=true },
}

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