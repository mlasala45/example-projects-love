local Bar = Class(Widget, function(self, x, y, w, h, current, max, color1, color2, border)
	self.base._ctor(self, "Bar", x, y)

	self.w = w
	self.h = h

	self.current = current
	self.max = max

	self.color1 = color1
	self.color2 = color2

	self.border = border
end)

function Bar:SetValues(current, max)
	self.current = current
	self.max = max
end

--Currently draws with piviot as bottom-left
function Bar:Draw()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx, sy = self.Transform:GetAbsoluteScale()
	local color2 = self.color2
	if type(color2) == "function" then color2 = color2(self.current, self.max) end
	--geo.drawBorderedRectangle(x, y, self.w * sx, self.h * sy, self.thick, self.color1, self.color2)
	love.graphics.setColor(self.color1)
	love.graphics.rectangle("fill", x, y, self.w * sx, self.h * sy)
	love.graphics.setColor(color2)
	local true_w = self.w * sy
	local true_h = self.h * sy
	local ratio = self.current / self.max
	if self.side then
		love.graphics.rectangle("fill", x, y, true_w * ratio, true_h)
	else
		love.graphics.rectangle("fill", x, y + (true_h*(1-ratio)), true_w, true_h * ratio)
	end
	if self.border then
		love.graphics.setColor(COLORS.BLACK)
		love.graphics.rectangle("line", x, y, self.w * sx, self.h * sy)
	end
	love.graphics.setColor(COLORS.WHITE)

	Widget.Draw(self)
end

return Bar