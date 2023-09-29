local thick = 5
local radius = HEX_RADIUS_SHORT - thick
local dot_radius = 5

local Pathfinder = Class(Prefab, function(self, x, y)
	self.base._ctor(self, x, y)

	self.pressed = false

	self.color = COLORS.YELLOW
end)

function Pathfinder:Update(dt)
	if TheGrid.selected and TheGrid.selected.unit and TheGameManager.player_num == TheGrid.selected.unit.owner then
		if love.mouse.isDown(2) then
			self.pressed = true
			local x,y = love.mouse.getPosition()
			x,y = TheGrid:WorldToLocal(x,y)
			local cx,cy = WorldToCartesian(x,y)
			self.target = TheGrid:GetCell(cx, cy)

			self.path = hex.path(TheGrid.selected, self.target)
		else
			if self.pressed then
				self.pressed = false
				if not self.target.unit then
					local unit = TheGrid.selected.unit
					unit:MoveAlong(self.path)
				end
				self.target = nil
			end
		end
	end
end

function Pathfinder:Draw(dt)
	if self.target then
		local unit = TheGrid.selected.unit
		local mp = unit.mp
		local turns = 0
		for i,v in ipairs(self.path) do
			local x,y = TheGrid:GetHexCenter(v.x, v.y)
			if mp > 0 then
				love.graphics.setColor(self.color)
				love.graphics.circle("fill",x,y,dot_radius)
				love.graphics.setLineWidth(1)
				love.graphics.setColor(COLORS.BLACK)
				love.graphics.circle("line",x,y,dot_radius)
			else
				turns = turns + 1
				love.graphics.print(tostring(turns),x-6,y-14)
			end
			mp = mp - 1
			if mp < 0 then mp = unit.max_mp end
		end
		local x,y = TheGrid:GetHexCenter(self.target.x, self.target.y)
		love.graphics.setColor(self.color)
		love.graphics.setLineWidth(thick)
		love.graphics.circle("line",x,y,radius)
		love.graphics.circle("fill",x,y,dot_radius)
		love.graphics.setLineWidth(1)
		love.graphics.setColor(COLORS.BLACK)
		love.graphics.circle("line",x,y,radius+thick/2)
		love.graphics.circle("line",x,y,radius-thick/2)
		love.graphics.circle("line",x,y,dot_radius)
		love.graphics.setColor(COLORS.WHITE)
	end
end

return Pathfinder