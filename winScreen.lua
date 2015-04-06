local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local background, proceedButton, repText 

-- Called when the scene's view does not exist
function scene:createScene( event )
	local group = self.view
	local score = event.params.score

	if (event.params.sceneImage ~= nil) then
		if (event.params.sceneImage == "win") then
			background = display.newImage("Assets/serverWinScreen.png") 
		end
	else
		background = display.newImage("Assets/you_win.jpg") 
	end

	--background image
    background.x = display.contentWidth/2
    background.y = display.contentHeight/2   
    group:insert(background)

    if "Win" == system.getInfo( "platformName" ) then
        customFont = "Lato"
    elseif "Android" == system.getInfo( "platformName" ) then
        customFont = "Lato-Bol"
    end
	local options = 
        {
            text = score,     
            x = 980,
            y = 530,
            font = customFont,   
            fontSize = 82,
        }
	repText = display.newText( options )
    repText:setFillColor( 0, 0, 0 )
    repText.anchorX = 0
    group:insert( repText )
end


-- Called immediately after scene has moved onscreen
function scene:enterScene( event )
	local group = self.view

	--proceed button event handler
	local function handleProceedPress( event )
		local options =
		{
		    effect = "fade",
		    time = 200,
		    isModal = true,
		}
	    if ( "ended" == event.phase ) then
	        storyboard.gotoScene( "mainMenuScreen", options )
	    end
	end
	proceedButton = widget.newButton
	{
		x = (display.contentWidth)/2,
		y = (display.contentHeight)/2,
	    width = 1920,
	    height = 1200,
	    defaultFile = "Assets/invisible.png",
        overFile = "Assets/invisible.png",
	    onEvent = handleProceedPress
	}
end


-- Called when scene is about to move offscreen
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener( "handleProceedPress", onEvent )
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
end

-- called after this scene has transitioned out
function scene:didExitScene( event )
	background:removeSelf()
	background = nil
	proceedButton:removeSelf()
	proceedButton = nil
	storyboard.removeScene( "winScreen" )
end

scene:addEventListener( "createScene" )

scene:addEventListener( "enterScene" )

scene:addEventListener( "exitScene" )

scene:addEventListener( "destroyScene" )

scene:addEventListener( "didExitScene" )

return scene