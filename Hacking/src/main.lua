require "constants"
require "strings"
require "tuning"

require "engine/class"
require "engine/assets"
require "engine/transform"
require "engine/widget"
require "engine/widgets/box"
require "engine/widgets/circle"
require "engine/widgets/image"
require "engine/widgets/text"
require "engine/widgets/button"
require "engine/widgets/screen"
require "engine/prefab"
require "engine/inputhandler"

debug_str = ""
p_debug_str = ""

print = function(msg)
	msg = msg or ""
	debug_str = debug_str..tostring(msg).."\n"
end

--Persistent
p_print = function(msg)
	msg = msg or ""
	p_debug_str = p_debug_str..tostring(msg).."\n"
end

p_clear = function()
	p_debug_str = ""
end

clear = function()
	debug_str = ""
end

function love.load()
	math.randomseed(os.time())
	
	love.window.setTitle(STRINGS.WINDOW_TITLE)
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { fullscreen=FULLSCREEN, msaa=MSAA })
	WINDOW_WIDTH = love.graphics.getWidth()
	WINDOW_HEIGHT = love.graphics.getHeight()

	MID_X = WINDOW_WIDTH / 2
	MID_Y = WINDOW_HEIGHT / 2

    love.filesystem.mount(love.filesystem.getSourceBaseDirectory(),"base")
    p_print(love.filesystem.getSaveDirectory())

	--time_acc = 0

	LoadTexture("images/logo")

	local Assets = require "game/assets"
	for i,v in ipairs(Assets.images) do
		LoadTexture(v)
	end

	--Init
	ROOT = Widget("ROOT",0,0)

	if SPLASH then
		Logo = Image(MID_X, MID_Y, "logo", "tex")

		ROOT:AddChild(Logo)

		Logo:AddComponent("fader")

		Logo.components.fader:Fade(3, true, function()
			Logo.components.fader:Fade(1, false, require("game/init"))
		end)
	else
		require("game/init")()
	end
end

function love.keypressed(key,scancode,isrepeat)
	if key=="escape" then
		love.event.quit()
	end
	InputHandler:OnKeypress(key, scancode, isrepeat)
end

function love.wheelmoved(x, y)
	InputHandler:OnScroll(y)
end

function love.mousepressed(x, y, button, istouch)
	InputHandler:OnClick(x, y, button, istouch)
end

function love.update(dt)
	--time_acc = time_acc + dt

	clear()
	print("FPS "..love.timer.getFPS())


	if UpdateCallback then UpdateCallback(dt) end

	--Update
	ROOT:Update(dt)

	for i,v in ipairs(GlobalPrefabs) do
		v:Update(dt)
	end
end

function love.draw()

	for i,v in ipairs(GlobalPrefabs) do
		love.graphics.push()
		local x, y = v.Transform:GetAbsolutePosition()
		love.graphics.translate(x, y)

		v:Draw()

		love.graphics.pop()
		love.graphics.setColor(COLORS.WHITE)
		love.graphics.setLineWidth(1)
	end

	ROOT:Draw()

	if DEBUG then
		love.graphics.setColor(DEBUG_TEXT_COLOR)
		love.graphics.print(debug_str..p_debug_str, 0, 0)
		love.graphics.setColor(COLORS.WHITE)
	end
end