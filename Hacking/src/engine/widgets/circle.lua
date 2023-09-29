Circle = Class(Widget, function(self, x, y, radius, thick, color1, color2)
	self.base._ctor(self, "Circle", x, y)

	self.x = x
	self.y = y
	self.w = radius*2
	self.h = self.w
	self.radius = radius
	self.thick = thick
	self.color1 = color1
	self.color2 = color2
end)

function Circle:Draw()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	
	geo.drawBorderedCircle(x, y, self.radius, self.thick, self.color1, self.color2)

	Widget.Draw(self)
end

function Circle:DrawBounds(color)
	if self.nobounds then return end

	local old = tostring(color)
	color = color or DEBUG_COLOR

	local minX, minY, maxX, maxY = self:GetBounds()
	love.graphics.setColor(color)
	love.graphics.rectangle("line",minX,minY,maxX-minX,maxY-minY)
	love.graphics.setColor(COLORS.WHITE)
end

function Circle:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	if self.nobounds then return false end

	local minX, minY, maxX, maxY = self:GetBounds()
	return geo.inbounds(mx,my,minX,minY,maxX,maxY,0)
end

function Circle:GetBounds()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	local w = self:GetWidth()/2
	local h = self:GetHeight()/2
	return x-w,y-h,x+w,y+h
end

function Circle:GetWidth()
	local sx,sy = self.Transform:GetAbsoluteScale()
	return self.w * sx
end

function Circle:GetHeight()
	local sx,sy = self.Transform:GetAbsoluteScale()
	return self.h * sy
end