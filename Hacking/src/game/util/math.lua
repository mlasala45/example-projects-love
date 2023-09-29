function math.clamp(n, min, max)
	if not min then
		if not max then return n end
		return math.min(n,max)
	elseif not max then
		return math.max(n,min)
	end
	return math.min(math.max(n, min), max)
end

function math.round(n)
	return math.floor(n + 0.5)
end

--Operates with radians
function math.polartocart(r, theta)
	local x = r * math.cos(theta)
	local y = r * math.sin(theta)
	return x, y
end

function math.carttopolar(x, y)
	local r = math.sqrt((x * x) + (y * y))
	local theta = math.atan(y / x)
	return r, theta
end

function math.lerp(a, b, t)
	return ((1 - t) * a) + (t * b);
end