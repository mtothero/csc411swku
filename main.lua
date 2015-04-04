display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local storyboard = require "storyboard"

-- load first screen
storyboard.gotoScene( "loadingScreen" )


----------------------------------------------------------------------------------------------------------
----------------------------Client Specific Listeners-----------------------------------------------------
----------------------------------------------------------------------------------------------------------
local function autolanConnected(event)
	print("broadcast", event.customBroadcast) --this is the user defined broadcast recieved from the server, it tells us about the server state.
	print("serverIP," ,event.serverIP) --this is the user defined broadcast recieved from the server, it tells us about the server state.
	print("connection established")
end
Runtime:addEventListener("autolanConnected", autolanConnected)

local function autolanServerFound(event)
	print("broadcast", event.customBroadcast) --this is the user defined broadcast recieved from the server, it tells us about the server state.
	print("server name," ,event.serverName) --this is the name of the server device (from system.getInfo()). if you need more details just put whatever you need in the customBrodcast
	print("server IP:", event.serverIP) --this is the server IP, you must store this in an external table to connect to it later
	print("autolanServerFound")
end
Runtime:addEventListener("autolanServerFound", autolanServerFound)

local function autolanDisconnected(event)
	print("disconnected b/c ", event.message) --this can be "closed", "timeout", or "user disonnect"
	print("serverIP ", event.serverIP) --this can be "closed", "timeout", or "user disonnect"
	print("autolanDisconnected") 
end
Runtime:addEventListener("autolanDisconnected", autolanDisconnected)

local function autolanConnectionFailed(event)
	print("serverIP = ", event.serverIP) --this indicates that the server went offline between discovery and connection. the serverIP is returned so you can remove it form your list
	print("autolanConnectionFailed")
end
Runtime:addEventListener("autolanConnectionFailed", autolanConnectionFailed)

----------------------------------------------------------------------------------------------------------
----------------------------Server Specific Listeners-----------------------------------------------------
----------------------------------------------------------------------------------------------------------
local function autolanPlayerJoined(event)
	print("client object: ", event.client) --this represents the connection to the client. you can use this to send messages and files to the client. You should save this in a table somewhere.
	print("autolanPlayerJoined") 
end
Runtime:addEventListener("autolanPlayerJoined", autolanPlayerJoined)

local function autolanPlayerDropped(event)
	print("client object ", event.client) --this is the reference to the client object you use to send messages to the client, you can use this to findout who dropped and react accordingly
	print("dropped b/c ," ,event.message) --this is the user defined broadcast recieved from the server, it tells us about the server state.
	print("autolanPlayerDropped")
end
Runtime:addEventListener("autolanPlayerDropped", autolanPlayerDropped)
