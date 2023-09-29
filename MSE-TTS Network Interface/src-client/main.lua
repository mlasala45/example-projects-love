require "constants"
require "strings"
require "tuning"

local socket = require "socket"

debug_str = ""
p_debug_str = ""

t_print = function(msg)
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

local address, port = "localhost", 12345

function love.load()
	math.randomseed(os.time())
	
	love.window.setTitle(STRINGS.WINDOW_TITLE)
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { fullscreen=FULLSCREEN, msaa=MSAA, highdpi=true })
	WINDOW_WIDTH = love.graphics.getWidth()
	WINDOW_HEIGHT = love.graphics.getHeight()

	MID_X = WINDOW_WIDTH / 2
	MID_Y = WINDOW_HEIGHT / 2

	p_print("CLIENT")

    love.filesystem.mount(love.filesystem.getSourceBaseDirectory(),"base")
    p_print(love.filesystem.getSaveDirectory())

    --[[local myFont = love.graphics.newFont( "arial.ttf", 64 )
	myFont:setFilter( "nearest", "nearest" )
	love.graphics.setFont(myFont)]]


	--Init
	
	p_print("Init Complete: "..tostring(os.time()))

	client = socket.tcp()
	--client:settimeout()
	client:setpeername(address, port)

	client:connect("192.168.86.188", 12345)
end

function love.keypressed(key,scancode,isrepeat)
	if key=="escape" then
		love.event.quit()
	end

	if key=="space" then
		print(client:send("Space Key Pressed - "..os.time().."\n"))
	end
end

function love.mousepressed(x, y, button, istouch)
	--
end

local data, msg_or_ip, port_or_nil
function love.update(dt)
	--time_acc = time_acc + dt

	clear()
	t_print("FPS "..love.timer.getFPS())

	--Update

	t_print("Update, before send")
	--udp:send(os.time())

	--print(client:send(os.time()))
	t_print("Connected to: "..client:getpeername())
	t_print("Update, after send")
end

function love.draw()
	--

	if DEBUG then
		love.graphics.setColor(DEBUG_TEXT_COLOR)
		love.graphics.print(debug_str..p_debug_str, 0, 0)
		love.graphics.setColor(COLORS.WHITE)
	end
end