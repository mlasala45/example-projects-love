RoundedBox = Class(Box, function(self, x, y, width, height, thick, fillColor, borderColor, radius)
	Box._ctor(self, x, y, width, height, thick, borderColor, fillColor)
	self.name = "RoundedBox"

	self.radius = radius or DEFAULT_UI_ROUNDNESS

	self.outline = true
end)

function RoundedBox:Draw()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	local w,h = self:GetWidth(), self:GetHeight()

	if self.thick > 0 then
		geo.drawRoundedBorderedRectangle(x, y, w, h, self.radius, self.thick, self.fillColor, self.borderColor)
	else
		geo.drawRoundedRectangle(x, y, w, h, self.radius, self.fillColor)
	end

	--[[if self.outline then
		geo.drawRoundedBorderedRectangle(x, y, w, h, self.radius, 5, COLORS.CLEAR, COLORS.RED)
	end]]

	Widget.Draw(self)
end