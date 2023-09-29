local Camera = Class(Prefab, function(self, x, y)
	self.base._ctor(self, x, y)

	self.vx = 0
	self.vy = 0

	self.sx = 1.5
	self.sy = 1.5

	self.acc = -1
end)

local function lerp_position(self)
	--
end

function Camera:Update(dt)
	if not self.locked then
		self.vx = 0
		self.vy = 0
		if love.keyboard.isDown("up") then self.vy = 1 end
		if love.keyboard.isDown("down") then self.vy = -1 end
		if love.keyboard.isDown("left") then self.vx = -1 end
		if love.keyboard.isDown("right") then self.vx = 1 end

		self.vx = self.vx * TUNING.CAMERA_MOVE_SPEED
		self.vy = self.vy * TUNING.CAMERA_MOVE_SPEED

		if self.lerp_data then
			local data = self.lerp_data
			data.dest_x = math.clamp(data.dest_x + self.vx * dt, self.minX, self.maxX)
			data.dest_y = math.clamp(data.dest_y + self.vy * dt, self.minY, self.maxY)

			data.acc = math.min(data.acc + dt, data.overtime)
			local t
			if data.overtime == 0 then t = 1 else t = data.acc / data.overtime end
			if t == 1 then self.lerp_data = nil end
			self.x = math.lerp(data.src_x, data.dest_x, t)
			self.y = math.lerp(data.src_y, data.dest_y, t)	
		else
			self.x = math.clamp(self.x + self.vx * dt, self.minX, self.maxX)
			self.y = math.clamp(self.y + self.vy * dt, self.minY, self.maxY)
		end
	end
	print(self.x.." "..self.y)
end

--Passed cartesian coords
function Camera:Center(x, y, overtime)
	if overtime == nil then overtime = TUNING.DEFAULT_CAMERA_PAN_TIME end

	local wx, wy = CartesianToWorld(x, y) --TODO: Add Transforms to Prefabs
	camX = (TheGrid.rx + wx - MID_X + HEX_RADIUS_SHORT)-- * self.sx
	camY = (TheGrid.ry + wy - MID_Y - HEX_RADIUS)-- * self.sy

	self.lerp_data = {
		dest_x = camX,
		dest_y = -camY,
		src_x = self.x,
		src_y = self.y,
		overtime = overtime,
		acc = 0
	}
	lerp_position(self)
	--[[local cornerX = MID_X + TheGrid.rx*self.sx
	local cornerY = MID_Y + TheGrid.ry*self.sy
	local camX = MID_X - (cornerX + wx*self.sx)
	local camY = MID_Y - (cornerY + wy*self.sy)]]
	--camX = camX - (TheGrid.w*HEX_RADIUS_SHORT)
	--camY = camY - (TheGrid.h*HEX_RADIUS)
	self.x, self.y = camX, -camY
end

return Camera