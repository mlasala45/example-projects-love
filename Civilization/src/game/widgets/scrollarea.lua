local ScrollArea = Class(Widget, function(self, x, y, w, h, city)
	self.base._ctor(self, "ScrollArea", x, y)
	
	self.w = w
	self.h = h

	self.is_ui = true --clumsy
	self.scroll_fn = self.HandleScrolling

	self.scroll_offset = 0

	self:Update()
end)

--TODO: Better?
function ScrollArea:AddChild(child)
	child.is_ui = true

	return Widget.AddChild(self, child)
end

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

	love.graphics.setStencilTest("greater", i+1)

	DBG_FLAG = true
	Widget.Draw(self)
	DBG_FLAG = nil

	love.graphics.stencil(stencilfn, "decrement")
	
	if i == -1 then
		love.graphics.setStencilTest()
	else
		love.graphics.setStencilTest(mode, i)
	end
end

function ScrollArea:Update()
		local minX, maxX, minY, maxY = self:GetBounds()
	for _,v in ipairs(self.children) do
		if v.GetBounds then v:UpdateBoundsCulling(minX, maxX, minY, maxY) end
	end
end

function ScrollArea:HandleScrolling(n)
	n = -n * TUNING.UI_SCROLL_SPEED
	local old = self.scroll_offset
	self.scroll_offset = math.clamp(self.scroll_offset + n, 0, self.scroll_max)

	for _,v in ipairs(self.children) do
		v.Transform:Translate(0, -(self.scroll_offset - old))
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