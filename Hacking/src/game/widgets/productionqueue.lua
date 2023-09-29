local width = 200*1.2
local height = 150*1.2
local thick = 5*1.2

local button_offset = 68
local button_radius = 85*1.2 / 2
local button_thick = thick
local button_scale = 1.8

local title_x = 5
local title_y = 5
local title_w = 200
local title_h = 40

local nav_spacing = 40
local nav_select_color = COLORS.CYAN
local nav_x = 15
--local nav_y = 0
local nav_w = 120
local nav_h = 25
local nav_thick = 3

local seperation = 0

local selectcolor = COLORS.CYAN

local ScrollArea = require("game/widgets/scrollarea")
local MenuList = require("game/widgets/menulist")
local ProductionListElement = require("game/widgets/productionlistelement")

local ProductionQueue = Class(Widget, function(self, x, y, w, h, color1, color2)
	self.base._ctor(self, "ProductionQueue", x, y)
	
	self.color1 = color1
	self.color2 = color2

	self.w = w
	self.h = h

	self.bg = self:AddChild(Box(0, 0, self.w, self.h, thick, self.color1, self.color2))
	self.bg.name = "Box (ProductionQueue)"

	local iw, ih = w-(thick*2),h-(thick*2)
	ih = ih - nav_spacing

	local y_acc = thick

	self.title = self:AddChild(Text(thick+title_x,y_acc+title_y,STRINGS.UI.PRODUCTION.TITLE_BUILDQUEUE, nil, false, FONTS.DEFAULT_LARGE, title_w))
	y_acc = y_acc + title_h

	self.scrollarea = self:AddChild(ScrollArea(thick,y_acc,iw,ih))

	self.buildoptions = self.scrollarea:AddChild(MenuList(0, 0, iw, ih, seperation))
	self.buildqueue   = self.scrollarea:AddChild(MenuList(0, 0, iw, ih, seperation))
	self.buildoptions.name = "OPTIONS"
	self.buildqueue.name = "QUEUE"

	self.buildoptions:Hide()

	self.show_options = false

	local nav_drawfn = function(inst)
		local color
		local mx,my = love.mouse:getPosition()
		if inst:IsFocused(mx, my) then
			color = nav_select_color
		else
			color = self.color1
		end
		local x,y = inst.Transform:GetAbsolutePosition()
		local sx,sy = inst.Transform:GetAbsoluteScale()
		geo.drawBorderedRectangle(x,y,inst.w*sx,inst.h*sy,nav_thick, color, self.color2)
	end

	local nav_clickfn = function(inst)
		self.disabled = true
		self.show_options = not self.show_options
		if self.show_options then
			self.buildoptions:Show()
			self.buildqueue:Hide()
			self.title:SetText(STRINGS.UI.PRODUCTION.TITLE_BUILDOPTIONS)
			self.nav_txt:SetText(STRINGS.UI.PRODUCTION.NAV_BACK)
		else
			self.buildoptions:Hide()
			self.buildqueue:Show()
			self.title:SetText(STRINGS.UI.PRODUCTION.TITLE_BUILDQUEUE)
			self.nav_txt:SetText(STRINGS.UI.PRODUCTION.NAV_CHOOSE)
		end
	end

	self.nav_button = self:AddChild(Button(nav_x, ih+thick+(nav_spacing/2)-(nav_h/2), nav_w, nav_h, false, COLORS.WHITE, nav_drawfn, nav_clickfn))
	self.nav_txt =  self.nav_button:AddChild(Text(nav_w/2, nav_h/2, STRINGS.UI.PRODUCTION.NAV_CHOOSE, nil, true))

	self.is_ui = true --clumsy
	for i,v in ipairs(self.children) do
		v.is_ui = true
	end

	--self.nextturnbutton = self:AddChild(Button(button_offset, height/2, button_radius*2, button_radius*2, COLORS.WHITE, ntb_drawfn, ntb_clickfn))
end)

function ProductionQueue:OnListElementClick(buildable, i, parent)
	--p_print("OnListElementClick "..parent.." "..tostring(i).."("..buildable.name..", "..tostring(self.disabled)..")")
	if self.disabled then return end
	if self.show_options then
		self.city:StartProducing(buildable)
		self.nav_button.clickfn()
	else
		self.city:StopProducing(i)
	end
	self.disabled = true
end

function ProductionQueue:RecalcBuildOptions()
	if not self.buildoptions then return end --DEBUG

	self.buildoptions:Clear()
	
	local options = self.city:GetBuildOptions()
	for i,v in ipairs(options) do
		if not ((not v.repeatable) and table.contains(self.city.production_queue, v)) then
			local item = ProductionListElement(v, self, self.color1, self.color2, selectcolor)
			self.buildoptions:AddItem(item)
		end
	end
end

function ProductionQueue:RecalcBuildQueue()
	if not self.buildqueue then return end --DEBUG

	self.buildqueue:Clear()
	
	local elements = self.city.production_queue
	for i,v in ipairs(elements) do
		local item = ProductionListElement(v, self, self.color1, self.color2, selectcolor)
		self.buildqueue:AddItem(item)
	end
end

function ProductionQueue:LoadCity(city)
	self.city = city

	--self.color1 = city.color1
	--self.color2 = city.color2

	self:RecalcBuildOptions()
	self:RecalcBuildQueue()
end

function ProductionQueue:Update(dt)
	if self.disabled then
		self.disabled = false
	end
	Widget.Update(self,dt)
end

function ProductionQueue:Draw()
	--local x, y = self.Transform:GetAbsolutePosition()

	print("ProductionQueue "..tostring(self.w)..", "..tostring(self.h))
	Widget.Draw(self)
end

function ProductionQueue:SetTurn(turn)
	self.turncount.text = "Turn "..tostring(turn) or "ERROR"
	self.turncount:Recalc()
end

function ProductionQueue:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	local x, y = self.Transform:GetAbsolutePosition()
	return geo.inbounds(mx,my,x,y,x+self.w,y+self.h,self.Transform:GetRotation())
end

function ProductionQueue:GetBounds()
	local x, y = self.Transform:GetAbsolutePosition()
	return x,y,x+self.w,y+self.h
end

return ProductionQueue