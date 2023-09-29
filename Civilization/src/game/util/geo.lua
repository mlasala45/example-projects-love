geo = {}

function geo.drawBorderedRectangle(x,y,width,height,thick, borderColor, fillColor)
	love.graphics.setColor(borderColor)
	love.graphics.rectangle("fill",x,y,width,height)
	love.graphics.setColor(fillColor)
	love.graphics.rectangle("fill",x+thick,y+thick,width-thick*2,height-thick*2)
	love.graphics.setColor(COLORS.BLACK)
	love.graphics.rectangle("line",x,y,width,height)
	love.graphics.rectangle("line",x+thick,y+thick,width-thick*2,height-thick*2)
	love.graphics.setColor(COLORS.WHITE)
end

function geo.drawRectangleBorder(x,y,width,height,thick, borderColor)
	love.graphics.setColor(borderColor)
	love.graphics.rectangle("fill",x,y,width,thick)
	love.graphics.rectangle("fill",x,y+height-thick,width,thick)
	love.graphics.rectangle("fill",x,y+thick,thick,height-thick-thick)
	love.graphics.rectangle("fill",x+width-thick,y+thick,thick,height-thick-thick)
	love.graphics.setColor(COLORS.BLACK)
	love.graphics.rectangle("line",x,y,width,height)
	love.graphics.rectangle("line",x+thick,y+thick,width-thick*2,height-thick*2)
	love.graphics.setColor(COLORS.WHITE)
end

--TRANSPARENCY DOES NOT WORK
--TODO
function geo.drawRoundedBorderedRectangle(x, y, width, height, radius, thick, fillColor, borderColor)
	if not fillColor then fillColor = COLORS.CLEAR end
	if (fillColor[4] or 1) < 1 then
		local mode,i = love.graphics.getStencilTest()
		if mode == "always" then i = -1 end
	
		local function stencilfn1()
			geo.doDrawRoundedRectangle(x, y, width, height, radius)
		end
		local function stencilfn2()
			geo.doDrawRoundedRectangle(x+thick, y+thick, width-(thick*2), height-(thick*2), radius-thick)
		end
		love.graphics.stencil(stencilfn1, "increment")
		love.graphics.stencil(stencilfn2, "decrement")
		love.graphics.setStencilTest("greater", i+1)
		
		love.graphics.setColor(borderColor)
		--love.graphics.rectangle("fill",x,y,width,height)
		love.graphics.rectangle("fill",0,0,WINDOW_WIDTH,WINDOW_HEIGHT)

		if i == -1 then
			love.graphics.setStencilTest()
		else
			love.graphics.setStencilTest(mode, i)
		end

		love.graphics.stencil(stencilfn2, "increment")
		love.graphics.stencil(stencilfn1, "decrement")

		if (fillColor[4] or 1) > 0 then
			love.graphics.stencil(stencilfn2, "increment")
			love.graphics.setStencilTest("greater", i+1)

			love.graphics.setColor(fillColor)
			love.graphics.rectangle("fill",x,y,width,height)

			love.graphics.stencil(stencilfn2, "decrement")
		end

		if i == -1 then
			love.graphics.setStencilTest()
		else
			love.graphics.setStencilTest(mode, i)
		end
	else
		geo.drawRoundedRectangle(x, y, width, height, radius, borderColor)
		geo.drawRoundedRectangle(x+thick, y+thick, width-(thick*2), height-(thick*2), radius-thick, fillColor)
	end
end

function geo.drawRoundedRectangle(x, y, width, height, radius, fillColor)
	local mode,i = love.graphics.getStencilTest()
	if mode == "always" then i = -1 end
	
	local function stencilfn()
		geo.doDrawRoundedRectangle(x, y, width, height, radius)
	end
	love.graphics.stencil(stencilfn, "increment")
	love.graphics.setStencilTest("greater", i+1)
	
	love.graphics.setColor(fillColor)
	love.graphics.rectangle("fill",x,y,width,height)

	love.graphics.stencil(stencilfn, "decrement")

	if i == -1 then
		love.graphics.setStencilTest()
	else
		love.graphics.setStencilTest(mode, i)
	end

	love.graphics.setColor(COLORS.WHITE)
end

function geo.doDrawRoundedRectangle(x, y, width, height, radius)
	love.graphics.setColor(COLORS.WHITE)

	love.graphics.rectangle("fill",x,y+radius,width,height-(radius*2))
	love.graphics.rectangle("fill",x+radius,y,width-(radius*2),height)
	love.graphics.circle("fill",x+radius,y+radius,radius)
	love.graphics.circle("fill",x+radius,y+height-radius,radius)
	love.graphics.circle("fill",x+width-radius,y+radius,radius)
	love.graphics.circle("fill",x+width-radius,y+height-radius,radius)

end

function geo.drawBorderedCircle(x,y,radius,thick, color1, color2)
	if color1 then
		love.graphics.setColor(color1)
		love.graphics.circle("fill",x,y,radius)
	end
	if color2 then
		love.graphics.setColor(color2)
		love.graphics.circle("fill",x,y,radius-thick)
	end
	love.graphics.setColor(COLORS.BLACK)
	if color1 then love.graphics.circle("line",x,y,radius) end
	if color1 or color2 then love.graphics.circle("line",x,y,radius-thick) end
	love.graphics.setColor(COLORS.WHITE)
end

--Centered
function geo.drawMeteredGeometry(x, y, w, h, t, fn)
	local mode,i = love.graphics.getStencilTest()
	if mode == "always" then i = -1 end
	
	local function stencilfn()
		local offset = math.lerp(h, -h, t)
		love.graphics.rectangle("fill", x-w/2, y+offset, h, (h/2)-offset)
	end
	love.graphics.stencil(stencilfn, "increment")
	love.graphics.setStencilTest("greater", i+1)
	fn(x,y,t)
	love.graphics.stencil(stencilfn, "decrement")

	if i == -1 then
		love.graphics.setStencilTest()
	else
		love.graphics.setStencilTest(mode, i)
	end

	love.graphics.setColor(COLORS.WHITE)
end

function geo.drawArrow(x,y,dir,length, tip_length, spread)
	local dx = length * math.cos(math.rad(dir))
	local dy = -length * math.sin(math.rad(dir))
	local dx2 = tip_length * math.cos(math.rad((dir+180-spread)%360))
	local dy2 = -tip_length * math.sin(math.rad((dir+180-spread)%360))
	local dx3 = tip_length * math.cos(math.rad((dir+180+spread)%360))
	local dy3 = -tip_length * math.sin(math.rad((dir+180+spread)%360))
	love.graphics.line(x-dx,y-dy,x+dx,y+dy)
	love.graphics.line(x+dx+dx2,y+dy+dy2,x+dx,y+dy,x+dx+dx3,y+dy+dy3)
end

--Currently ignores R
function geo.inbounds(x,y,minX,minY,maxX,maxY,r)
	return x >= minX and x <= maxX and y >= minY and y <= maxY
end