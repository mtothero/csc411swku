--[[/************************************************************/
/* Author:  Frat Defense Team - Matt Tothero, Josh Smith,       */
/*          Dave Clymer, Alec McCloskey                         */
/* Creation Date: March 2014                                    */
/* Modification Date: --                                        */
/* Course: CSC354                                               */
/* Professor Name: Dr. Parson                                   */
/* Filename: settingsScreen                                     */
/* Purpose: This displays the settings screen of the game.      */
/************************************************************/--]]

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local audio = require("audio")

local background, backButton, settingsButton, onePlayerButton, twoPlayerButton, highScoreButton
local soundSlider, musicSlider, effectSlider
local volume

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    --background image
    background = display.newImage("Assets/settings_popup.png")
    background.x = display.contentWidth/2
    background.y = display.contentHeight/2  
    background.id = "background"  
    group:insert(background)

    --hardware back button event listener
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

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    Runtime:addEventListener( "key", onKeyEvent )

    -- Function to handle back button events
    local function handleBackPress( event )
        if ( "ended" == event.phase ) then
            storyboard.hideOverlay( "fade", 200 )
        end
    end
    backButton = widget.newButton
    {
        x = 1254,
        y = 339,
        width = 70,
        height = 70,
        defaultFile = "Assets/invisible.png",
        overFile = "Assets/invisible.png",
        onEvent = handleBackPress
    }

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

    sliderGroup = display.newGroup( )
    local function musicSliderListener(event)
      if ("moved" == event.phase) then
        volume = event.value / 100
        audio.setVolume( volume )
      end
    end

    musicSlider = widget.newSlider
    {
        x = 1025,
        y = 520,
        width = 400,
        value = audio.getVolume() * 100,
        listener = musicSliderListener,
    }
    sliderGroup:insert( musicSlider )

    soundSlider = widget.newSlider
    {
        x = 1025,
        y = 650,
        width = 400,
        value = 100
    }
    sliderGroup:insert( soundSlider )

    effectsSlider = widget.newSlider
    {
        x = 1075,
        y = 775,
        width = 300,
        value = 100
    }
    sliderGroup:insert( effectsSlider )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view

    if (volume ~= nil) then 
        local path = system.pathForFile( "volumeConfig.txt", system.DocumentsDirectory )
        local file = io.open( path, "w" )
        file:write(volume)
        io.close( file )
        file = nil    
    end

    Runtime:removeEventListener( "handleBackPress", onEvent )
    Runtime:removeEventListener( "handle1PlayerPress", onEvent )
    Runtime:removeEventListener( "handle2PlayerPress", onEvent )
    Runtime:removeEventListener( "handleHighScorePress", onEvent )
    Runtime:removeEventListener( "handleSettingsPress", onEvent )
    Runtime:removeEventListener( "key", onKeyEvent )
    Runtime:removeEventListener( "musicSliderListener", listener )
end

-- called when the transition has completed
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
    soundSlider:removeSelf( )
    soundSlider = nil
    musicSlider:removeSelf( )
    musicSlider = nil
    effectsSlider:removeSelf( )
    effectsSlider = nil
    sliderGroup:removeSelf( )
    sliderGroup = nil
    background:removeSelf( )
    background = nil
    volume = nil
    storyboard.removeScene( "settingsScreen" )
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