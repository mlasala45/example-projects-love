renderutil = {}

local offsets = {
	{ x=1, z=-1 },
	{ x=1, z=0 },
	{ x=0, z=1 },
	{ x=-1, z=1 },
	{ x=-1, z=0 },
	{ x=0, z=-1 },
}

function renderutil.createbordersegmenttable(map, territory)
	local borders = {}
	for i,v in ipairs(territory) do
		local tx, ty, tz = CartesianToTrifold(v.x, v.y)
		for i=1,6 do
			local cx, cy = TrifoldToCartesian(tx+offsets[i].x, tz+offsets[i].z)
			if not table.contains(territory, map:GetCell(cx, cy)) then
				table.insert(borders, { x1=v.x, y1=v.y, i=i })
			end
		end
	end
	return borders
end

function renderutil.drawbordersegments(map, borders, color, linewidth)
	linewidth = linewidth or 4
	for i,v in ipairs(borders) do
		wx, wy = map:GetHexCenter(v.x1, v.y1)
		local verts = HexVerts(wx, wy, TheCamera.sx, TheCamera.sy)
		local nxt = v.i+1
		if nxt > 6 then nxt = 1 end

		love.graphics.setLineWidth(linewidth)
		love.graphics.setColor(color)
		love.graphics.line(verts[((v.i-1)*2)+1], verts[((v.i-1)*2)+2], verts[((nxt-1)*2)+1], verts[((nxt-1)*2)+2])
	end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(COLORS.WHITE)
end