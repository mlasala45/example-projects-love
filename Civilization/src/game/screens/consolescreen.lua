local bg1_w = 400
local bg1_h = 350

local entrybar_w = bg1_w
local entrybar_h = 30

local margin = 5

local title_oy = 25

local text_color = COLORS.WHITE

local lower_margin = 20

local output_scale = 0.8
local linestarter = " > "

--TUNING

local default_history_size = 20

local MenuList = require("game/widgets/menulist")

local ConsoleScreen = Class(Screen, function(self)
	Screen._ctor(self, false)

	self.name = "ConsoleScreen"

	self.color1 = CITY_UI_COLOR_PRIMARY
	self.color2 = CITY_UI_COLOR_SECONDARY

	self.prevent_input_handling = true

	self.ORGANIZER = {}
	self.DATA = {}

	local top = WINDOW_HEIGHT - bg1_h - entrybar_h - margin*2


	local bg2 = self:AddChild(Box(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT))
	bg2.nobounds = true

	self.ORGANIZER.bg2 = { _inst=bg2 }


	local bg1 = self:AddChild(Box(margin, top, bg1_w, bg1_h, 2, COLORS.WHITE, COLORS.THREE_QUARTER_BLACK))

	self.ORGANIZER.output = {}
	self.ORGANIZER.output.bg = { _inst=bg1 }


	local entrybar_bg = self:AddChild(Box(margin, top + bg1_h + margin, entrybar_w, entrybar_h, 2, COLORS.WHITE, COLORS.THREE_QUARTER_BLACK))
	
	self.ORGANIZER.entrybar = {}
	self.ORGANIZER.entrybar.bg = { _inst=entrybar_bg }

	local submitfn = function(entry, text)
		entry:Clear()

		self.DATA.history_pointer = 0
		self:SubmitText(text)
	end

	local extrakeyfn = function(entry, key, isrepeat)
		if not entry.selected then return end

		if key == "up" then
			self.DATA.history_pointer = math.min(self.DATA.history_pointer + 1, #self.DATA.history)
			self:LoadFromHistory(entry)
		end
		if key == "down" then
			self.DATA.history_pointer = math.max(self.DATA.history_pointer - 1, 0)
			self:LoadFromHistory(entry)
		end
	end

	local entrybar = entrybar_bg:AddChild(TextEntry(0, 0, entrybar_w, entrybar_h, linestarter, submitfn, nil, extrakeyfn))
	entrybar.Transform:SetScale(1.8)

	self.ORGANIZER.entrybar._inst = entrybar


	local output = bg1:AddChild(Text(0, 0, "", COLORS.WHITE, false, FONTS.DEFAULT_LARGE, bg1_w / output_scale))
	output.Transform:SetScale(output_scale)

	self.ORGANIZER.output._inst = output


	self.DATA.history = {}
	self.DATA.history_pointer = 0


	for i,v in ipairs(self.children) do v.is_ui = true end
end)

--Backend

function ConsoleScreen:Update(dt)
	if self.select_on_update then self.ORGANIZER.entrybar._inst.selected = true end

	local output_text = self:FormatOutputText(p_debug_str)
	self.ORGANIZER.output._inst:SetText(output_text)

	Screen.Update(self, dt)
end

function ConsoleScreen:Show()
	self.select_on_update = true

	self.ORGANIZER.entrybar._inst.visible = true

	Screen.Show(self)
end

function ConsoleScreen:Hide()
	self.ORGANIZER.entrybar._inst.selected = false
	
	self.ORGANIZER.entrybar._inst.visible = false

	Screen.Hide(self)
end

--External Access

function ConsoleScreen:LoadFromHistory(entry)
	if self.DATA.history_pointer == 0 then
		entry.text = ""
	else
		entry.text = self.DATA.history[self.DATA.history_pointer]
	end
	entry:SetCursorPos(#entry.text)

	entry:UpdateText()
end

function ConsoleScreen:SubmitText(text)
	p_print(linestarter..text)

	table.insert(self.DATA.history, 1, text)
	if #self.DATA.history > (TUNING.ENGINE.CONSOLE_HISTORY_SIZE or default_history_size) then
		table.remove(self.DATA.history, #self.DATA.history)
	end

	local fn, err = loadstring(text)
	if fn then
		print = p_print

		local success, err2 = pcall(fn)
		if not success then
			p_print(err2)
		end

		print = f_print
	else
		p_print(err)
	end
end

function ConsoleScreen:FormatOutputText(debugText)
	local lines = {}
	for s in debugText:gmatch("[^\n]+") do
	    table.insert(lines, s)
	end

	local output = ""
	for i,v in ipairs(lines) do
		output = output..v.."\n"
	end
	output = output:sub(1, -2)
	return output
end

return ConsoleScreen