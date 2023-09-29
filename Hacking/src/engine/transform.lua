Transform = Class(function(self, x, y, sx, sy, parent)
	self.x = x or 0
	self.y = y or 0

	self.sx = sx or 1
	self.sy = sy or 1

	self.r = 0

	self.parent = parent
end)

--Does NOT include local scale
function Transform:GetCumulativeScale()
	if not self.parent then return 1, 1 end
	local psx, psy = self.parent:GetCumulativeScale()
	return psx*self.parent.sx, psy*self.parent.sy
end

function Transform:GetAbsoluteScale()
	local sx, sy = self:GetCumulativeScale()
	return sx*self.sx, sy*self.sy
end

function Transform:GetAbsolutePosition()
	if not self.parent then return self.x, self.y end
	local px, py = self.parent:GetAbsolutePosition()
	local psx, psy = self:GetCumulativeScale()
	local x = px+self.x*psx
	local y = py+self.y*psx
	return x,y
end

function Transform:GetCumulativeRotation()
	if not self.parent then return 0 end
	local pr = self.parent:GetCumulativeRotation()
	return pr+self.parent.r
end

function Transform:GetAbsoluteRotation()
	local r = self:GetCumulativeRotation()
	return r+self.r
end

function Transform:SetScale(sx, sy)
	self.sx = sx or 1
	self.sy = sy or self.sx
end

function Transform:GetScale()
	return self.sx, self.sy
end

function Transform:SetPosition(x, y)
	self.x = x or 0
	self.y = y or 0
end

function Transform:SetRotation(r)
	self.r = r % 360
end

function Transform:GetRotation()
	return self.r
end

--Local Position
function Transform:GetPosition()
	return self.x, self.y
end