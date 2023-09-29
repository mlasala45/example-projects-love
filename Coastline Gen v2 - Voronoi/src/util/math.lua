function math.dist(a,b)
	return math.sqrt(a*a + b*b)
end

function math.lerp(a,b, t)
	return (1 - t)*a + t*b;
end

--Returns in degrees
function math.angle(x, y)
	local angle = math.deg(math.atan(y/x)) % 90
	--angle = 90-angle


	if(x < 0) then
		if(y < 0) then
			return angle + 180
		else
			return angle + 90
		end
	else
		if(y < 0) then
			return angle + 270
		else
			return angle
		end
	end
end

local oldfn = math.angle
math.angle = function(x,y)
	return 360 - oldfn(x,y)
end