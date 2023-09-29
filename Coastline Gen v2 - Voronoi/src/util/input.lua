KeysDown = {}

function HandleKeyDown(keycode)
	local firstFrameDown = false
	if love.keyboard.isDown(keycode) then
		if not KeysDown[keycode] then firstFrameDown = true end
		KeysDown[keycode] = true
	else
		KeysDown[keycode] = false
	end

	return firstFrameDown
end