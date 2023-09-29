local Unit = require("game/prefabs/unit")
local City = require("game/prefabs/city")

local SaveGameIndex = Class(Prefab, function(self)
	self.base._ctor(self, 0, 0)

	love.filesystem.createDirectory("savegames")
end)

local ext = ".civsave"

function SaveGameIndex:SaveGameToFile(filename)
	local savedata = TheGameManager:GetSaveData()

	local file = love.filesystem.newFile("savegames/"..filename..ext)
	assert(file:open("w")) --TODO: Remove crash on error

	file:write(table.serialize(savedata))

	file:flush()
	file:close()
end

function SaveGameIndex:LoadGameFromFile(filename)
	local file = love.filesystem.newFile("savegames/"..filename..ext)
	assert(file:open("r")) --TODO: Remove crash on error

	local savedata = table.deserialize(file:read())

	TheGameManager:LoadSaveData(savedata)

	file:close()
end

function SaveGameIndex:Save(filename)
	self:SaveGameToFile(filename)
end

function SaveGameIndex:Load(filename)
	self:LoadGameFromFile(filename)
end

return SaveGameIndex