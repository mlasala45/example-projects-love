local action_move = function(unit)
	p_print("ACTION MOVE")
end

local action_attack = function(unit)	
	p_print("ACTION ATTACK")
end

local action_disband = function(unit)	
	p_print("ACTION DISBAND")
end

local action_settle = function(unit)
	UnitActions.FoundCity.fn(unit)
	--[[local x,y = unit.cx, unit.cy
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
	TheGameManager:PushNotification(unit.owner, notif_data)]]
end

local action_ranged_attack = function(unit)	
	--p_print("ACTION RANGED_ATTACK")

end

local action_construct_1 = function(unit)	
	p_print("ACTION CONSTRUCT_1")
end

local action_construct_2 = function(unit)	
	p_print("ACTION CONSTRUCT_2")
end

local action_construct_3 = function(unit)	
	p_print("ACTION CONSTRUCT_3")
end

local keys_warrior = {
	["m"]=action_move,
	["a"]=action_attack,
	["delete"]=action_disband,
}
local keys_settler = {
	["m"]=action_move,
	["b"]=action_settle,
	["delete"]=action_disband,
}
local keys_archer = {
	["m"]=action_move,
	["a"]=action_ranged_attack,
	["delete"]=action_disband,
}
local keys_builder = {
	["m"]=action_move,
	["e"]=action_construct_1,
	["r"]=action_construct_2,
	["t"]=action_construct_3,
	["delete"]=action_disband,
}

--TODO: New system for stats and unit types
Units = {
	Warrior = { name=STRINGS.UNITS.WARRIOR, desc=STRINGS.DESC.UNITS.WARRIOR, icon="icon_warrior", portrait="portrait_warrior", hp = 100, cp = 10, mp = 3, keys=keys_warrior, cost=50 },
	Settler = { name=STRINGS.UNITS.SETTLER, desc=STRINGS.DESC.UNITS.SETTLER, icon="icon_settler", portrait="portrait_settler", hp = 100, cp = 0, mp = 3,  keys=keys_settler, cost=50 },
	Archer = { name=STRINGS.UNITS.ARCHER, desc=STRINGS.DESC.UNITS.ARCHER, icon="icon_archer", portrait="portrait_archer",  hp = 100, cp = 10, mp = 3, keys=keys_archer, cost=50, ranged=true },
	Builder = { name=STRINGS.UNITS.BUILDER, desc=STRINGS.DESC.UNITS.BUILDER, icon="icon_builder", portrait="portrait_builder", hp = 100, cp = 0, mp = 3, keys=keys_builder, cost=50 },
}

for k,v in pairs(Units) do
	v.build_type = "unit"
	if not v.view then v.view = TUNING.DEFAULT_UNIT_VIEW_RANGE end
end