GlobalPrefabs = {}

Prefab = Class(function(self, type, x, y)
	self.type = type

	self.components = {}

	self.x = x or 0
	self.y = y or 0

	self.alpha = 255

	table.insert(GlobalPrefabs, self)
	self.layer = 1
end)

function Prefab:AddChild(child)
	table.insert(self.children, child)
	child.parent = self
end

function Prefab:MoveToFront()
	for i,v in ipairs(GlobalPrefabs) do
		if v == self then
			table.remove(GlobalPrefabs, i)
			table.insert(GlobalPrefabs, 1, self)
			return
		end
	end
end

function Prefab:AddComponent(type)
	local ctor = require("engine/components/"..type)
	local comp = ctor(self)
	self.components[type] = comp
end

function Prefab:Remove()
	for i=1,#GlobalPrefabs do
		if GlobalPrefabs[i]==self then
			table.remove(GlobalPrefabs, i)
			break
		end
	end
end

function Prefab:Update(dt)
	for k,v in pairs(self.components) do
		if v.Update then v:Update(dt) end
	end
end

function Prefab:Draw()
	--
end