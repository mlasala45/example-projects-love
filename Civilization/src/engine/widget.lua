Widget = Class(function(self, name, x, y)
	self.name = name

	self.parent = nil
	self.children = {}

	self.components = {}

	self.Transform = Transform(x, y)

	self.alpha = 255

	self.visible = true
	self.in_bounds = true
end)

function Widget:AddChild(child)
	table.insert(self.children, child)
	child.parent = self
	child.Transform.parent = self.Transform
	return child
end

function Widget:AddComponent(type)
	local ctor = require("engine/components/"..type)
	local comp = ctor(self)
	self.components[type] = comp
end

function Widget:Remove()
	for i,v in ipairs(self.parent.children) do
		if v == self then
			table.remove(self.parent.children, i)
			break
		end
	end
	self.parent = nil
	Transform.parent = nil
end

function Widget:Destroy()
	for i,v in ipairs(self.children) do
		if v.Destroy then v:Destroy() end
	end
end

function Widget:Update(dt)
	for k,v in pairs(self.components) do
		if v.Update then v:Update(dt) end
	end
	
	for i,v in ipairs(self.children) do
		v:Update(dt)
	end
end

function Widget:Draw()
	if self.visible and self.in_bounds then
		for i,v in ipairs(self.children) do
			if v.visible then
				v:Draw()
				love.graphics.setColor(COLORS.WHITE)
			end
		end

		if DRAW_BOUNDS and self.GetBounds then
			local mode,i = love.graphics.getStencilTest()
			if mode == "always" then i = -1 end

			love.graphics.setStencilTest()
			local color
			local mx,my = love.mouse:getPosition()
			if self:IsFocused(mx,my) then color = COLORS.GREEN end

			self:DrawBounds(color)

			if i == -1 then
				love.graphics.setStencilTest()
			else
				love.graphics.setStencilTest(mode, i)
			end
		end
	end
end

function Widget:GetWidth()
	if self.GetBounds then
		local x1,_,x2,_ = self:GetBounds()
		return math.abs(x2 - x1) * self.Transform.sx
	end
	if self.w then return self.w * self.Transform.sx end
	if self.width then return self.width * self.Transform.sx end
	return 0
end

function Widget:GetHeight()
	if self.GetBounds then
		local _,y1,_,y2 = self:GetBounds()
		return math.abs(y2 - y1) * self.Transform.sy
	end
	if self.h then return self.h * self.Transform.sy end
	if self.height then return self.height * self.Transform.sy end
	return 0
end

function Widget:DrawBounds(color)
	color = color or DEBUG_COLOR

	local minX, minY, maxX, maxY = self:GetBounds()
	love.graphics.setColor(color)
	love.graphics.rectangle("line",minX,minY,maxX-minX,maxY-minY)
	love.graphics.setColor(COLORS.WHITE)
end

--Will crash if a widget doesn't have GetBounds implemented
function Widget:UpdateBoundsCulling(minX2, minY2, maxX2, maxY2)
	local minX, minY, maxX, maxY = self:GetBounds()
	if (minX < minX2 and maxX < minX2) or (minX > maxX2 and maxX > maxX2) or
		(minY < minY2 and maxY < minY2) or (minY > maxY2 and maxY > maxY2) then
		self.in_bounds = false
	else
		self.in_bounds = true
	end

	for _,v in ipairs(self.children) do
		if v.GetBounds then
			v:UpdateBoundsCulling(minX2, minY2, maxX2, maxY2)
		end
	end
end

--TODO: Priority Queue for children!!!
--Or run it backwards?
--NOTE: Does not check for parent visibility
function Widget:IsFocused(x, y)
	if self.visible and self.in_bounds then
		for i=0,#self.children-1 do
			local v = self.children[#self.children-i]
			if v.visible then
				if v:IsFocused(x, y) then return true end
			end
		end
	end
end

function Widget:GetFocused(x, y)
	if self:IsFocused(x, y) then
		for i=0,#self.children-1 do
			local v = self.children[#self.children-i]
			if v.visible then
				if v:IsFocused(x, y) then return v:GetFocused(x, y) end
			end
		end
		return self
	end
end

function Widget:Hide()
	self.visible = false
end

function Widget:Show()
	self.visible = true
end

function Widget:IsVisible()
	local inst = self
	while inst.parent do
		if not inst.visible then return false end
		if not inst.in_bounds then return false end
		inst = inst.parent
	end
	return true
end