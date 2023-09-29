local FloatingTextRenderer = Class(Prefab, function(self, map)
	self.base._ctor(self, 0, 0)

	self.map = map

	self.layer = LAYERS.TEXT

	self.slaves = {}
	self.lifetimes = {}
	self.positions = {}
end)

function FloatingTextRenderer:AddObj(obj)
	local wx, wy = self.map:GetHexCenter(0, 0)
	obj.color = table.copy(obj.color)
	obj.Transform:SetPosition(obj.Transform.x - wx, obj.Transform.y - wy)
	table.insert(self.slaves, obj)
	self.lifetimes[obj] = 0
	self.positions[obj] = { x=obj.Transform.x, y=obj.Transform.y }
end

function FloatingTextRenderer:RemoveObj(obj)
	for i,v in ipairs(self.slaves) do
		if v == obj then
			table.remove(self.slaves, i)
			break
		end
	end
end

function FloatingTextRenderer:Update(dt)
	local newSlaves = {}
	for i,v in ipairs(self.slaves) do
		self.lifetimes[v] = self.lifetimes[v] + dt
		local t = self.lifetimes[v] / TUNING.UI.FLOATER_DURATION
		v.color[4] = math.lerp(1, 0, t)
		if v.color[4] > 0 then
			local wx, wy = self.map:GetHexCenter(0, 0)
			v.Transform:SetPosition(self.positions[v].x + wx, self.positions[v].y + wy + math.lerp(0, TUNING.UI.FLOATER_OFFSET_Y, t))
			table.insert(newSlaves, v)
		else
			self.lifetimes[v] = nil
			self.positions[v] = nil
		end
	end
	self.slaves = newSlaves
end

function FloatingTextRenderer:Draw()
	for i,v in ipairs(self.slaves) do
		v:Draw()
	end
end

return FloatingTextRenderer