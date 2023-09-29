geo = {}

function geo.drawBorderedRectangle(x,y,width,height,thick, color1, color2)
	love.graphics.setColor(color1)
	love.graphics.rectangle("fill",x,y,width,height)
	love.graphics.setColor(color2)
	love.graphics.rectangle("fill",x+thick,y+thick,width-thick*2,height-thick*2)
	love.graphics.setColor(COLORS.BLACK)
	love.graphics.rectangle("line",x,y,width,height)
	love.graphics.rectangle("line",x+thick,y+thick,width-thick*2,height-thick*2)
	love.graphics.setColor(COLORS.WHITE)
end

function geo.drawBorderedCircle(x,y,radius,thick, color1, color2)
	love.graphics.setColor(color1)
	love.graphics.circle("fill",x,y,radius)
	love.graphics.setColor(color2)
	love.graphics.circle("fill",x,y,radius-thick)
	love.graphics.setColor(COLORS.BLACK)
	love.graphics.circle("line",x,y,radius)
	love.graphics.circle("line",x,y,radius-thick)
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