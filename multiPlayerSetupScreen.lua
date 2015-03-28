local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local multiHandler = require( "multiHandler" )

local backButton, background, settingsButton, onePlayerButton, twoPlayerButton, highScoreButton, highScoresText, textGroup
local createButton, findButton, tableView, roomInputField, roomInput
local customFont
local roomName, roomIP, roomCounter


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
            storyboard.hideOverlay( "fade", 200 )
            return true
        end
        return false
    end

    roomCounter = 1
end


--- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    -- Create Button
    local function handleCreatePress( event )
       if ( "ended" == event.phase ) then
            tableView:insertRow
            {
                rowColor = { default = { 255, 255, 255, 0 }},
                lineColor = { 1, 1, 1 },
                rowHeight = 100,
                params = { input = roomIP, roomID = "GameRoom" .. roomCounter },
            }
            roomCounter = roomCounter+1
            createButton:setEnabled( false )
        end
    end
    createButton = widget.newButton
    {
        x = (display.contentWidth)/2-300,
        y = (display.contentHeight)*(2/3),
        width = 210,
        height = 80,
        defaultFile = "Assets/createButton.png",
        overFile = "Assets/createButtonPressed.png",
        onEvent = handleCreatePress
    }

    -- Find Button
    local function handleFindPress( event )
       if ( "ended" == event.phase ) then
            tableView:insertRow
            {
                rowColor = { default = { 255, 255, 255, 0 }},
                lineColor = { 1, 1, 1 },
                rowHeight = 100,
                params = { input = roomInput, roomID = "Find Button" },
            }
        end
    end
    findButton = widget.newButton
    {
        x = (display.contentWidth)/2+275,
        y = (display.contentHeight)*(2/3),
        width = 210,
        height = 80,
        defaultFile = "Assets/findButton.png",
        overFile = "Assets/findButtonPressed.png",
        onEvent = handleFindPress
    }

    roomIP = multiHandler:getIP()
    roomInput = "Hello"

    --TableView
    local function onRowRender( event )
        local row = event.row
        local rowHeight = row.contentHeight
        local rowWidth = row.contentWidth

        local roomID = display.newText(row, row.params.roomID, 0, 0, customFont, 40 )
        roomID:setFillColor( 1 )
        roomID.x = 140
        roomID.y = row.height * 0.5

        local ip = display.newText(row, row.params.input, 0, 0, customFont, 40 )
        ip:setFillColor( 1 )
        ip.x = 650 
        ip.y = row.height * 0.5
       
    end

    local options =
    {
        left = 545,
        top = 300,
        width = 800,
        height = 400,
        backgroundColor = { 1,1,1,.5},
        onRowRender = onRowRender,
    }
    tableView = widget.newTableView( options )

    local function textListener( event )
        if ( event.phase == "began" ) then
            -- begins editing
        elseif ( event.phase == "ended" or event.phase == "submitted" ) then
            roomInput = event.target.text 
            native.setKeyboardFocus( nil )
        elseif ( event.phase == "editing" ) then
           -- is editing
        end
    end

    -- Create text field
    local fontSize = 14
    local textToMeasure = display.newText("", (display.contentWidth / 2), 100, native.systemFont, fontSize)
    local textHeight = textToMeasure.contentHeight
    textHeight = textHeight+90


    roomInputField = native.newTextField(display.contentWidth/2, display.contentHeight*(2/3), 300, textHeight )
    roomInputField.font = native.newFont( native.systemFont, fontSize)
    roomInputField.size = fontSize
    roomInputField:addEventListener( "userInput", textListener )


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

    -- Function to handle back button
    local function handleBackPress( event )
        if ( "ended" == event.phase ) then
            roomInputField:removeSelf( )
            roomInputField = nil
            tableView:removeSelf( )
            tableView = nil
            createButton:removeSelf( )
            createButton = nil
            findButton:removeSelf( )
            findButton = nil
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

scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )

scene:addEventListener( "destroyScene", scene )

scene:addEventListener( "didExitScene", scene )

return scene