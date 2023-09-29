IconText = Class(Widget, function(self, x, y, raw, color, centered, font, ww)
	self.base._ctor(self, "IconText", x, y)

	self.raw = raw
	self.color = color or COLORS.WHITE
	self.font = font or FONTS.DEFAULT
	self.ww = ww or DEFAULT_TEXT_WIDTH

	self.centered = centered
	if self.centered==nil then self.centered = true end

	self.anchor = self:AddChild(Widget("IconText Anchor", 0, 0))

	self.nobounds = true

	self.subs = {}

	self:Recalc()
end)

--REGISTRY
RegisteredInlineIcons = {}
function RegisterInlineIcon(name, atlas, tex, scale, ox, oy)
	RegisteredInlineIcons[name] = {
		atlas = atlas,
		tex = tex,
		scale = scale,
		ox = ox or 0,
		oy = oy or 0,
	}
end


function IconText:SetText(raw)
	self.raw = raw
	self:Recalc()
end

function IconText:Recalc()
	for i,v in ipairs(self.subs) do
		if v.obj then v.obj:Remove() end
	end

	self:LoadRawString(self.raw)

	local w = 0
	local h = 0

	local fontHeight = self.font:getHeight()
	local line = 0

--p_print("BEGIN")

	--TODO: Wrappingh for images
	local oy = 0
	local i = 1
	local v
	while i <= #self.subs do
		v = self.subs[i]

		if v.type == "string" then
			local objWidth
			local spareVal = ""
			local loop
			local loop_acc = 0
				--p_print("LOOP "..i)
			repeat
				loop = false
				v.obj = self.anchor:AddChild(Text(w, 0, v.val, self.color, false, self.font))
				objWidth = v.obj.drawable:getWidth()
				--p_print((w + objWidth).." "..v.val:gsub("\n","\\n").."::"..spareVal:gsub("\n","\\n")..";;")
				if w + objWidth > self.ww then
					--p_print("FACTS")
					spareVal = v.val:sub(-1)..spareVal
					v.val = v.val:sub(1, -2)
					v.obj:Remove()
					loop = true
					loop_acc = loop_acc + 1
				end
			until (not loop) or loop_acc > 10
			assert(loop_acc < 10, p_debug_str)
			v.obj.Transform.y = (line*fontHeight) * oy + (self.centered and -(fontHeight/2) or 0)
			h = math.max(h, self.font:getHeight())
			w = w + objWidth

			if spareVal:len() > 0 then
				line = line + 1
				table.insert(self.subs, i+1, { type="string", val=spareVal })
			end
		elseif v.type == "image" then
			local entry = RegisteredInlineIcons[v.val]
			assert(entry, "Attempt to load IconText with unregistered inline icon: "..v.val)
			v.obj = self.anchor:AddChild(Image(0, 0, entry.atlas, entry.tex))
			v.obj.Transform.x = w + (v.obj:GetWidth()*entry.scale/2) + entry.ox
			v.obj.Transform.y = entry.oy + oy---v.obj:GetHeight() * entry.scale / 2
			v.obj.Transform:SetScale(entry.scale)
			--h = math.max(h, oy+v.obj:GetHeight())
			w = w + (v.obj:GetWidth())
		elseif v.type == "oy" then
			oy = v.val
		elseif v.type == "sep" then
			local sep = (v.val or 1) * 3
			w = w + sep
		end

		i = i + 1
	end

	--if v then w = w - v.obj:GetWidth() end

	self.w = w
	self.h = h

	--if self.centered then self.anchor.Transform.x = -w/2 end
end

local function add_text_sequence(self, str)
	if #self.subs > 0 and self.subs[1].type == "text" then
		self.subs[1].val = self.subs[1].val + str
	else
		table.insert(self.subs, {
			type = "string",
			val = str,
		})
	end
end

local function add_command_sequence(self, val)
	if val == "sep" then
		table.insert(self.subs, {
				type = "sep",
			})
	elseif val:find(":") then
		table.insert(self.subs, {
				type = val:sub(1, val:find(":")-1),
				val = val:sub(val:find(":")+1),
			})
	else
		--Inline Icon
		table.insert(self.subs, {
				type = "image",
				val = val,
			})
	end
end

local function clean_floating_spaces(self)
	local pass = true
	repeat
		pass = true
		for i,v in ipairs(self.subs) do
			if v.type == "string" then
				local count = 0
				while v.val:sub(#v.val-count, #v.val-count) == " " do
					count = count + 1
				end
				if count > 0 then
					v.val = v.val:sub(1, #v.val-count)
					table.insert(self.subs, i+1, {
						type = "sep",
						val = count
					})
					if #v.val == 0 then table.remove(self.subs, i) end
					pass = false
					break
				end
			end
		end
	until pass
end

function IconText:LoadRawString(raw)
	self.subs = {}
	while raw:len() > 0 do
		local nextEscapeIndex = raw:find("%%")
		if nextEscapeIndex then
			add_text_sequence(self, raw:sub(1, nextEscapeIndex - 1))
			raw = raw:sub(nextEscapeIndex+1)
			
			nextEscapeIndex = raw:find("%%")
			if nextEscapeIndex then
				if nextEscapeIndex == 1 then
					add_text_sequence(self, "%")
				else
					add_command_sequence(self, raw:sub(1, nextEscapeIndex - 1))
				end
				raw = raw:sub(nextEscapeIndex+1)
			else
				assert(false, "LoadRawString Error: No closing delimiter ('%') for escape sequence!")
			end
		else
			add_text_sequence(self, raw)
		    raw = ""
		end
	end

	clean_floating_spaces(self)
end

function IconText:Draw()
	Widget.Draw(self)
end

function IconText:DrawBounds(color)
	local old = tostring(color)
	color = color or DEBUG_COLOR

	local minX, minY, maxX, maxY = self:GetBounds()
	love.graphics.setColor(color)
	love.graphics.rectangle("line",minX,minY,maxX-minX,maxY-minY)
	love.graphics.setColor(COLORS.WHITE)
end

function IconText:IsFocused(mx, my)
	if Widget.IsFocused(self, mx, my) then return true end
	
	local minX, minY, maxX, maxY = self:GetBounds()
	return mx >= minX and mx <= maxX and my >= minY and my <= maxY
end

function IconText:GetBounds()
	local x,y = self.anchor.Transform:GetAbsolutePosition()
	local sx,sy = self.Transform:GetAbsoluteScale()
	local w,h = self.w, self.h
	w = w * sx
	h = h * sy
	if self.centered then
		return x,y-h/2,x+w,y+h/2
	else
		return x,y,x+w,y+h
	end
end

function IconText:GetWidth()
	return self.w
end

function IconText:GetHeight()
	return self.h
end

--TODO: Alignment; Width/Height sensing