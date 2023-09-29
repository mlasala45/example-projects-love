local NameplateRenderer = Class(Prefab, function(self)
	self.base._ctor(self, 0, 0)

	self.layer = LAYERS.TEXT

	self.nameplates = {}
end)

function NameplateRenderer:RegisterNameplate(obj)
	table.insert(self.nameplates, obj)
	return obj
end

function NameplateRenderer:RemoveNameplate(obj)
	for i,v in ipairs(self.nameplates) do
		if v == obj then
			table.remove(self.nameplates, i)
			break
		end
	end
end

function NameplateRenderer:Draw()
	for i,v in ipairs(self.nameplates) do
		v:Draw()
	end
end

return NameplateRenderer