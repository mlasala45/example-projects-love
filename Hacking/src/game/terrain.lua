Biomes = {
	Tundra = { name=STRINGS.BIOMES.TUNDRA, color=COLORS.WHITE, tex="tile_desert", moisture=-1, movecost=1, yields = {}, portrait="portrait_desert" },
	Jungle = { name=STRINGS.BIOMES.JUNGLE, color=COLORS.DARK_GREEN, tex="tile_marsh", moisture=2, movecost=2, yields = {}, portrait="portrait_marsh" },
	Desert = { name=STRINGS.BIOMES.DESERT, color=COLORS.YELLOW, tex="tile_desert", moisture=-1, movecost=1, yields = {}, portrait="portrait_desert" },
	Savanna = { name=STRINGS.BIOMES.SAVANNA, color={216,172,41}, tex="tile_plains", moisture=1, movecost=1, yields = { food=1, prod=1 }, portrait="portrait_plains" },
	Grasslands = { name=STRINGS.BIOMES.GRASSLANDS, color=COLORS.GREEN, tex="tile_plains", moisture=1, movecost=1, yields = { food=2 }, portrait="portrait_plains" },
	Marsh = { name=STRINGS.BIOMES.MARSH, color=COLORS.DARK_GREEN, tex="tile_marsh", moisture=2, movecost=2, yields = { food=3 },portrait="portrait_marsh" },

	Floodplain = { name=STRINGS.BIOMES.FLOODPLAIN, color={163,175,28}, tex="tile_marsh", moisture=1, movecost=1, yields = { food=2 },portrait="portrait_marsh" },

	--Mountain = { color=COLORS.DARK_GRAY, impassable=true }

	Coast = { name=STRINGS.BIOMES.COAST, color=COLORS.CYAN, tex="tile_coast", marine=true, movecost=1, yields = { food=1 },portrait="portrait_coast" },
	Ocean = { name=STRINGS.BIOMES.OCEAN, color=COLORS.DARK_BLUE, tex="tile_ocean", marine=true, movecost=1, yields = {},portrait="portrait_ocean" },

	Debug = { name="Debug Terrain", color=COLORS.MAGENTA, tex="tile_ocean", marine=false, movecost=1, portrait="portrait_ocean" },
}

Yields = {
	river = { gold=1 },

	--Terrain
	hills = { prod=1 },

	--Vegetation
	forest = { prod=1 },
}

--AutoCorrect/Defaults
for k,v in pairs(Biomes) do
	if v.marine == nil then v.marine = false end
	if not v.movecost then v.movecost = 1 end
	if not v.moisture then v.moisture = 0 end
	if not v.yields then v.yields = {} end

	assert(v.name, "Biome '"..k.."'' missing attribute 'name'")
	assert(v.color, "Biome '"..k.."'' missing attribute 'color'")
	assert(v.tex, "Biome '"..k.."'' missing attribute 'tex'")
	assert(v.portrait, "Biome '"..k.."'' missing attribute 'portrait'")
end

--TMP
PlateBiomes = {
	Biomes.Desert,
	Biomes.Savanna,
	Biomes.Grasslands,
	Biomes.Marsh,
}