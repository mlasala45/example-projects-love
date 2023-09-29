local width = 120*1.2
local height = 420*1.2
local thick = 5*1.2

local seperation = 5

local Bar = require("game/widgets/bar")
local MenuList = require("game/widgets/menulist")
local NotificationFeedElement = require("game/widgets/notificationfeedelement")

local NotificationFeed = Class(Widget, function(self, x, y)
	self.base._ctor(self, "NotificationFeed", x, y)
	
	self.color1 = UI_COLOR_PRIMARY
	self.color2 = UI_COLOR_SECONDARY

	self.notifs = {}

	self.menulist = self:AddChild(MenuList(width/2,thick,width-thick*2,height-thick*2,seperation,true))
	self.menulist.centered = true
end)

function NotificationFeed:RecalcNotifications(notifs)
	self.menulist:Clear()

	self.notifs = notifs --Change later?

	for i,v in ipairs(self.notifs) do
		local item = NotificationFeedElement(v, self, self.color1, self.color2)
		self.menulist:AddItem(item)
	end
end

function NotificationFeed:OnNotificationClicked(i, button)
	if button == 1 then
		if self.notifs[i].clickfn then self.notifs[i].clickfn(TheGameManager:GetCurrentPlayer()) end
	elseif button == 2 and not self.notifs[i].persistent then
		TheGameManager:DismissNotification(nil, i)
	end
end

function NotificationFeed:Draw()
	local x, y = self.Transform:GetAbsolutePosition()
	--geo.drawBorderedRectangle(x, y, width, height, thick, self.color1, self.color2)

	self.base.Draw(self)
end

--This is REALLY not how buttons are supposed to work; Refactor at some point?
function NotificationFeed:Update(dt)
	Widget.Update(self,dt)
end

function NotificationFeed:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	--assert(false, tostring(mx).." "..tostring(my))
	local x, y = self.Transform:GetAbsolutePosition()
	return geo.inbounds(mx,my,x,y,x+width,y+height,self.Transform:GetRotation())
end

function NotificationFeed:GetBounds()
	local x, y = self.Transform:GetAbsolutePosition()
	return x,y,x+width,y+height
end

return NotificationFeed