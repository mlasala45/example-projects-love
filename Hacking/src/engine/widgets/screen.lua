Screen = Class(Widget, function(self, a, b, c)
	Widget._ctor(self, "Screen", 0, 0)

	self.is_screen = true

	self.hidden_screens = {}
end)

function Screen:Show()
	Widget.Show(self)

	for i,v in ipairs(ROOT.children) do
		if v.is_screen and v.visible and v ~= self then
			table.insert(self.hidden_screens, v)
			v:Hide()
		end
	end
end

function Screen:Hide()
	Widget.Hide(self)
	
	for i,v in ipairs(self.hidden_screens) do
		v:Show()
	end
	self.hidden_screens = {}
end