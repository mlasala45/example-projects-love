require "constants"
require "strings"
require "tuning"

local socket = require "socket"
local http = require("socket.http")

debug_str = ""
debug2_str = ""
p_debug_str = ""

t_print = function(msg)
	msg = msg or ""
	debug_str = debug_str..tostring(msg).."\n"
end

t2_print = function(msg)
	msg = msg or ""
	debug2_str = debug2_str..tostring(msg).."\n"
end

--Persistent
p_print = function(msg)
	msg = msg or ""
	p_debug_str = p_debug_str..tostring(msg).."\n"
	print(msg) --TODO: Add prefix for p_print?
end

p_clear = function()
	p_debug_str = ""
end

clear = function()
	debug_str = ""
	debug2_str = ""
end

local thread, channel_fromThread, channel_toThread

CLIENT = nil
ERR = nil

function love.load()
	local startTime = os.time()

	math.randomseed(os.time())
	
	love.window.setTitle(STRINGS.WINDOW_TITLE)
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { fullscreen=FULLSCREEN, msaa=MSAA, highdpi=true })
	WINDOW_WIDTH = love.graphics.getWidth()
	WINDOW_HEIGHT = love.graphics.getHeight()

	MID_X = WINDOW_WIDTH / 2
	MID_Y = WINDOW_HEIGHT / 2

	p_print("SERVER")

	love.filesystem.mount(love.filesystem.getSourceBaseDirectory(),"base")
	--p_print(love.filesystem.getSaveDirectory())

	--[[local myFont = love.graphics.newFont( "arial.ttf", 64 )
	myFont:setFilter( "nearest", "nearest" )
	love.graphics.setFont(myFont)]]


	--Init

	require "util/get_local_ip_address"
	p_print(string.format("Detected local address to be %s:%s", BINDING_IP, BINDING_PORT))

	REQUEST_BATCH_SIZE = 0

	--XML Loading
	require "card_loader"

	local files = love.filesystem.getDirectoryItems("data")
	for _,v in ipairs(files) do
		LoadCardSet(v)
	end

	--
	-- EDIT HERE FOR GROUP NAMES
	--

	CARD_GROUPS = { 'Character', "Stand", "Action", "Event", "Composite" }

	SAMPLE_DECKS = {}
	local cards_by_type = {}
	for _,v in ipairs(CARD_GROUPS) do cards_by_type[v] = {} end
	for _,set in pairs(CARD_SETS) do
		for name,card in pairs(set) do
			local card_type = card.type:match("([a-zA-Z]*) - ")
			if not card_type then card_type = card.type end
			if card_type then
				--Temporary Fix

				--
				-- EDIT HERE FOR GROUPING STANDARDS
				--

				--TODO: Add Stand group logic

				if card_type == "Trickery" or card_type == "Disguise" then card_type = "Action" end
				if card_type == "Story" then card_type = "Event" end

				if card_type == "Field" or card_type == "Field Modifier" or card_type == "Object" or card_type == "Mount" then
					card_type = "Composite"
				end

				if cards_by_type[card_type] or card_type == "Composite" then
					table.insert(cards_by_type[card_type], card)
				else
					print(string.format("ERR: Unknown Type detected for card '%s': '%s'",name,card_type))
				end
			else
				--Unreachable
				print(string.format("ERR: No Type detected for card '%s'",name))
			end
		end
	end

	local maxDeckSize = 40
	for _,cards_type in ipairs(CARD_GROUPS) do
		local group = {}

		local startIndex = 1
		local doneWithType = false
		repeat
			local deck = {}
			for i=0,maxDeckSize-1 do
				local card = cards_by_type[cards_type][startIndex+i]
				if card then
					table.insert(deck, card)
				else
					doneWithType = true
					break
				end
			end
			table.insert(group, deck)
			startIndex = startIndex + maxDeckSize
		until doneWithType
		print(string.format("Generated %s Sample Decks for group '%s', out of %s cards", #group, cards_type, #cards_by_type[cards_type]))
		SAMPLE_DECKS[cards_type] = group
	end
	SELECTED_GROUP = 1
	SELECTED_DECK = 1
	
	--Multithreading

	channel_fromThread = love.thread.getChannel("thread-to-main")
	channel_toThread = love.thread.getChannel("main-to-thread")

	thread = love.thread.newThread("thread-main.lua")
	thread:start(BINDING_IP, BINDING_PORT)

	print(string.format("Init Completed in %sms",os.time()-startTime))

	p_print(LINE_BR)
end

function love.keypressed(key,scancode,isrepeat)
	if key=="escape" then
		love.event.quit()
	end

	if key=="left" then
		SELECTED_DECK = SELECTED_DECK - 1
		if SELECTED_DECK < 1 then
			SELECTED_GROUP = SELECTED_GROUP - 1
			if SELECTED_GROUP < 1 then
				SELECTED_GROUP = #CARD_GROUPS
			end
			local group_name = CARD_GROUPS[SELECTED_GROUP]
			SELECTED_DECK = #SAMPLE_DECKS[group_name]
		end
	end
	if key=="right" then
		local group_name = CARD_GROUPS[SELECTED_GROUP]
		SELECTED_DECK = SELECTED_DECK + 1
		if SELECTED_DECK > #SAMPLE_DECKS[group_name] then
			SELECTED_GROUP = SELECTED_GROUP + 1
			if SELECTED_GROUP > #CARD_GROUPS then
				SELECTED_GROUP = 1
			end
			SELECTED_DECK = 1
		end
	end

	--OS Agnostic Copy Command
	local osString = love.system.getOS()

	local control

	if osString == "OS X" then
		control = love.keyboard.isDown("lgui","rgui")
	elseif osString == "Windows" or osString == "Linux" then
		control = love.keyboard.isDown("lctrl","rctrl")
	end

	if control then
		if key == "c" then
			CopySampleDeckToClipboard()
		end
	end
end

function CopySampleDeckToClipboard()
	local buffer = ""
	local function addLine(line) buffer = buffer..line.."\n" end

	local group_name = CARD_GROUPS[SELECTED_GROUP]
	local deck = SAMPLE_DECKS[group_name][SELECTED_DECK]

	addLine("Deck")
	for _,card in pairs(deck) do
		local modifiedcardname = card.name:gsub("[)(]","")
		addLine("1 "..modifiedcardname)
	end

	love.system.setClipboardText(buffer)

	table.insert(DATA_QUEUE, string.format("Copied sample Deck %s:%s to Clipboard",group_name,SELECTED_DECK))
end

function love.mousepressed(x, y, button, istouch)
	--
end

DATA_QUEUE = {}
TOTAL_PACKETS_RECEIVED = 0

CLIENT_NAME = nil
REQUEST_QUEUE = {}

local data, msg_or_ip, port_or_nil
function love.update(dt)

	--time_acc = time_acc + dt

	clear()
	t_print("FPS "..love.timer.getFPS())

	--Update

	local copyHotkey
	local osString = love.system.getOS()
	if osString == "OS X" then
		copyHotkey = "Cmd+C"
	elseif osString == "Windows" or osString == "Linux" then
		copyHotkey = "Ctrl+C"
	end

	local selected_group_name = CARD_GROUPS[SELECTED_GROUP]
	t_print(string.format("Press %s to copy a sample Deck to the Clipboard",copyHotkey))
	t_print(string.format("\t(Group %s: %s - Deck %s of %s)", SELECTED_GROUP, selected_group_name, SELECTED_DECK, #SAMPLE_DECKS[selected_group_name]))
	t_print("(Left and Right to switch between decks)")
	t_print(LINE_BR)


	if not PREVENT_UPDATES then

		local t
		if not ip then
			t = channel_fromThread:demand()
			ip, port = unpack(t)
		end

		t_print("Listening on IP="..tostring(ip)..", PORT="..tostring(port).."...")

		if not t then
			t = channel_fromThread:pop()
		end
		if t then
			if t.msg == "client-name" then
				CLIENT_NAME = t.peername
				print("Connection Established: "..CLIENT_NAME)
			elseif t.msg == "connection-closed" then
				print("Connection Closed")
			elseif t.msg == "data-received" then
				local line = tostring(t.line)
				local err = tostring(t.err)

				--TODO: Match line with GET / HTTP/1.1
				local request = string.match(line, 'GET ([%w%p\\_]*) HTTP/[0-9\\.]*')
				if request then
					print("Request Detected: "..request)
					table.insert(REQUEST_QUEUE, request)
				end

				--p_print(CLIENT_NAME.." -> "..line)
				if err ~= nil and err ~= "nil" then p_print("ERR: "..err) end
			elseif t.msg == "error" then
				p_print(string.format("ERROR: Failed to bind to address %s:%s", BINDING_IP, BINDING_PORT))
				PREVENT_UPDATES = true
			end
		end

		while #REQUEST_QUEUE > 0 do
			if not FIRST_REQUEST_TIME then FIRST_REQUEST_TIME = os.time() end
			LAST_REQUEST_TIME = os.time()
			REQUEST_BATCH_SIZE = REQUEST_BATCH_SIZE + 1

			local active_request = REQUEST_QUEUE[1]
			table.remove(REQUEST_QUEUE, 1)

			local content_type, content
			if active_request:match(".png") then
				content_type = "image/png"
				print("PNG Request Detected")

				local path = active_request:gsub("%%20"," ")
				path = path:gsub("[')()]","") --MSE Removes these characters on image export
				content = love.filesystem.read(path)
				if not content then print("Could not find matching file") end
			elseif active_request:match(".jpg") then
				content_type = "image/jpeg"
				print("JPG Request Detected")
				local path = active_request:gsub("%%20"," ")
				content = love.filesystem.read(path)
				if not content then print("Could not find matching file") end
			else
				print("Defaulting to JSON Request")
				content_type = "application/json"

				local cardName = active_request:match("/?q=(.*)")
				if cardName then
					cardName = cardName:gsub("%%20", ' ')
				end

				print(string.format("Card '%s' Requested", cardName))

				require "card_json_generator"

				local cardData, cardSetName
				for setname, set in pairs(CARD_SETS) do
					for cardname_loop,data in pairs(set) do
						if cardname_loop:gsub("[])(]","") == cardName then
							cardData = data
							cardSetName = setname
							break
						end
					end
					if cardData then break end
				end
				if cardData then
					print(string.format("Found match in set '%s'",cardSetName))
					content = GenerateCardJSON(cardSetName, cardData)
				else
					print("No matching card found")
				end
			end

			if not content then content = "" end
			if content_type then
				print("Queueing Response from Main")
				channel_toThread:push({
					msg="send-response",
					content_type=content_type,
					content=content
				})
			end
		end

		--TODO: Could refactor this a bit, but it works fine
		if FIRST_REQUEST_TIME then
			local dt = os.time() - LAST_REQUEST_TIME
			local batchLength = LAST_REQUEST_TIME - FIRST_REQUEST_TIME
			if dt > 2000 then
				table.insert(DATA_QUEUE, string.format("Processed %s requests in %s",REQUEST_BATCH_SIZE,batchLength))

				FIRST_REQUEST_TIME = nil
				LAST_REQUEST_TIME = nil
				REQUEST_BATCH_SIZE = 0
			elseif batchLength > 5000 then
				--If batches are long enough, they get split up in logging
				--The next request in will be the new "first", but the time since last request persists from the last batch

				table.insert(DATA_QUEUE, string.format("Processed %s requests in %s",REQUEST_BATCH_SIZE,batchLength))
				REQUEST_BATCH_SIZE = 0
				FIRST_REQUEST_TIME = nil
			end
		end

		--[[
		--local client,err = server:accept()
		if client then
			local line, err = client:receive()
			local data = line

			if data then
				TOTAL_PACKETS_RECEIVED = TOTAL_PACKETS_RECEIVED + 1

				table.insert(DATA_QUEUE, 1, data)
				if #DATA_QUEUE > 10 then
					DATA_QUEUE[#DATA_QUEUE] = nil
				end
			end
		end]]

		--[[
		data, msg_or_ip, port_or_nil = udp:receivefrom()
		if data then
			TOTAL_PACKETS_RECEIVED = TOTAL_PACKETS_RECEIVED + 1

			table.insert(DATA_QUEUE, 1, data)
			if #DATA_QUEUE > 10 then
				DATA_QUEUE[#DATA_QUEUE] = nil
			end
		end]]

		while #DATA_QUEUE > DATA_QUEUE_SIZE do
			table.remove(DATA_QUEUE,1)
		end

		t_print("Total Packets Received: "..TOTAL_PACKETS_RECEIVED)
		for i,v in ipairs(DATA_QUEUE) do
			t2_print(v)
		end

		socket.sleep(0.01)

	end
end

function love.draw()
	--

	if DEBUG then
		love.graphics.setColor(DEBUG_TEXT_COLOR)
		love.graphics.print(debug_str..p_debug_str..debug2_str, 0, 0)
		love.graphics.setColor(COLORS.WHITE)
	end
end