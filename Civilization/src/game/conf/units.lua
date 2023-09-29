--TODO: New system for stats and unit types
Units = {}

local ACC = 1

local function RegisterUnit(name, data)
	data.build_type = "unit"
	if not data.view then data.view = TUNING.DEFAULT_UNIT_VIEW_RANGE end


	Units[name] = data
	Units[name].uid = ACC

	ACC = ACC + 1
end

RegisterUnit("Warrior", { name=STRINGS.UNITS.WARRIOR, desc=STRINGS.DESC.UNITS.WARRIOR, icon="icon_warrior", portrait="portrait_warrior", hp = 100, cp = 10, mp = 3, cost=50 })
RegisterUnit("Settler", { name=STRINGS.UNITS.SETTLER, desc=STRINGS.DESC.UNITS.SETTLER, icon="icon_settler", portrait="portrait_settler", civilian = true, hp = 100, cp = 0, mp = 3, cost=50 })
RegisterUnit("Archer",  { name=STRINGS.UNITS.ARCHER, desc=STRINGS.DESC.UNITS.ARCHER, icon="icon_archer", portrait="portrait_archer",  hp = 100, cp = 10, mp = 3, cost=50, ranged=true })
RegisterUnit("Builder", { name=STRINGS.UNITS.BUILDER, desc=STRINGS.DESC.UNITS.BUILDER, icon="icon_builder", portrait="portrait_builder", civilian = true, builds_improvements = true, hp = 100, cp = 0, mp = 3, cost=50 })

RegisterUnit("Horseman", { name=STRINGS.UNITS.HORSEMAN, desc=STRINGS.DESC.UNITS.HORSEMAN, icon="icon_warrior", portrait="portrait_horseman", hp = 100, cp = 10, mp = 5, cost=50 })