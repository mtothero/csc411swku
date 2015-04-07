--[[/************************************************************/
/* Author:  Dave Clymer, Matt Tothero                           */
/* Creation Date: March 2014                                    */
/* Modification Date: 4/7/2015                                  */
/* Course: CSC411                                               */
/* Professor Name: Dr. Frye                                     */
/* Filename: multiplayerSetup                                   */
/* Purpose: Serves as the multiplayer lobby. Allows clients     */
/*          to connect to servers.                              */
/* NOTE: More inline documentation has been provided here since */
/*       this file contains alot of networking concepts         */
/*       that pertain to this assignment.                       */
/************************************************************/--]]

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )

local backButton, background, settingsButton, onePlayerButton, twoPlayerButton
local highScoreButton, createButton, tableView
local customFont
local client, server, isClient, isServer, myPlayerID, playerDropped, clientDropped
local numPlayers, clients, numberOfServers, connectionAttemptFailed

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    --insert background
    background = display.newImage("Assets/multiBackground.png")
    background.x = display.contentWidth/2
    background.y = display.contentHeight*.45
    background.id = "background"    
    group:insert(background)

    --hardware back button, when touched go back to main menu
    function onKeyEvent( event )
        local phase = event.phase;
        local keyName = event.keyName;
        if ( "back" == keyName and phase == "up" ) then
            tableView = nil
            createButton = nil
            storyboard.hideOverlay( "fade", 200 )
            return true
        end
        return false
    end

    -- init networking values to 0
    numPlayers = 0                  -- number of players connected to a server
    clients = {}                    -- client table, used to keep track of clients
    numberOfServers = 0             -- number of servers found
end


--- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    -- upon entry, always make the user a client, this allows users to view
    -- other servers, if a user wants to be a server, clicking the create
    -- button deletes his/her associated client object
    makeClient() 
    
    -- listener adds a server entry to the tableview
    Runtime:addEventListener("autolanServerFound", createListItem)

    -- listener that notifies a client if it successfully connected to a server
    Runtime:addEventListener("autolanConnected", connectedToServer)

    -- Create button listener, removes client, and makes it a server
    local function handleCreatePress( event )
       if ( "ended" == event.phase ) then
            makeServer()
            createButton:setEnabled( false )
        end
    end
    createButton = widget.newButton
    {
        x = (display.contentWidth)/2,
        y = (display.contentHeight)*(2/3),
        width = 210,
        height = 80,
        defaultFile = "Assets/createButton.png",
        overFile = "Assets/createButtonPressed.png",
        onEvent = handleCreatePress
    }

    --TableView, render listener - used to display the content
    local function onRowRender( event )
        local row = event.row
        local rowHeight = row.contentHeight
        local rowWidth = row.contentWidth

        local gameRoomName = display.newText(row, row.params.gameRoomName, 0, 0, customFont, 40 )
        gameRoomName:setFillColor( 1 )
        gameRoomName.x = 140
        gameRoomName.y = row.height * 0.5

        local ip = display.newText(row, row.params.description, 0, 0, customFont, 40 )
        ip:setFillColor( 1 )
        ip.x = 650 
        ip.y = row.height * 0.5 
    end

    -- Tableview, row touch listener - if clicked, connect to server
    local function onRowTouch( event )
        local row = event.row
        client:connect(row.params.serverIP)
    end

    -- tableview, used to display the list of servers
    local options =
    {
        left = 545,
        top = 300,
        width = 800,
        height = 400,
        backgroundColor = { 1,1,1,.5},
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
    }
    tableView = widget.newTableView( options )

    -- inserts a server entry into the tableview
    function insertARow(serverName, customBroadcast, serverIP)
        tableView:insertRow
        {
            rowColor = { default = { 255, 255, 255, 0 }},
            lineColor = { 1, 1, 1 },
            rowHeight = 100,
            params = { gameRoomName = serverName, description = customBroadcast, serverIP = serverIP},
        }
        numberOfServers = numberOfServers+1
    end

    -- Settings button event listener, dummy button, blur effect
    local function handleSettingsPress( event )
        
    end
    settingsButton = widget.newButton
    {
        x = (display.contentWidth)*(4/5),
        y = (display.contentHeight)*.87,
        width = 210,
        height = 80,
        defaultFile = "Assets/settings_button_BLUR.png",
        overFile = "Assets/settings_button_BLUR.png",
        onEvent = handleSettingsPress
    }

    -- one player button event listener, dummy button, blur effect
    local function handle1PlayerPress( event )
        
    end
    onePlayerButton = widget.newButton
    {
        x = display.contentWidth*(1/5),
        y = (display.contentHeight)*.87,
        width = 210,
        height = 80,
        defaultFile = "Assets/onePlayerBlurred.png",
        overFile = "Assets/onePlayerBlurred.png",
        onEvent = handle1PlayerPress
    }

    -- two player button event listener, dummy button, blur effect
    local function handle2PlayerPress( event )
        
    end
    twoPlayerButton = widget.newButton
    {
        x = display.contentWidth*(2/5),
        y = (display.contentHeight)*.87,
        width = 210,
        height = 80,
        defaultFile = "Assets/twoPlayerBlurred.png",
        overFile = "Assets/twoPlayerBlurred.png",
        onEvent = handle2PlayerPress
    }

    -- high score button event listener, dummy button, blur effect
    local function handleHighScorePress( event )

    end
    highScoreButton = widget.newButton
    {
        x = display.contentWidth*(3/5),
        y = (display.contentHeight)*.87,
        width = 210,
        height = 80,
        defaultFile = "Assets/highscore_button_BLUR.png",
        overFile = "Assets/highscore_button_BLUR.png",
        onEvent = handleHighScorePress
    }

    -- Function to handle back button, deletes all active listeners
    -- If server, closes server
    -- If client, closes client
    local function handleBackPress( event )
        if ( "ended" == event.phase ) then
            Runtime:removeEventListener("autolanConnectionFailed", connectionAttemptFailed)
            Runtime:removeEventListener("autolanDisconnected", connectionAttemptFailed)
            Runtime:removeEventListener("autolanPlayerJoined", addPlayer)
            Runtime:removeEventListener("autolanServerFound", createListItem)
            Runtime:removeEventListener("autolanConnected", connectedToServer)
            if(isServer) then
                server:disconnect( )
                server:stop()
            end
            if(isClient) then
                client:disconnect( )
            end
            storyboard.hideOverlay( "fade", 200 )
        end
    end
    backButton = widget.newButton
    {
        x = 1375,
        y = 162,
        width = 70,
        height = 70,
        defaultFile = "Assets/invisible.png",
        overFile = "Assets/invisible.png",
        onEvent = handleBackPress
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
    Runtime:removeEventListener("autolanConnectionFailed", connectionAttemptFailed)
    Runtime:removeEventListener("autolanDisconnected", connectionAttemptFailed)
    Runtime:removeEventListener("autolanPlayerJoined", addPlayer)
    Runtime:removeEventListener("autolanServerFound", createListItem)
    Runtime:removeEventListener("autolanConnected", connectedToServer)
    Runtime:removeEventListener( "handleCreatePress", onEvent )
    Runtime:removeEventListener( "handleFindPress", onEvent )
    Runtime:removeEventListener( "handleBackPress", onEvent )
    Runtime:removeEventListener( "handle1PlayerPress", onEvent )
    Runtime:removeEventListener( "handle2PlayerPress", onEvent )
    Runtime:removeEventListener( "handleHighScorePress", onEvent )
    Runtime:removeEventListener( "handleSettingsPress", onEvent )
    Runtime:removeEventListener( "key", onKeyEvent )
end

-- Called when new scene has transitioned in
function scene:didExitScene( event )
    tableView:removeSelf( )
    tableView = nil
    createButton:removeSelf( )
    createButton = nil
    backButton:removeSelf( )
    backButton = nil
    settingsButton:removeSelf()
    settingsButton = nil
    highScoreButton:removeSelf()
    highScoreButton = nil
    onePlayerButton:removeSelf()
    onePlayerButton = nil
    twoPlayerButton:removeSelf( )
    twoPlayerButton = nil
    background:removeSelf( )
    background = nil
    storyboard.removeScene( "multiPlayerSetupScreen" )
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    local group = self.view
end

-- When the user clicks the create button, makeServer is executed
-- this makes the user a server by starting up the server object
-- created by the AutoLan library, it then creates the appropriate
-- listeners for the server
function makeServer()
    if(isClient) then --if we were a client before, we need to unregister all the event listeners
        isClient = false
        Runtime:removeEventListener("autolanConnectionFailed", connectionAttemptFailed)
        Runtime:removeEventListener("autolanDisconnected", connectionAttemptFailed)
    end

    server = require("Server")
    server:setCustomBroadcast("1 V 1") 
    server:start()
    isServer = true

    --add event listeners, checks when a player is added
    Runtime:addEventListener("autolanPlayerJoined", addPlayer)
end

-- if a user wants to play multiplayer, he/she is automatically set as a client
-- client:start() inits the client and client:scanServers() searches for servers
-- appropriate listeners are also created
function makeClient()
    if(isServer) then --if we were a server before, we need to unregister all the event listeners
        isServer = false
    end
    client = require("Client")
    client:start()
    client:scanServers()
    isClient = true
    Runtime:addEventListener("autolanConnectionFailed", connectionAttemptFailed)
    Runtime:addEventListener("autolanDisconnected", connectionAttemptFailed)
end

-- event handler for when a server is found
function createListItem(event) --displays found servers
    insertARow(event.serverName,event.customBroadcast,event.serverIP)
end

-- SERVER ACCEPTANCE CODE
-- if a client connects to a server, this handler gets executed
-- allows a server to accept a client invite or reject it
addPlayer = function(event)
    local client = event.client --this is the client object, used to send messages
    local function onComplete( event )
    if event.action == "clicked" then
            local i = event.index
            if i == 2 then
                print("player joined",client)
                --look for a client slot
                numPlayers = numPlayers+1
                clients[numPlayers] = client
                local options =         
                {       
                    params = { var1 = "nothing", var2 = server, var3 = clients, var4 = numPlayers}        
                }       
                storyboard.gotoScene( "MultiGameScreen", options ) 
                for i=1, numPlayers 
                    do clients[i]:sendPriority({1,1})
                end
            elseif i == 1 then
                client:disconnect()
                client = nil
            end
        end
    end
    native.showAlert( "Request", "Some wants to attack your house! Will you accept this request?", { "No", "Yes" }, onComplete )
end

-- CLIENT ACCEPTANCE CODE
-- if a client successfully connects to a server, it is sent to the multiplayer game
-- screen, it then waits for the server to acknowledge its invite
function connectedToServer(event)
    print("connected, waiting for sync")
    local options =         
    {       
        params = { var1 = client, var2 = "nothing", var3 = "mothing", var4 = numPlayers}        
    }       
    storyboard.gotoScene( "MultiGameScreen", options ) 
end

-- if connection was not successful
connectionAttemptFailed = function(event)
    print("connection failed")
end

scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )

scene:addEventListener( "destroyScene", scene )

scene:addEventListener( "didExitScene", scene )

return scene