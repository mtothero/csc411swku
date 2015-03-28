local multiHandler = {}
local socket = require( "socket" ) 

function multiHandler:getIP() 
    local s = socket.udp()  --creates a UDP object
    s:setpeername( "74.125.115.104", 80 )  --Google website
    local ip, sock = s:getsockname()
    print( "myIP:", ip, sock )
    return ip
end

return multiHandler