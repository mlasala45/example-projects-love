local MenuList = Class(Widget, function(self, x, y, w, h, seperation, invert)
	self.base._ctor(self, "MenuList", x, y)
	
	self.w = w
	self.h = h

	self.items = {}
	--self.bg = self:AddChild(Box(0, 0, self.w, self.h, 40, COLORS.RED, COLORS.BLUE))
	--self.bg.name = "Box (MenuList)"

	self.seperation = seperation
	self.invert = invert
end)

function MenuList:AddItem(item)
	table.insert(self.items, item)
	self:AddChild(item)
	item.i = #self.items

	self:RecalcPositions()
end

function MenuList:RemoveItem(item)
	table.remove(self.items, table.find(self.items, item))
	item:Remove()
	item:Destroy()

	self:RecalcPositions()
end

function MenuList:Clear()
	for i,v in ipairs(self.items) do
		v:Remove()
		v:Destroy()
	end
	self.items = {}
end

function MenuList:RecalcPositions()
	if self.invert then
		local h = self.h
		if self.centered and #self.items > 0 then h = h + self.items[1]:GetHeight()/2 end
		for i,v in ipairs(self.items) do
			h = h - v:GetHeight()
			v.Transform:SetPosition(0, h)
			h = h - self.seperation
		end
	else
		local h = 0
		if self.centered and #self.items > 0 then h = h + self.items[1]:GetHeight()/2 end
		for i,v in ipairs(self.items) do
			v.Transform:SetPosition(0, h)
			h = h + v:GetHeight() + self.seperation
		end
	end
end

function MenuList:Draw()
	local x, y = self.Transform:GetAbsolutePosition()
	print("MenuList "..tostring(x)..", "..tostring(y).." / "..tostring(self.w)..", "..tostring(self.h))

	self.base.Draw(self)
end

function MenuList:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	local x, y = self.Transform:GetAbsolutePosition()
	return geo.inbounds(mx,my,x,y,x+self.w,y+self.h,self.Transform:GetRotation())
end

function MenuList:GetBounds()
	local x, y = self.Transform:GetAbsolutePosition()
	return x,y,x+self.w,y+self.h
end

return MenuList