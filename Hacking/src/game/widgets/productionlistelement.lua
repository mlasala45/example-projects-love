local width = 400
local height = 40

local img_x = 20
local img_y = height/2
local img_bg_radius = 16
local img_bg_thick = 3

local text1_x = 90
local text1_y = height/2

local text2_x = 170
local text2_y = height/2

local text3_x = 300
local text3_y = height/2

local thick = 5

local ProductionListElement = Class(Widget, function(self, buildable, pq_ui, color1, color2, selectcolor)
	self.base._ctor(self, "ProductionListElement", 0, 0)

	self.buildable = buildable
	self.pq_ui = pq_ui

	self.color1 = color1
	self.color2 = color2
	self.selectcolor = selectcolor

	self.w = width-thick
	self.h = height

	self.bg = self:AddChild(Box(-thick, -thick, self.w, self.h+thick, thick, self.color1, self.color2))
	self.bg.nobounds = true

	self.city = pq_ui.city

	local function clickfn(inst)
		local name = "ERR"
		if self.parent then name = self.parent.name end
		self.pq_ui:OnListElementClick(self.buildable, self.i, name)
	end

	self.button = self:AddChild(Button(0, 0, self.w, self.h, false, nil, drawfn, clickfn))

	self.img_bg = self:AddChild(Circle(img_x, img_y, img_bg_radius, img_bg_thick, self.color1, self.color2))

	self.img = self:AddChild(Image(img_x, img_y, buildable.portrait, "tex"))
	self.img.Transform:SetScale(0.5)

	self.img.tooltip = { txt=self.buildable.desc, w=200 }

	self.text1 = self:AddChild(Text(text1_x, text1_y, "Product Name"))
	self.text2 = self:AddChild(Text(text2_x, text2_y, "???"))
	self.text3 = self:AddChild(Text(text3_x, text3_y, "0 PP (0 Turns)"))

	self.text1.Transform:SetScale(1.5)
	self.text2.Transform:SetScale(1.5)
	self.text3.Transform:SetScale(1.5)

	self.text1:SetText(buildable.name)
	self.text2:SetText(STRINGS.PRODUCTION.BUILD_TYPES[string.upper(buildable.build_type)])

	self:SetValues((self.city.productions[self.buildable] or 0) + self.city.stored_production, self.city.yields.prod or 0, true)

	self.is_ui = true
	for i,v in ipairs(self.children) do
		v.is_ui = true
	end
end)

function ProductionListElement:SetValues(total, ppt, showcase)
	local turns
	if ppt == 0 then
		turns = 9999
	else
		turns = math.ceil((self.buildable.cost - total) / ppt)
	end

	local prefix = ""
	if not showcase then prefix = total.." / " end

	self.text3:SetText(prefix..self.buildable.cost.." PP ("..turns.." "..STRINGS.PRODUCTION.TURNS..")")
end

function ProductionListElement:Update(dt)
	local mx, my = love.mouse:getPosition()
end

function ProductionListElement:Draw()
	local x, y = self.Transform:GetAbsolutePosition()
	local mx, my = love.mouse:getPosition()

	local c2 = self.color2
	if self:IsFocused(mx, my) then c2 = self.selectcolor end

	self.bg.color2 = c2

	Widget.Draw(self)
end

return ProductionListElement