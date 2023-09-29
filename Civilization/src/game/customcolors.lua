CUSTOM_COLORS = {
	SCIENCE = { 77, 164, 222 },
	GOLD = { 255, 255, 99 },
	PRODUCTION = { 255, 147, 3 },
	CULTURE = { 231, 105, 206 },
	FOOD = { 148, 207, 16 },

	TECH_STATUS_0 = { 11, 16, 17 },
	TECH_STATUS_1 = { 50, 146, 2 },
	TECH_STATUS_2 = { 47, 106, 136 },
	TECH_STATUS_3 = { 202, 186, 83 },

	EXPANSION_INDICATOR = { 231, 105, 206 },

	SILVER = { 255, 255, 203 },

	UI_BUTTON = { 47, 106, 136 },
}

if CLAMP_COLORS then
	for k,v in pairs(CUSTOM_COLORS) do
		ClampColor(v)
	end
end