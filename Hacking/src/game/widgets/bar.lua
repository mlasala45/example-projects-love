local Bar = Class(Widget, function(self, x, y, w, h, thick, current, max, color1, color2, color3)
	self.base._ctor(self, "Bar", x, y)

	self.w = w
	self.h = h
	self.thick = thick

	self.current = current
	self.max = max

	self.color1 = color1
	self.color2 = color2
	self.color3 = color3
end)

function Bar:SetValues(current, max)
	self.current = current
	self.max = max
end

--Currently draws with piviot as bottom-left
function Bar:Draw()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx, sy = self.Transform:GetAbsoluteScale()
	local color3 = self.color3
	if type(color3) == "function" then color3 = color3(self.current, self.max) end
	--geo.drawBorderedRectangle(x, y, self.w * sx, self.h * sy, self.thick, self.color1, self.color2)
	love.graphics.setColor(color3)
	love.graphics.rectangle("fill", x+(self.thick*sx), y+(self.thick*sy), (self.w-self.thick*2) * sx, (self.h-self.thick*2) * sy)
	love.graphics.setColor(COLORS.BLACK)
	love.graphics.rectangle("line", x, y, self.w * sx, self.h * sy)
	love.graphics.setColor(COLORS.WHITE)

	Widget.Draw(self)
end

return Bar