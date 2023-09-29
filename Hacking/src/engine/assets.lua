ASSETS = {
	IMAGES = {},
	QUADS = {},
}

local function getPathName(path)
	local i = path:find("/[^/]*$")
	return path:sub(i+1)
end

function LoadTexture(path)
	print("Loading Texture: "..getPathName(path))
	LoadImage(path)
	LoadAtlas(path)
end

function LoadImage(path)
	file = love.filesystem.newFile("base/assets/"..path..".png")
    assert(file:open("r"))
    local imageData = love.image.newImageData(love.filesystem.newFileData(file:read(), getPathName(path)..".png"))
	local image = love.graphics.newImage(imageData)
	image:setFilter("linear", "linear")
	ASSETS.IMAGES[string.upper(getPathName(path))] = image
end

function LoadAtlas(path)
	file = love.filesystem.newFile("base/assets/"..path..".lua")
    assert(file:open("r"))
    local atlas = loadstring(file:read())()
    local quads = {}
    for k,v in pairs(atlas.textures) do
    	quads[string.upper(k)] = love.graphics.newQuad(v.x, v.y, v.w, v.h, atlas.w, atlas.h)
    end
    ASSETS.QUADS[string.upper(getPathName(path))] = quads
end

function Draw(atlas, tex, x, y, r, sx, sy, ox, oy, kx, ky)
	r = r or 0
	sx = sx or 1
	sy = sy or sx
	local texture = ASSETS.IMAGES[string.upper(atlas)]
	local quad = ASSETS.QUADS[string.upper(atlas)][string.upper(tex)]
	local _, _, w, h = quad:getViewport()
	x = x - (w/2) * sx
	y = y - (h/2) * sy
	love.graphics.draw(texture, quad, x, y, r, sx, sy, ox, oy, kx, ky)
end