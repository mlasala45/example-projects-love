local default_cursor_tick = 1

TextEntry = Class(Box, function(self, x, y, width, height, linestart, submitfn, entryfn, extrakeyfn)
	Box._ctor(self, x, y, width, height)
	self.name = "TextEntry"

	self.submitfn = submitfn
	self.entryfn = entryfn
	self.extrakeyfn = extrakeyfn

	self.linestart = linestart or ""

	self.text_obj = self:AddChild(Text(0, 0, self.linestart, COLORS.WHITE, false, FONTS.DEFAULT_LARGE, width))
	self.text_obj.Transform:SetScale(0.5)

	local keyhandler = function(key, isrepeat)
		if not self.visible then return end
		if not self.selected then return end

		if not isrepeat then
			if key == "a" and love.keyboard.isDown("lctrl") then
				--self:SelectAll()
			end
			if key == "return" then
				self:Submit()
			end
		end

		if key == "backspace" then
			self.text = self.text:sub(1, self.cursor_pos-1)..self.text:sub(self.cursor_pos+1)
			self:SetCursorPos(self.cursor_pos-1)
		end
		if key == "left" then
			self:SetCursorPos(self.cursor_pos - 1)
		end
		if key == "right" then
			self:SetCursorPos(self.cursor_pos + 1)
		end

		if self.extrakeyfn then self.extrakeyfn(self, key, isrepeat) end

		self:UpdateText()

		return true
	end

	local texthandler = function(char)
		if not self.visible then return end

		if self.entryfn then
			self.entryfn(self, char)
		else
			if self.selected then
				self.text = self.text:sub(1, self.cursor_pos)..char..self.text:sub(self.cursor_pos+1)
				self:SetCursorPos(self.cursor_pos+1)
			end
		end

		self:UpdateText()
	end

	local clickhandler = function(x, y, button)
		if not self.visible then return end
		--No good reason for this
		if button == 1 then
			if not self:IsFocused(x, y) then
				self.selected = false
			end
		end
		if button == 0 then
			if self:IsFocused(x, y) then
				self.selected = true
			else
				self.selected = false
			end
		end
	end

	self.texthandler = InputHandler:AddTextHandler(texthandler)
	self.keyhandler = InputHandler:AddGeneralKeypressHandler(keyhandler, true)
	self.clickhandler = InputHandler:AddClickHandler(clickhandler)

	--

	self.selected = false
	self.text = ""

	self.cursor_pos = 0
	self.cursor_acc = 0
	self.cursor_state = true

	self.cursor_tick = TUNING.ENGINE.TEXTENTRY.CURSOR_TICK or default_cursor_tick
end)

--Backend

function TextEntry:Draw()
	--local x,y = self.Transform:GetAbsolutePosition()
	--local sx,sy = self.Transform:GetAbsoluteScale()
	--local w,h = self:GetWidth(), self:GetHeight()

	Widget.Draw(self)
end

function TextEntry:Update(dt)
	if not self.visible then self.selected = false end

	if self.selected then
		self.cursor_acc = self.cursor_acc + dt
		if self.cursor_acc > self.cursor_tick then
			self.cursor_acc = self.cursor_acc - self.cursor_tick
			self.cursor_state = not self.cursor_state
		end
	else
		self.cursor_pos = #self.text
		self.cursor_state = false
		self.cursor_acc = self.cursor_tick - 0.01
	end

	--TODO: Dynamic cursor position

	self:UpdateText()
end

function TextEntry:UpdateText()	
	local cursor_char = " "
	if self.cursor_state then cursor_char = "|" end
	
	local text = self.linestart..self.text:sub(1,self.cursor_pos)..cursor_char..self.text:sub(self.cursor_pos+1)

	self.text_obj:SetText(text)
end

--External Access

function TextEntry:SetCursorPos(pos)
	self.cursor_pos = math.clamp(pos, 0, #self.text)
	--self.cursor_state = true
	--self.cursor_acc = 0
end

function TextEntry:Clear()
	self.text = ""
	self:UpdateText()
end

function TextEntry:Submit()
	if self.submitfn then
		self.submitfn(self, self.text)
	end
end

function TextEntry:Destroy()
	InputHandler:RemoveTextHandler(self.texthandler)
	InputHandler:RemoveGeneralKeypressHandler(self.keyhandler)
end