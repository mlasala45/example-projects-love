local min_reticle_scale = 1
local max_reticle_scale = 1.1
local hover_anim_time = 0.125

local Node = Class(Prefab, function(self, x, y, map, data)
	self.base._ctor(self, "node", x, y)
	self.Transform.parent = map.Transform

	self.map = map

	self.name = data.name or STRINGS.DEFAULT_NODE_NAME
	self.color = data.color or COLORS.WHITE

	self.hover_acc = 0

	local size = TUNING.NODE_DEFAULT_SIZE
	local ax, ay = self.Transform:GetAbsolutePosition()
	self.hitbox = PrefabHitBoxParent:AddChild(Box(ax - size, ay - size, size * 2, size * 2, false))
	self.hitbox.hitbox_owner = self

	self.hitbox.tooltip = { txt=data.name, w=90, no_box=true, oy=-15 }

	--self.color1 = self.faction.color1 or COLORS.YELLOW
	--self.color2 = self.faction.color2 or COLORS.PURPLE
end)

function Node:Update(dt)
	if self.is_focus then
		self.hover_acc = math.min(hover_anim_time, self.hover_acc + dt)
		--if self.hover_acc > 1 then self.hover_acc = self.hover_acc - 1 end
	elseif self.hover_acc > 0 then
		self.hover_acc = math.max(0, self.hover_acc - dt)
	end
end

local size = TUNING.NODE_DEFAULT_SIZE

local verts = {
	0, size,
	size, 0,
	0, -size,
	-size, 0
}

local function draw_gap_line(x1, y1, x2, y2, ratio)
	love.graphics.line(x1, y1, math.lerp(x1, x2, ratio * 0.5), math.lerp(y1, y2, ratio * 0.5))
	love.graphics.line(x2, y2, math.lerp(x2, x1, ratio * 0.5), math.lerp(y2, y1, ratio * 0.5))
end

local function draw_reticle(ratio)
	draw_gap_line(verts[1], verts[2], verts[3], verts[4], ratio)
	draw_gap_line(verts[3], verts[4], verts[5], verts[6], ratio)
	draw_gap_line(verts[5], verts[6], verts[7], verts[8], ratio)
	draw_gap_line(verts[7], verts[8], verts[1], verts[2], ratio)
end

function Node:Draw()
	local scale = 0.75--math.lerp(0.58, 0.62, self.hover_acc)
	print(scale)
	
	love.graphics.setLineWidth(2)
	love.graphics.push()
	love.graphics.scale(math.lerp(min_reticle_scale, max_reticle_scale, self.hover_acc / hover_anim_time))

	love.graphics.setColor(COLORS.BLACK)
	love.graphics.polygon("fill", verts)
	
	love.graphics.setColor(self.color)
	draw_reticle(0.8)

	love.graphics.pop()

	love.graphics.push()
	love.graphics.scale(scale)
	love.graphics.polygon("line", verts)
	love.graphics.pop()
end

function Node:NextTurn()
	--
end

function Node:OnKeypress(key)
	--
end

return Node