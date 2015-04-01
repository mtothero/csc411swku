local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local multiHandler = require( "multiHandler" )

local background
local customFont
local client, server, clients, numPlayers


-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    local aParams = event.params

    if aParams then
        client = aParams.var1
        server = aParams.var2
        clients = aParams.var3
        numPlayers = aParams.var4

        if ( client == "nothing" ) then
             Runtime:addEventListener("autolanReceived", serverReceived);
        end

        if ( server == "nothing" ) then
           Runtime:addEventListener("autolanReceived", clientReceived);
        end

        print (aParams.var1)
        print (aParams.var2)
        print (aParams.var3)
        print (aParams.var4)
    end

    --insert background
    background = display.newImage("Assets/map.jpg")
    background.x = display.contentWidth/2
    background.y = display.contentHeight/2  
    group:insert(background)

    --hardware back button, when touched go back to main menu
    function onKeyEvent( event )
        local phase = event.phase;
        local keyName = event.keyName;
        if ( "back" == keyName and phase == "up" ) then
            storyboard.gotoScene( "mainMenuScreen" )
            return true
        end
        return false
    end  
end


--- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    local function handleButton1Event( event )
        if ( "ended" == event.phase ) then
           client:send("THIS IS A CLIENT SEND TEST")
        end
    end
    -- Create the widget
    local button1 = widget.newButton
    {
        x = display.contentWidth*(1/3),
        y = (display.contentHeight)/2,
        id = "button1",
        label = "Client Send",
        onEvent = handleButton1Event
    }

    if "Win" == system.getInfo( "platformName" ) then
        customFont = "Lato"
    elseif "Android" == system.getInfo( "platformName" ) then
        customFont = "Lato-Bol"
    end
     
    Runtime:addEventListener( "key", onKeyEvent )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    Runtime:removeEventListener( "key", onKeyEvent )
    Runtime:removeEventListener("autolanReceived", clientReceived);
    Runtime:removeEventListener("autolanReceived", serverReceived);
end

-- Called when new scene has transitioned in
function scene:didExitScene( event )
    background:removeSelf( )
    background = nil
    storyboard.removeScene( "multiPlayerSetupScreen" )
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
end

-- CLIENT RETRIEVAL CODE
clientReceived = function(event)
    print("client received")
end

-- SERVER RETRIEVAL CODE
serverReceived = function(event)
    print("server received")

    for i=1, numPlayers 
        do clients[i]:send("THIS IS A SERVER RESPONSE TEST") 
    end

end


scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )

scene:addEventListener( "destroyScene", scene )

scene:addEventListener( "didExitScene", scene )

return scene