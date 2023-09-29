Box = Class(Widget, function(self, x, y, width, height, thick, borderColor, fillColor)
	Widget._ctor(self, "Box", x, y)

	self.x = x
	self.y = y
	self.w = width
	self.h = height
	self.thick = thick
	
	self.borderColor = borderColor
	self.fillColor = fillColor
end)

function Box:Draw()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	
	if self.fillColor then
		if self.borderColor then
			geo.drawBorderedRectangle(x, y, self:GetWidth(), self:GetHeight(), self.thick, self.borderColor, self.fillColor)
		else
			love.graphics.setColor(self.fillColor)
			love.graphics.rectangle("fill", x, y, self:GetWidth(), self:GetHeight())
		end
	elseif self.borderColor then
		geo.drawRectangleBorder(x, y, self:GetWidth(), self:GetHeight(), self.thick, self.borderColor)
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