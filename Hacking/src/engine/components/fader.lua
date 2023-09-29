local Component = require "engine/component"

local Fader = Class(Component, function(self, inst)
	self.base._ctor(self, inst)

	self.elapsed = 0
	self.target = 0
	self.fade_dir = false
	self.cb = nil
end)

function Fader:Update(dt)
	if self.target ~= 0 then
		self.elapsed = math.min(self.target, self.elapsed + dt)

		self.inst.alpha = (self.elapsed / self.target) * 255
		if not self.fade_dir then self.inst.alpha = 255 - self.inst.alpha end

		if self.elapsed == self.target then
			self.target = 0
			if self.cb then
				self.cb(self.inst)
			end
		end
	end
end

--[[
-- Initiates a fade with the object's alpha value
-- dt - Length of fade in seconds
-- on - 
--	true: Fade from alpha = 0 to alpha = 255
--	false: Fade from alpha = 255 to alpha = 0
-- cb - Callback to perform upon fade completion (can be nil)
--]]
function Fader:Fade(dt, on, cb)
	self.target = dt
	self.elapsed = 0
	self.fade_dir = on
	self.cb = cb
end

return Fader