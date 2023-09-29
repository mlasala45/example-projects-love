local width = 200*1.2
local height = 150*1.2
local thick = 5*1.2

local button_offset = 68
local button_radius = 85*1.2 / 2
local button_thick = thick
local button_scale = 1.8

local button_acc_cap = 0.5

local Bar = require("game/widgets/bar")

local info_start = button_offset+button_radius+thick

local TurnCounterPanel = Class(Widget, function(self, x, y)
	self.base._ctor(self, "TurnCounterPanel", x, y)
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.bg = self:AddChild(RoundedBox(0, 0, width, height, thick, self.color2, self.color1, 10))

	self.turncount = self:AddChild(Text(info_start, 20, "Title", COLORS.YELLOW, false))
	self.turncount.Transform:SetScale(1.5)

	self.is_ui = true --clumsy

	local ntb_drawfn = function(inst)
		print("DEBUG - NTB_DRAWFN")
		local x,y = inst.Transform:GetAbsolutePosition()
		print(x.." "..y)
		geo.drawBorderedCircle(x, y, button_radius, button_thick, self.color1, self.color2)
	end

	local ntb_clickfn = function(inst)
		p_print("ntb_clickfn")
		if TheGameManager:CenterOnNextNecessaryAction(TUNING.DEFAULT_CAMERA_PAN_TIME) then
			self:RecalcMessage()
		else
			self.button_acc = 0
		end
	end

	self.nextturnbutton = self:AddChild(Button(button_offset, height/2, button_radius*2, button_radius*2, true, COLORS.WHITE, ntb_drawfn, ntb_clickfn))
	self.button_text = self.nextturnbutton:AddChild(Text(0, 0, STRINGS.UI.NEXT_TURN_BUTTON.NEXT_TURN, nil, true, nil, 80))

	self.button_acc = -1 --Counter for animation on click

	for i,v in ipairs(self.children) do v.is_ui = true end
	self.button_text.is_ui = true
end)

function TurnCounterPanel:Draw()
	local x, y = self.Transform:GetAbsolutePosition()

	self.base.Draw(self)
end

--This is REALLY not how buttons are supposed to work; Refactor at some point?
function TurnCounterPanel:Update(dt)
	print("Next Turn Button ACC: "..self.button_acc)
	if self.button_acc >= 0 then
		self.button_acc = self.button_acc + dt
		if self.button_acc >= button_acc_cap then
			TheGameManager:NextTurn()
			self.button_acc = -1
			self.nextturnbutton.Transform:SetScale(1)
			--self.nextturnbutton.visible = true
		else
			local s = 0.5 --Calculate animation curve
			self.nextturnbutton.Transform:SetScale(s)
			--self.nextturnbutton.visible = false
		end
	end

	self.base.Update(self, dt)
end

function TurnCounterPanel:RecalcMessage()
	local action = TheGameManager.next_action
	if action then
		if action.type == "unit" then
			self.button_text:SetText(STRINGS.UI.NEXT_TURN_BUTTON.UNIT_NEEDS_ORDERS)
		elseif action.type == "city_setproduction" then
			self.button_text:SetText(STRINGS.UI.NEXT_TURN_BUTTON.CHOOSE_PRODUCTION)
		end
	else
		self.button_text:SetText(STRINGS.UI.NEXT_TURN_BUTTON.NEXT_TURN)
	end
end

function TurnCounterPanel:SetTurn(turn, player)
	self.turncount.text = "Turn "..tostring(turn).."\n"..player.faction.name or "ERROR"
	self.turncount:Recalc()
end

function TurnCounterPanel:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	--assert(false, tostring(mx).." "..tostring(my))
	local x, y = self.Transform:GetAbsolutePosition()
	return geo.inbounds(mx,my,x,y,x+width,y+height,self.Transform:GetRotation())
end

function TurnCounterPanel:GetBounds()
	local x, y = self.Transform:GetAbsolutePosition()
	return x,y,x+width,y+height
end

return TurnCounterPanel