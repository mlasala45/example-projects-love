local Camera = Class(Prefab, function(self, x, y)
	self.base._ctor(self, "camera", x, y)

	self.vx = 0
	self.vy = 0

	self.sx = 1
	self.sy = 1

	self.acc = -1
end)

function Camera:Update(dt)
	self.vx = 0
	self.vy = 0
	if love.keyboard.isDown("up") then self.vy = 1 end
	if love.keyboard.isDown("down") then self.vy = -1 end
	if love.keyboard.isDown("left") then self.vx = -1 end
	if love.keyboard.isDown("right") then self.vx = 1 end

	self.vx = self.vx * TUNING.CAMERA_MOVE_SPEED
	self.vy = self.vy * TUNING.CAMERA_MOVE_SPEED

	local x = self.Transform.x
	local y = self.Transform.y

	x = x + self.vx * dt
	y = y + self.vy * dt

	if not self.no_clamps then
		x = math.clamp(x, self.minX, self.maxX)
		y = math.clamp(y, self.minY, self.maxY)
	end

	print(x.." "..y)

	self.Transform.x = x
	self.Transform.y = y
end

function Camera:Center(x, y, overtime)
	if overtime == nil then overtime = TUNING.DEFAULT_CAMERA_PAN_TIME end
	
	self.Transform.x, self.Transform.y = x, -y
end

return Camera