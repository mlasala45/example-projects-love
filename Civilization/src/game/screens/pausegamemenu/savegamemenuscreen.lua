local bg1_w = 350
local bg1_h = 400

local thick = 5

local title_oy = 25

local menulist_oy = 25
local menulist_w = bg1_w - (thick*2) - (thick*2)
local seperation = 5

local button_h = 30

local text_color = COLORS.WHITE

local lower_margin = 20

local MenuList = require("game/widgets/menulist")

local SaveGameMenuScreen = Class(Screen, function(self)
	Screen._ctor(self)

	self.color1 = CITY_UI_COLOR_PRIMARY
	self.color2 = CITY_UI_COLOR_SECONDARY

	self.prevent_input_handling = true

	self.ORGANIZER = {}

	local top = MID_Y - bg1_h/2

	local bg2 = self:AddChild(Box(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT))
	bg2.nobounds = true

	self.ORGANIZER.bg2 = { _inst=bg2 }


	local bg1 = self:AddChild(RoundedBox(MID_X - bg1_w/2, top, bg1_w, bg1_h, thick, COLORS.DARK_GRAY, COLORS.BLACK, 20))

	self.ORGANIZER.bg1 = { _inst=bg1 }


	local title = bg1:AddChild(Text(bg1_w/2, title_oy, STRINGS.UI.PAUSEGAMEMENU.TITLE, text_color, true, FONTS.DEFAULT_LARGE, 200))
	title.Transform:SetScale(1.5)

	self.ORGANIZER.title = { _inst=title }


	top = top + title_oy + self.ORGANIZER.title._inst:GetHeight()

	local menulist = bg1:AddChild(MenuList((bg1_w/2)-(menulist_w/2), title_oy + self.ORGANIZER.title._inst:GetHeight() + menulist_oy, menulist_w, 0, seperation))

	self.ORGANIZER.menulist = { _inst=menulist }

	local function make_clickfn(i)
		return function(inst)
		end
	end

	self.ORGANIZER.menulist.buttons = {}

	self:AddButton(1, STRINGS.UI.PAUSEGAMEMENU.BUTTON_1)
	self:AddButton(2, STRINGS.UI.PAUSEGAMEMENU.BUTTON_2)
	self:AddButton(3, STRINGS.UI.PAUSEGAMEMENU.BUTTON_3)
	self:AddButton(4, STRINGS.UI.PAUSEGAMEMENU.BUTTON_4)
	self:AddButton(5, STRINGS.UI.PAUSEGAMEMENU.BUTTON_5)

	local new_h = title_oy + self.ORGANIZER.title._inst:GetHeight()
	 + menulist_oy + self.ORGANIZER.menulist._inst:GetHeight()
	  + lower_margin
	p_print("COWABUNGA")
	p_print(self.ORGANIZER.menulist._inst:GetHeight())
	p_print(new_h)
	self.ORGANIZER.bg1._inst.h = new_h
	self.ORGANIZER.bg1._inst.Transform.y = MID_Y-new_h/2

	for i,v in ipairs(self.children) do v.is_ui = true end
end)

local function drawfn(inst)
	--inst.ORGANIZER.bg._inst:Draw()
	--inst.ORGANIZER.text._inst:Draw()

	inst.ORGANIZER.select._inst.visible = inst:IsFocused(MX, MY)
end

function SaveGameMenuScreen:AddButton(i, str)
	local clickfn = function(inst) self:OnButtonClicked(i) end
	local button = Button(0, 0, menulist_w, button_h, false, nil, drawfn, clickfn)

	local w,h = button:GetWidth(), button:GetHeight()

	button.ORGANIZER = {
		bg = {
			_inst = button:AddChild(RoundedBox(0, 0, button:GetWidth(), button:GetHeight(), 0, CUSTOM_COLORS.UI_BUTTON, nil, 5))
		},
		select = {
			_inst = button:AddChild(RoundedBox(0, 0, button:GetWidth(), button:GetHeight(), 0, COLORS.HALF_WHITE, nil, 5))
		},
		text = {
			_inst = button:AddChild(Text(w/2, h/2, str, COLORS.WHITE, true, FONTS.DEFAULT_LARGE, w))
		},
	}

	button.ORGANIZER.text._inst.Transform:SetScale(1)

	--local text = button:AddChild(Text())

	self.ORGANIZER.menulist.buttons[i] = {
		_inst=button,
		--text = { _inst=text }
	}

	self.ORGANIZER.menulist._inst:AddItem(button)

	return button
end

local Enum_PGM_Buttons = {
	Resume = 1,
	SaveGame = 2,
	LoadGame = 3,
	Options = 4,
	Quit = 5
}

function SaveGameMenuScreen:OnButtonClicked(i)
	if i == Enum_PGM_Buttons.Resume then
		self:Hide()
	elseif i == Enum_PGM_Buttons.SaveGame then
		SaveGameIndex:SaveGameToFile("quicksave")
	elseif i == Enum_PGM_Buttons.LoadGame then
		SaveGameIndex:LoadGameFromFile("quicksave")
	elseif i == Enum_PGM_Buttons.Options then
		--
	elseif i == Enum_PGM_Buttons.Quit then
		love.event.quit()
	end
end

return SaveGameMenuScreen