Screen = Class(Widget, function(self, hide_other_screens)
	Widget._ctor(self, "Screen", 0, 0)

	self.is_screen = true

	self.hide_other_screens = hide_other_screens or (hide_other_screens == nil and true)

	if self.hide_other_screens then
		self.hidden_screens = {}
	end
end)

function Screen:Show()
	Widget.Show(self)

	ActiveScreen = self

	if self.hide_other_screens then
		for i,v in ipairs(ROOT.children) do
			if v.is_screen and v.visible and v ~= self then
				table.insert(self.hidden_screens, v)
				v:Hide()
			end
		end
	end
end

function Screen:Hide()
	Widget.Hide(self)
	
	if self.hide_other_screens then
		for i,v in ipairs(self.hidden_screens) do
			v:Show()
		end
		self.hidden_screens = {}
	end
end