--[[/************************************************************/
/* Author:  Frat Defense Team - Matt Tothero, Josh Smith,       */
/*          Dave Clymer, Alec McCloskey                         */
/* Creation Date: March 2014                                    */
/* Modification Date: --                                        */
/* Course: CSC354                                               */
/* Professor Name: Dr. Parson                                   */
/* Filename: highScoresScreen                                   */
/* Purpose: This displays the high scores of the game.          */
/************************************************************/--]]

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )

local backButton, background, settingsButton, onePlayerButton, twoPlayerButton, highScoreButton, highScoresText, textGroup
local customFont

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    --insert background
    background = display.newImage("Assets/highscore_popup.png")
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
end


--- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

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
            storyboard.hideOverlay( "fade", 200 )
        end
    end
    backButton = widget.newButton
    {
        x = 1254,
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

    local path = system.pathForFile( "highScores.txt", system.ResourceDirectory )
    local file = io.open( path, "r" )
    textGroup = display.newGroup( )
    local x = 675
    local y = 350
    local lineNum = 0
    local maxLine = 10 
    if (file) then    
        for line in file:lines( ) do
            if(line ~= nil and lineNum < maxLine) then
                local numString = line
                local numValue = tonumber(numString)
                
                --name
                if numValue == nil then
                    local options = 
                    {
                        text = line,     
                        x = x,
                        y = y,
                        font = customFont,   
                        fontSize = 46,
                    }
                    highScoresText = display.newText( options )
                    highScoresText:setFillColor( 255, 255, 255 )
                    highScoresText.anchorX = 0
                    textGroup:insert( highScoresText )
                --value
                else
                    local options = 
                    {
                        text = numValue .. " kegs",     
                        x = x+300,
                        y = y,
                        font = customFont,   
                        fontSize = 46,
                    }
                    highScoresText = display.newText( options )
                    highScoresText:setFillColor( 255, 255, 255 )
                    highScoresText.anchorX = 0
                    textGroup:insert( highScoresText )

                    y = y + 70
                    lineNum = lineNum + 1
                end
             end
        end
    file:close()
    else
        print("file not found")
    end

    Runtime:addEventListener( "key", onKeyEvent )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    Runtime:removeEventListener( "handleBackPress", onEvent )
    Runtime:removeEventListener( "handle1PlayerPress", onEvent )
    Runtime:removeEventListener( "handle2PlayerPress", onEvent )
    Runtime:removeEventListener( "handleHighScorePress", onEvent )
    Runtime:removeEventListener( "handleSettingsPress", onEvent )
    Runtime:removeEventListener( "key", onKeyEvent )
end

-- Called when new scene has transitioned in
function scene:didExitScene( event )
    textGroup:removeSelf( )
    textGroup = nil
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
    storyboard.removeScene( "highScoresScreen" )
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