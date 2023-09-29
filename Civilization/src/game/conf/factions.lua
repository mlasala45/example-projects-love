Factions = {}

local ACC = 1

local function RegisterFaction(name, data)
	Factions[name] = data
	Factions[name].uid = ACC

	ACC = ACC + 1
end

RegisterFaction("Rome",    { name=STRINGS.FACTIONS.ROME, color1=COLORS.YELLOW, color2=COLORS.PURPLE, cities=STRINGS.CITYNAMES.ROME })
RegisterFaction("America", { name=STRINGS.FACTIONS.AMERICA, color1=COLORS.WHITE, color2=COLORS.BLUE, cities=STRINGS.CITYNAMES.AMERICA })
RegisterFaction("France",  { name=STRINGS.FACTIONS.FRANCE, color1=COLORS.CYAN, color2=COLORS.WHITE, cities=STRINGS.CITYNAMES.FRANCE })
RegisterFaction("Egypt",   { name=STRINGS.FACTIONS.EGYPT, color1=COLORS.PURPLE, color2=COLORS.YELLOW, cities=STRINGS.CITYNAMES.EGYPT })