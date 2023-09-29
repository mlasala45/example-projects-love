Text = Class(Widget, function(self, x, y, text, color, centered, font, w)
	self.base._ctor(self, "Text", x, y)

	self.text = text or ""
	self.color = color or COLORS.WHITE
	self.font = font or FONTS.DEFAULT

	self.is_ui = true

	self.w = w or DEFAULT_TEXT_WIDTH
	p_print("DEBUUUUG")
	p_print(self.w)
	p_print(tostring(w))
	self.ww = self.w

	self.centered = centered
	if self.centered==nil then self.centered = true end

	self.drawable = love.graphics.newText(self.font, self.text)

	self:Recalc()
	p_print(self.w)
	p_print(self.ww)	
end)

function Text:SetText(text)
	self.text = text
	self:Recalc()
end

function Text:Recalc()
	if self.drawable then self.drawable:clear() end

	self.drawable:setf(self.text, self.ww, "left")
	self.w = self.drawable:getWidth()
	self.drawable:setf(self.text, self.w, self.centered and "center" or "left")
end

function Text:Draw()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx, sy = self.Transform:GetAbsoluteScale()
	if self.centered then
		local w,h = self.drawable:getDimensions()
		x = x - w*sx/2
		y = y - h*sy/2
	end
	love.graphics.setColor(self.color)
	love.graphics.draw(self.drawable, x, y, 0, sx, sy)
	love.graphics.setColor(COLORS.WHITE)

	Widget.Draw(self)
end

function Text:DrawBounds(color)
	local old = tostring(color)
	color = color or DEBUG_COLOR

	local minX, minY, maxX, maxY = self:GetBounds()
	love.graphics.setColor(color)
	love.graphics.rectangle("line",minX,minY,maxX-minX,maxY-minY)
	love.graphics.setColor(COLORS.WHITE)
end

function Text:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	local minX, minY, maxX, maxY = self:GetBounds()
	return mx >= minX and mx <= maxX and my >= minY and my <= maxY
end

function Text:GetBounds()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	local w,h = self.drawable:getDimensions()
	w = w * sx
	h = h * sy
	return x-w/2,y-h/2,x+w/2,y+h/2
end

function Text:GetWidth()
	local sx,sy = self.Transform:GetAbsoluteScale()
	return self.drawable:getWidth() * sx
end

function Text:GetHeight()
	local sx,sy = self.Transform:GetAbsoluteScale()
	return self.drawable:getHeight() * sy
end

--TODO: Alignment; Width/Height sensing