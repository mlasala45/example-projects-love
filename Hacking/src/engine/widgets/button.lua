Button = Class(Widget, function(self, x, y, w, h, centered, color, drawfn, clickfn)
	self.base._ctor(self, "Button", x, y)

	self.color = color or COLORS.WHITE

	self.w = w
	self.h = h

	self.centered = centered

	self.is_ui = true --clumsy

	self.drawfn = drawfn
	self.clickfn = clickfn
	
	self.click_handle = InputHandler:AddClickHandler(function(x, y, button)
		if button == 1 and self:IsFocused(x, y) and self:IsVisible() then
			--assert(self.parent.parent.visible)
			self.clickfn(self)
		end
	end)
end)

function Button:Destroy()
	Widget.Destroy(self)

	InputHandler:RemoveClickHandler(self.click_handle)
end

function Button:Draw()
	love.graphics.setColor(self.color)
	if self.drawfn then self.drawfn(self) end
	love.graphics.setColor(COLORS.WHITE)

	Widget.Draw(self)
end

function Button:DrawBounds(color)
	local old = tostring(color)
	color = color or DEBUG_COLOR

	local minX, minY, maxX, maxY = self:GetBounds()
	love.graphics.setColor(color)
	love.graphics.rectangle("line",minX,minY,maxX-minX,maxY-minY)
	love.graphics.setColor(COLORS.WHITE)
end

function Button:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	local minX, minY, maxX, maxY = self:GetBounds()
	assert(minX~=nil and minY~=nil and maxX~=nil and maxY~=nil, tostring(minX).." "..tostring(minY).." "..tostring(maxX).." "..tostring(maxY))
	assert(mx~=nil and my~=nil, tostring(mx).." "..tostring(my))
	return mx >= minX and mx <= maxX and my >= minY and my <= maxY
end

function Button:GetBounds()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	local w,h = self.w, self.h
	w = w * sx
	h = h * sy
	if self.centered then
		return x-w/2,y-h/2,x+w/2,y+h/2
	else
		return x,y,x+w,y+h
	end
end