local BINDING_IP, BINDING_PORT = ...

local socket = require "socket"

channel_toThread = love.thread.getChannel("main-to-thread")
channel_fromThread = love.thread.getChannel("thread-to-main")

server = socket.tcp()
--server:settimeout(0)
local bind_err = false
if not server:bind(BINDING_IP, BINDING_PORT) then
	bind_err = true
	channel_fromThread:push({msg="error"})
	return false
end
server:listen(4096)

local ip, port = server:getsockname()
channel_fromThread:push({ ip, port })


local client, err

function SendResponse(data)
	--local content = require "template_card"

	--local htmlcontent = require "monkey"

	local function sendLine(line)
		client:send(line.."\n")
	end

	print("Sending Response From Thread")

	sendLine("HTTP/1.1 200 OK")
	sendLine("Content-Type: "..data.content_type.."; charset=utf-8")
	--sendLine("Content-Type:text/html; charset=utf-8")
	sendLine("Connection: Close")
	sendLine("Content-Length: "..#(data.content))
	sendLine("")
	sendLine(data.content)
	--sendLine(htmlcontent)
end

local lines_received = 0

while true do
	if not client then
		client,err = server:accept()

		channel_fromThread:push({ msg="client-name", peername=client:getpeername() })
	end

	if client then
		if lines_received < 20 then
			local line,err = client:receive()
			if line then
				if #line == 0 then lines_received = 100 end
				channel_fromThread:push({msg="data-received", line=line,err=err})
				--print("Line: (len:"..#line..") "..line)
				lines_received = lines_received + 1
			end
		else
			local t = channel_toThread:pop()
			if t then
				if t.msg == "send-response" then
					SendResponse(t)
					lines_received = 0
					channel_fromThread:push({msg="connection-closed"})
					client = nil
				end
			end
		end
		--[[SendResponse()
		lines_received = 0
		channel_fromThread:push({msg="connection-closed"})
		client = nil]]
	end
end