local ScrollArea = Class(Widget, function(self, x, y, w, h, city)
	self.base._ctor(self, "ScrollArea", x, y)
	
	self.w = w
	self.h = h

	self.is_ui = true --clumsy
end)

--Don't nest these
--X,Y is top left, not center
function ScrollArea:Draw()

	print("ScrollArea "..tostring(self.w)..", "..tostring(self.h))
	local x, y = self.Transform:GetAbsolutePosition()

	local mode,i = love.graphics.getStencilTest()
	if mode == "always" then i = -1 end

	local function stencilfn()
		love.graphics.rectangle("fill",x, y, self.w, self.h)
	end

	love.graphics.stencil(stencilfn, "increment")

	--love.graphics.setStencilTest("greater", i+1)

	self.base.Draw(self)

	if i == -1 then
		love.graphics.setStencilTest("always", 0)
	else
		--love.graphics.setStencilTest("greater", i)
	end
end

function ScrollArea:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	local x, y = self.Transform:GetAbsolutePosition()
	return geo.inbounds(mx,my,x,y,x+self.w,y+self.h,self.Transform:GetRotation())
end

function ScrollArea:GetBounds()
	local x, y = self.Transform:GetAbsolutePosition()
	print(tostring(x).." "..tostring(y).." "..tostring(x+self.w).." "..tostring(y+self.h))
	return x,y,x+self.w,y+self.h
end

return ScrollArea