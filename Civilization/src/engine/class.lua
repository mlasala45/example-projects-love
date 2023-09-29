Class = {}
setmetatable(Class, {
	__call = function(_, base, ctor)
		if type(base) == "function" then
			ctor = base
			base = nil
		end
		local ret = {}
		ret._ctor = ctor
		ret.base = base
		setmetatable(ret, {
			__call = function(classdef, ...)
				local inst = {}
				setmetatable(inst, {
					__index = classdef,
				})
				classdef._ctor(inst, ...)
				return inst
			end,

			__index = base,
		})
		return ret
	end
})