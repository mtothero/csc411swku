local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local audio = require( "audio" )
local onePlayerButton, twoPlayerButton, highScoreButton, settingsButton, background, clouds, logo, xValue


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	--background image
	background = display.newImage("Assets/home_menu.jpg")
	background.x = display.contentWidth/2
	background.y = display.contentHeight/2	
	group:insert(background)

	clouds = display.newImageRect( "Assets/scroll_clouds.png", 3840, 411 )
	clouds.anchorX = 0
	clouds.anchorY = 0
	clouds.x = 0
	clouds.y = 0
	local function reset_clouds( clouds )
		if ( clouds ~= nil ) then
		    clouds.x = 0
		    transition.to( clouds, {x=0-3840+1920, time=30000, onComplete=reset_clouds} )
	    end
	end
	reset_clouds( clouds )
	group:insert(clouds)

	logo = display.newImage("Assets/cloud_logo.png")
	logo.x = display.contentWidth/2
	logo.y = display.contentHeight/4	
	group:insert(logo)

	--start background music
	if audio.isChannelActive( 1 ) == false then
		local backgroundMusic = audio.loadStream( "Assets/backgroundMusic.mp3")
		local path = system.pathForFile( "volumeConfig.txt", system.DocumentsDirectory )
		local file = io.open( path, "r" )

		
		if(file ~= nil) then
			local volume = file:read( "*n" )
			audio.setVolume( volume )
    	else
    		audio.setVolume( .5 )
		end
		
		local options =
		{
			channel=1,
			loops=-1,
			fadein=5000
		}
    	audio.play( backgroundMusic, options )
	end
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	--One player button event handler
	local function handle1PlayerPress( event )
	    if ( "ended" == event.phase ) then
	        --storyboard.gotoScene( "gameBoardScreen" )
	        storyboard.gotoScene( "MultiGameScreen" )
	    end
	end
	onePlayerButton = widget.newButton
	{
		x = display.contentWidth*(1/5),
		y = (display.contentHeight)*.87,
	    width = 210,
	    height = 80,
	    defaultFile = "Assets/onePlayer.png",
	    overFile = "Assets/onePlayerPressed.png",
	    onEvent = handle1PlayerPress
	}

	-- Two player button event handler
	local function handle2PlayerGamePress( event )
	    if ( "ended" == event.phase ) then
	        local options =
			{
			    effect = "fade",
			    time = 50,
			    isModal = true,
			}
		    if ( "ended" == event.phase ) then
		        storyboard.showOverlay( "multiPlayerSetupScreen", options )
		    end
	    end
	end
	twoPlayerButton = widget.newButton
	{
		x = display.contentWidth*(2/5),
		y = (display.contentHeight)*.87,
	    width = 210,
	    height = 80,
	    defaultFile = "Assets/twoPlayer.png",
	    overFile = "Assets/twoPlayerPressed.png",
	    onEvent = handle2PlayerGamePress
	}

	--high score button event handler
	local function handleHighScorePress( event )
		local options =
		{
		    effect = "fade",
		    time = 200,
		    isModal = true,
		}
	    if ( "ended" == event.phase ) then
	        storyboard.showOverlay( "highScoresScreen", options )
	    end
	end
	highScoreButton = widget.newButton
	{
		x = display.contentWidth*(3/5),
		y = (display.contentHeight)*.87,
	    width = 210,
	    height = 80,
	    defaultFile = "Assets/highscore_buttonMain.png",
	    overFile = "Assets/highscore_button_PRESSED.png",
	    onEvent = handleHighScorePress
	}

	--settings button event handler
	local function handleSettingsPress( event )
		local options =
		{
		    effect = "fade",
		    time = 200,
		    isModal = true,
		}
	    if ( "ended" == event.phase ) then
	        storyboard.showOverlay( "settingsScreen", options )
	    end
	end
	settingsButton = widget.newButton
	{
		x = (display.contentWidth)*(4/5),
		y = (display.contentHeight)*.87,
	    width = 210,
	    height = 80,
	    defaultFile = "Assets/settings_buttonMain.png",
	    overFile = "Assets/settings_button_PRESSED.png",
	    onEvent = handleSettingsPress
	}
end

--called when show overlay was called
function scene:overlayBegan( event )
	local group = self.view
	xValue = clouds.x
	background = display.newImage("Assets/home_menu_BLUR.jpg")
	background.x = display.contentWidth/2
	background.y = display.contentHeight/2	
	group:insert(background)
	clouds = display.newImageRect( "Assets/scroll_clouds_BLUR.png", 3840, 411 )
	clouds.anchorX = 0
	clouds.anchorY = 0
	clouds.x = xValue
	clouds.y = 0
	group:insert(clouds)
	logo = display.newImage("Assets/cloud_logo_BLUR.png")
	logo.x = display.contentWidth/2
	logo.y = display.contentHeight/4	
	group:insert(logo)
	onePlayerButton:setEnabled(false)
	twoPlayerButton:setEnabled( false )
	highScoreButton:setEnabled(false)
	settingsButton:setEnabled(false)
end

--called when remove overlay was called
function scene:overlayEnded( event )
	local group = self.view
	background = display.newImage("Assets/home_menu.jpg")
	background.x = display.contentWidth/2
	background.y = display.contentHeight/2	
	group:insert(background)
	clouds = display.newImageRect( "Assets/scroll_clouds.png", 3840, 411 )
	clouds.anchorX = 0
	clouds.anchorY = 0
	clouds.x = xValue
	clouds.y = 0
	local function reset_clouds( clouds )
		if ( clouds ~= nil ) then
			if ( xValue ~= 0 and xValue ~= nil) then
		    	clouds.x = xValue
		    	--the following calculates how much time it will take for the clouds to move across
		    	--based off of the original setting of moving 1920 pixels in 30 seconds
		   	 	local timeVar = (1920+xValue)/(0.064)
		    	xValue = 0
		    	transition.to( clouds, {x=0-3840+1920, time=timeVar, onComplete=reset_clouds} )
		    else
		    	clouds.x = 0
		    	transition.to( clouds, {x=0-3840+1920, time=30000, onComplete=reset_clouds} )
		    end
	    end
	end
	reset_clouds( clouds )
	group:insert(clouds)
	logo = display.newImage("Assets/cloud_logo.png")
	logo.x = display.contentWidth/2
	logo.y = display.contentHeight/4	
	group:insert(logo)
	onePlayerButton:setEnabled(true)
	twoPlayerButton:setEnabled(true)
	highScoreButton:setEnabled(true)
	settingsButton:setEnabled(true)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener( "handle1PlayerPress", onEvent )
	Runtime:removeEventListener( "handle2PlayerPress", onEvent )
	Runtime:removeEventListener( "handleHighScorePress", onEvent )
	Runtime:removeEventListener( "handleSettingsPress", onEvent )
end

function scene:didExitScene( event )
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
	clouds:removeSelf()
	clouds = nil
	logo:removeSelf()
	logo = nil
	xValue = nil
	storyboard.removeScene( "mainMenuScreen" )
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
end

scene:addEventListener( "createScene" )

scene:addEventListener( "enterScene" )

scene:addEventListener( "exitScene" )

scene:addEventListener( "destroyScene" )

scene:addEventListener( "didExitScene" )

scene:addEventListener( "overlayBegan" )

scene:addEventListener( "overlayEnded" )

return scene