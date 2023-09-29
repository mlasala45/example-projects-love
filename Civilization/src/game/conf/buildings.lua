Buildings = {
	Palace = { name=STRINGS.BUILDINGS.PALACE, desc=STRINGS.DESC.BUILDINGS.PALACE, portrait="portrait_palace", cost=0, yields={prod=3,sci=3,gold=3,cult=1}, no_sell=true },

	Monument = { name=STRINGS.BUILDINGS.MONUMENT, desc=STRINGS.DESC.BUILDINGS.MONUMENT, portrait="portrait_monument", cost=50, yields={cult=1} },
	Granary = { name=STRINGS.BUILDINGS.GRANARY, desc=STRINGS.DESC.BUILDINGS.GRANARY, portrait="portrait_granary", cost=50, yields={food=2} },
	WaterMill = { name=STRINGS.BUILDINGS.WATERMILL, desc=STRINGS.DESC.BUILDINGS.WATERMILL, portrait="portrait_watermill", cost=50, yields={prod=2} },
}

for k,v in pairs(Buildings) do
	v.build_type = "building"
end