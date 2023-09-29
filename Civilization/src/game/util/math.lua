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

function math.lerp(a, b, t)
	return a + (b-a)*t
end