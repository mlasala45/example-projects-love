Image = Class(Widget, function(self, x, y, atlas, image)
	self.base._ctor(self, "Image", x, y)

	self.atlas = atlas
	self.image = image

	self.r = 255
	self.g = 255
	self.b = 255

	--Do Not Interact
	self.dni = false
end)

function Image:Draw()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	--if self.parent and self.parent.name=="UnitInfoBox" then print(sx.." "..sy) end
	local r = self.Transform:GetAbsoluteRotation()
	love.graphics.setColor(self.r, self.g, self.b, self.alpha)
	Draw(self.atlas, self.image, x, y, r, sx/QUALITY_SCALE, sy/QUALITY_SCALE)
	love.graphics.setColor(COLORS.WHITE[1], COLORS.WHITE[2], COLORS.WHITE[3], COLORS.WHITE[4])

	Widget.Draw(self)
end

function Image:DrawBounds(color)
	local old = tostring(color)
	color = color or DEBUG_COLOR

	local minX, minY, maxX, maxY = self:GetBounds()
	love.graphics.setColor(color)
	love.graphics.rectangle("line",minX,minY,maxX-minX,maxY-minY)
	love.graphics.setColor(COLORS.WHITE)
end

function Image:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	if self.dni then return false end
	
	local minX, minY, maxX, maxY = self:GetBounds()
	return geo.inbounds(mx,my,minX,minY,maxX,maxY,self.Transform:GetRotation())
end

function Image:GetBounds()
	local x,y = self.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	assert(ASSETS.QUADS[string.upper(self.atlas)], "Attempt to call Image:GetBounds on faulty atlas: "..tostring(self.atlas))
	local quad = ASSETS.QUADS[string.upper(self.atlas)][string.upper(self.image)]
	if not quad then return x,y,x,y end
	local _,_,w,h = quad:getViewport()
	w = w * sx/QUALITY_SCALE
	h = h * sy/QUALITY_SCALE
	return x-w/2,y-h/2,x+w/2,y+h/2
end

function Image:GetWidth()
	local sx,sy = self.Transform:GetAbsoluteScale()
	assert(ASSETS.QUADS[string.upper(self.atlas)], "Attempt to call Image:GetWidth on faulty atlas: "..tostring(self.atlas))
	local quad = ASSETS.QUADS[string.upper(self.atlas)][string.upper(self.image)]
	if not quad then return 0 end
	local _,_,w,h = quad:getViewport()
	return w* sx/QUALITY_SCALE
end

function Image:GetHeight()
	local sx,sy = self.Transform:GetAbsoluteScale()
	assert(ASSETS.QUADS[string.upper(self.atlas)], "Attempt to call Image:GetHeight on faulty atlas: "..tostring(self.atlas))
	local quad = ASSETS.QUADS[string.upper(self.atlas)][string.upper(self.image)]
	if not quad then return 0 end
	local _,_,w,h = quad:getViewport()
	return h * sy/QUALITY_SCALE
end