Box = Class(Widget, function(self, x, y, width, height, thick, color1, color2)
	self.base._ctor(self, "Box", x, y)

	self.x = x
	self.y = y
	self.w = width
	self.h = height

	if thick == false then
		self.no_draw = true
	else
		self.thick = thick
		self.color1 = color1
		self.color2 = color2
	end
end)

function Box:Draw()
	if not self.no_draw then
		local x,y = self.Transform:GetAbsolutePosition()
		local sx,sy = self.Transform:GetAbsoluteScale()
		
		geo.drawBorderedRectangle(x, y, self:GetWidth(), self:GetHeight(), self.thick, self.color1, self.color2)
	end

	Widget.Draw(self)
end

function Box:DrawBounds(color)
	if self.nobounds then return end

	local old = tostring(color)
	color = color or DEBUG_COLOR

	local minX, minY, maxX, maxY = self:GetBounds()
	love.graphics.setColor(color)
	love.graphics.rectangle("line",minX,minY,maxX-minX,maxY-minY)
	love.graphics.setColor(COLORS.WHITE)
end

function Box:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	if self.nobounds then return false end

	local minX, minY, maxX, maxY = self:GetBounds()
	return geo.inbounds(mx,my,minX,minY,maxX,maxY,0)
end

function Box:GetBounds()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	return x,y,x+self:GetWidth(),y+self:GetHeight()
end

function Box:GetWidth()
	local sx,sy = self.Transform:GetAbsoluteScale()
	return self.w * sx
end

function Box:GetHeight()
	local sx,sy = self.Transform:GetAbsoluteScale()
	return self.h * sy
end