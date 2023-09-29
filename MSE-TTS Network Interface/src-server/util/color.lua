CLAMP_COLORS = true

--Uses AMERICAN spelling, for consitency

COLORS = {
	RED     = {255, 0, 0},
	ORANGE  = {255, 255/2, 0},
	YELLOW  = {255, 255, 0},
	GREEN   = {0, 255, 0},
	BLUE    = {0, 0, 255},
	MAGENTA = {255, 0, 255},
	PURPLE  = {255/2, 0, 255},
	CYAN    = {0, 255, 255},
	WHITE   = {255, 255, 255, 255},
	BLACK   = {0, 0, 0},
	GRAY    = {255/2, 255/2, 255/2},

	DARK_GREEN   = {0, 255/2, 0},
	DARK_BLUE   = {0, 0, 255/2},
	DARK_GRAY   = {255/3, 255/3, 255/3},

	HALF_WHITE = {255, 255, 255, 255/2},
	HALF_BLACK = {0, 0, 0, 255/2},

	THREE_QUARTER_BLACK = {0, 0, 0, 255*2/3},

	CLEAR = {0, 0, 0, 0}
}

function ClampColor(v)
	for i=1,3 do v[i] = v[i] / 255 end
	if v[4] then v[4] = v[4] / 255 end
end

if CLAMP_COLORS then
	for k,v in pairs(COLORS) do
		ClampColor(v)
	end
end

function MakeColor(r, g, b, a)
	local ret
	if a then
		ret = { r, g, b, a }
	else
		ret = { r, g, b }
	end
	if CLAMP_COLORS then
		ClampColor(ret)
	end
	return ret
end

--When 0 ≤ H < 360, 0 ≤ S ≤ 1 and 0 ≤ V ≤ 1:
function HSVtoRGB(h,s,v)
	local c = v*s
	local x = c*(1-math.abs((h/60)%2-1))
	local m = v-c
	local r1 = 0
	local g1 = 0
	local b1 = 0
	if h < 60 then
		r1 = c
		g1 = x
	elseif h < 120 then
		r1 = x
		g1 = c
	elseif h < 180 then
		g1 = c
		b1 = x
	elseif h < 240 then
		g1 = c
		b1 = x
	elseif h < 300 then
		r1 = x
		b1 = c
	elseif h < 360 then
		r1 = c
		b1 = x
	end
	return { (r1+m)*255,(g1+m)*255,(b1+m)*255 }
end

function RandomColor()
	return { math.random(0,255), math.random(0,255), math.random(0,255) }
end

function ColorMult(color, mult)
	return { color[1]*mult, color[2]*mult, color[3]*mult, color[4] }
end

--Draws stencil values as color zones; for debug purposes
function DrawStencil()
	local mode, num = love.graphics.getStencilTest()
	local colors = { COLORS.DARK_BLUE, COLORS.RED, COLORS.ORANGE, COLORS.YELLOW, COLORS.GREEN, COLORS.BLUE, COLORS.PURPLE }

	for i=0,6 do
		love.graphics.setStencilTest("equal", i)
		love.graphics.setColor(colors[i+1])
		love.graphics.rectangle("fill",0,0,WINDOW_WIDTH,WINDOW_HEIGHT)
	end

	love.graphics.setStencilTest(mode, num)
end