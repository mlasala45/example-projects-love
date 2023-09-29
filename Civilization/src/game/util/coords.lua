--Conventions:
  --World: Pixel coords used by LOVE
  --Cartesian: X,Y coords used by the map to store and refer to cell positions
  --Trifold: X,Y,Z coords used for positional arithmetic (hex grid = three axes)

function CartesianToWorld(x, y)
	local wx = x * HEX_RADIUS_SHORT*2
	local wy = -y * HEX_RADIUS*1.5
	if y % 2 == 1 then wx = wx + HEX_RADIUS_SHORT end
	return wx, wy
end

function WorldToCartesian(x, y)
	local tx, ty, tz = WorldToTrifold(x, y)
	return TrifoldToCartesian(tx, tz)
end

function TrifoldToCartesian(x, z)
	local cx = x + math.floor(z/2)
	local cy = z
	return cx, cy
end

function CartesianToTrifold(x, y)
	local tx = x - math.floor(y/2)
	local tz = y
	return tx, -tx-tz, tz
end

function WorldToTrifold(x, y)
	x = x - HEX_RADIUS_SHORT
	y = y - HEX_RADIUS
	local tx = x / (HEX_RADIUS_SHORT * 2)
	local ty = -tx;

	local offset = y / (HEX_RADIUS * 3)
	tx = tx - offset
	ty = ty - offset

	local iX = math.round(tx)
	local iY = math.round(ty)
	local iZ = math.round(-tx-ty)

	if iX + iY + iZ ~= 0 then
		local dX = math.abs(tx - iX)
		local dY = math.abs(ty - iY)
		local dZ = math.abs(-tx-ty - iZ)

		if dX > dY and dX > dZ then
			iX = -iY - iZ
		elseif dZ > dY then
			iZ = -iX - iY
		end
	end

	return iX, iY, iZ
end

function HexVerts(x, y, sx, sy)
	sx = sx or 1
	sy = sy or sx
	local t = {
		0, HEX_RADIUS,
		HEX_RADIUS_SHORT, HEX_RADIUS/2,
		HEX_RADIUS_SHORT, -HEX_RADIUS/2,
		0, -HEX_RADIUS,
		-HEX_RADIUS_SHORT, -HEX_RADIUS/2,
		-HEX_RADIUS_SHORT, HEX_RADIUS/2,
	}
	for i,v in ipairs(t) do
		if i%2==1 then
			t[i] = t[i]*sx + x
		else
			t[i] = t[i]*sy + y
		end
	end
	return t
end