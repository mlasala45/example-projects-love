if OVERRIDE_BINDING_IP then return end

local socket = require "socket"
local client = socket.udp()
client:settimeout(0)
client:setpeername("240.0.0.1", 80) --Connect to a reserved address outside of the network
local socket_name = client:getsockname()
if socket_name then
    local address, port_str = string.match(socket_name, "(.*):(.*)")
    if not address then
        address = socket_name
        port_str = "12345"
    end
    BINDING_IP = address
    BINDING_PORT = tonumber(port_str)
else
    print("Failed to acquire ipconfig")
end