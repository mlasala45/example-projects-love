local Node = require("game/prefabs/node")

local NetMap = Class(Prefab, function(self, x, y)
	self.base._ctor(self, "netmap", x, y)

	self.nodes = {}
	self.links = {}
end)

function NetMap:AddNode(data)
	local node = Node(data.x * TUNING.NODE_DEFAULT_SIZE, data.y * TUNING.NODE_DEFAULT_SIZE, self, data)
	table.insert(self.nodes, node)

	if data.parent and table.contains(self.nodes, data.parent) then
		table.insert(self.links, { a=data.parent, b=node })
	end

	return node
end

function NetMap:Draw()
	--local cornerX = (MID_X - (MID_X - self.rx) * TheCamera.sx) - TheCamera.x * TheCamera.sx
	--local cornerY = (MID_Y - (MID_Y - self.ry) * TheCamera.sy) + TheCamera.y * TheCamera.sy

	love.graphics.setColor(COLORS.WHITE)
	love.graphics.circle("line", 0, 0, 30)

	for _,v in ipairs(self.links) do
		love.graphics.line(
			v.a.Transform.x, v.a.Transform.y,
			v.b.Transform.x, v.b.Transform.y)
	end

	--Final Color Reset
	love.graphics.setColor(COLORS.WHITE)
end

return NetMap