--
-- Utility Commands
--

function c_help()
	local commands = {}
	for k,v in pairs(_G) do
		if k:sub(1,2) == "c_" then
			table.insert(commands, k)
		end
	end
	table.sort(commands)

	print("Console Commands:")
	for i,v in ipairs(commands) do
		print(i.."    "..v)
	end
end

function c_dbg()
	DEBUG = not DEBUG
	DRAW_BOUNDS = not DRAW_BOUNDS
end

--
-- Map Affectors
--

function c_set_biome(biome)
	if not TheGrid.hovered then
		print("No tile selected!")
		return
	end
	if not table.contains(Biomes, biome) then
		print("Invalid biome!")
		return
	end
	TheGrid.hovered.biome = biome
	TheGrid:UpdateCellAttributes(TheGrid.hovered)
end

function c_set_terrain(terrain)
	if not TheGrid.hovered then
		print("No tile selected!")
		return
	end
	TheGrid.hovered.terrain = terrain
	TheGrid:UpdateCellAttributes(TheGrid.hovered)
end

function c_set_vegetation(vegetation)
	if not TheGrid.hovered then
		print("No tile selected!")
		return
	end
	TheGrid.hovered.vegetation = vegetation
	TheGrid:UpdateCellAttributes(TheGrid.hovered)
end

--Does not check valid placement
function c_spawn_city(player)
	if not TheGrid.hovered then
		print("No tile selected!")
		return
	end

	if not player then player = TheGameManager.player_num end
	if player < 1 or player > #TheGameManager.players then
		print("Invalid player!")
		return
	end

	TheGameManager:CreateCity(TheGrid.hovered.x, TheGrid.hovered.y, player)
end

--
-- Unit Affectors
--

function c_spawn(unit, player)
	if not TheGrid.hovered then
		print("No tile selected!")
		return
	end

	if not player then player = TheGameManager.player_num end
	if player < 1 or player > #TheGameManager.players then
		print("Invalid player!")
		return
	end

	if not table.contains(Units, unit) then
		print("Invalid unit!")
		return
	end

	TheGameManager:SpawnUnit(TheGrid.hovered.x, TheGrid.hovered.y, unit, player)
end

--
-- City Affectors
--

function c_grant_population(amt)
	local city

	if Screen_CityOverview.visible then
		city = Screen_CityOverview.DATA.city
	else
		if (not TheGrid.hovered) or (not TheGrid.hovered:GetCity()) then
			print("No city selected!")
			return
		end
		city = TheGrid.hovered:GetCity()
	end

	if amt <= -city.population then
		print("Removing cities is not yet implemented!")
		return
	end

	city.population = city.population + amt
	city:RecalcAll()
end

--
-- Vision
--

-- 'player' optional
function c_set_vis(vis, player)
	if not TheGrid.hovered then
		print("No tile selected!")
		return
	end

	if not player then player = TheGameManager.player_num end
	if player < 1 or player > #TheGameManager.players then
		print("Invalid player!")
		return
	end

	vis = math.clamp(vis, 0, 2)

	TheGrid.hovered.visibility[player] = vis
end

function c_reveal(r, player, ignoreterrain)
	if not r then
		c_set_vis(2)
		return
	end

	ignoreterrain = ignoreterrain or (ignoreterrain == nil and true)

	if not TheGrid.hovered then
		print("No tile selected!")
		return
	end

	if not player then player = TheGameManager.player_num end
	if player < 1 or player > #TheGameManager.players then
		print("Invalid player!")
		return
	end

	vis = math.max(r, 0)

	TheGrid:Reveal(TheGrid.hovered.x, TheGrid.hovered.y, r, player, ignoreterrain)
end

function c_reveal_all(player)
	if not player then player = TheGameManager.player_num end
	if player < 1 or player > #TheGameManager.players then
		print("Invalid player!")
		return
	end

	TheGrid:RevealAll(player)
end

--
-- Player Affectors
--

function c_unlock_tech(tech, player)
	if not table.contains(Techs, tech) then
		print("Invalid tech!")
		return
	end

	if not player then player = TheGameManager.player_num end
	if player < 1 or player > #TheGameManager.players then
		print("Invalid player!")
		return
	end

	TheGameManager:UnlockTech(tech, player)
end