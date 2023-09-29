local width = 272
local height = 62

local thick = 5

local portrait_offset = 32
local portrait_radius = 25
local portrait_thick = thick
local portrait_scale = 1

local title_x = 72
local title_y = 4
local title_scale = 1.25
local title_height = 15

local icons_start_x = 80
local icon_scale = 0.6
local icon_seperation = 35

--TODO

local TechBubble = Class(Widget, function(self, x, y, tech)
	self.base._ctor(self, "TechBubble", x, y)
	
	self.borderColor = UI_COLOR_PRIMARY
	self.fillColor = UI_COLOR_SECONDARY

	self.bg = self:AddChild(RoundedBox(0, 0, width, height, thick, self.fillColor, self.borderColor, 10))

	self.title = self:AddChild(Text(title_x, title_y, "Title", COLORS.WHITE, false))
	self.title.Transform:SetScale(title_scale)

	self.portrait = self:AddChild(Image(portrait_offset, height/2, "portrait_plains", "tex"))
	self.portrait.Transform:SetScale(portrait_scale)

	local x = icons_start_x
	local y = height-((height-title_height)/2)
	self.icons = {}
	for i=1,5 do
		self.icons[i] = self:AddChild(Image(x, y, "portrait_plains", "tex"))
		self.icons[i].Transform:SetScale(icon_scale)
		x = x + icon_seperation
	end

	self:LoadTech(tech)
end)

-- 0: Not Yet Available
-- 1: Available
-- 2: Currently Researching
-- 3: Researched
function TechBubble:SetStatus(num)
	self.status = num
	if num == 0 then
		self.color = CUSTOM_COLORS.TECH_STATUS_0
	elseif num == 1 then
		self.color = CUSTOM_COLORS.TECH_STATUS_1
	elseif num == 2 then
		self.color = CUSTOM_COLORS.TECH_STATUS_2
	elseif num == 3 then
		self.color = CUSTOM_COLORS.TECH_STATUS_3
	end

	self.bg.fillColor = self.color
end

function TechBubble:Draw()
	local x, y = self.Transform:GetAbsolutePosition()

	love.graphics.setColor(CUSTOM_COLORS.SILVER)
	for i,v in ipairs(self.lines) do
		love.graphics.line(v)
	end

	--love.graphics.setColor(self.color)
	--love.graphics.rectangle("fill", x, y, width, height)
	--love.graphics.setColor(COLORS.BLACK)
	--love.graphics.rectangle("line", x, y, width, height)

	self.base.Draw(self)

	love.graphics.setColor(COLORS.BLACK)
	x,y = self.portrait.Transform:GetAbsolutePosition()
	love.graphics.circle("line", x, y, portrait_radius)
end

local function determine_portrait(cell)
	if cell.terrain == "mountain" then return "portrait_mountain" end
	if cell.vegetation == "forest" then return "portrait_forest" end
	if cell.terrain == "hills" then return "portrait_hills" end
	return cell.biome.portrait
end

function TechBubble:LoadTech(tech)
	self.tech = tech

	self.title:SetText(STRINGS.TECHS.NAMES[string.upper(tech.name)])

	self:RecalcOverviewIcons()

	self:SetStatus(0)
end

local function roi_process_table(self, t, default)
	if not t then return end

	for i,v in ipairs(t) do
		if self.roi_tmp_index > 5 then return end

		local atlas
		if v then
			atlas = v.portrait or default or "portrait_mountain"
		else
			atlas = "portrait_mountain" --"missing_portrait"
		end
		self.icons[self.roi_tmp_index].atlas = atlas
		self.icons[self.roi_tmp_index]:Show()
		self.roi_tmp_index = self.roi_tmp_index + 1
	end
end

function TechBubble:RecalcOverviewIcons()
	self.roi_tmp_index = 1
	roi_process_table(self, self.tech.units)
	roi_process_table(self, self.tech.buildings)
	roi_process_table(self, self.tech.wonders)
	roi_process_table(self, self.tech.improvements)
	roi_process_table(self, self.tech.resources)
	roi_process_table(self, self.tech.features)

	while self.roi_tmp_index <= 5 do
		self.icons[self.roi_tmp_index]:Hide()
		self.roi_tmp_index = self.roi_tmp_index + 1
	end
	self.roi_tmp_index = nil
end

function TechBubble:RecalcConnectors(tech_bubbles)
	self.lines = {}
	if not self.tech.prereq then return end
	for i,v in ipairs(self.tech.prereq) do
		local parent = tech_bubbles[v].Transform
		table.insert(self.lines, {
			parent.x+width,
			parent.y+(height/2),
			self.Transform.x,
			self.Transform.y+(height/2)
		})
	end
end

return TechBubble