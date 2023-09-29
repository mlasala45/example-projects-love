Improvements = {}

Improvements["Farm"] = {
	name = STRINGS.IMPROVEMENTS.FARM,
	action_atlas = "Improvements_Farm",
	action_key = "f",
	action_ctrl = true,

	map_atlas = "Improvements_Farm_Revealed",

	testfn = function(cell)
		p_print("TESTFN")
		return cell.biome == Biomes.Grasslands or cell.biome == Biomes.Savanna or cell.biome == Biomes.Jungle
	end,

	base_yields = {
		food=1
	},
}

Improvements["Pasture"] = {
	name = STRINGS.IMPROVEMENTS.PASTURE,
	action_atlas = "Improvements_Pasture",
	action_key = "p",
	action_ctrl = true,

	map_atlas = "Improvements_Pasture_Revealed",

	testfn = function(cell)
		return true --cell.biome == "grassland"
	end,

	base_yields = {
		prod=1
	},
}

Improvements["Mine"] = {
	name = STRINGS.IMPROVEMENTS.MINE,
	action_atlas = "Improvements_Mine",
	action_key = "m",
	action_ctrl = true,

	map_atlas = "Improvements_Mine_Revealed",

	testfn = function(cell)
		return cell.terrain == "hills"
	end,

	base_yields = {
		prod=1
	},
}

Improvements["RemoveForest"] = {
	name = STRINGS.IMPROVEMENTS.REMOVE_FOREST,
	action_atlas = "citizen",--"Improvements_RemoveForest",
	action_key = "r",
	action_ctrl = true,

	testfn = function(cell)
		return cell.owning_city and cell.vegetation == "forest"
	end,

	oncomplete = function(cell)
		cell.vegetation = nil
		--Give prod to city
		local city = cell.owning_city
		local prod = TUNING.GAMEPLAY.PRODUCTION_FROM_FOREST
		city:AddProduction(prod)

		local wx, wy = cell.map:GetHexCenter(cell.x, cell.y)
		local text = IconText(wx, wy + TUNING.UI.YIELDFLOATER_OFFSET_Y, "+"..prod.."%prod%", CUSTOM_COLORS.PRODUCTION)
		TheFloatingTextRenderer:AddObj(text)
	end,

	is_activity = true,
}

for k,v in pairs(Improvements) do v.name = k end