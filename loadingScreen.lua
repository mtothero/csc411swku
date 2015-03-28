local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local background, progressView  

-- Called when the scene's view does not exist
function scene:createScene( event )
	local group = self.view

	--background image
	background = display.newImage("Assets/load_menu.jpg") 
    background.x = display.contentWidth/2
    background.y = display.contentHeight/2   
    group:insert(background)

    --loading bar
	progressView = widget.newProgressView
	{
	    x = display.contentWidth/2,
	    y = display.contentHeight*4/5,
	    width = display.contentWidth/2,
	    isAnimated = true
	}
end


-- Called immediately after scene has moved onscreen
function scene:enterScene( event )
	local group = self.view

	local function listener( event )
	    
		progressView:setProgress( 0.5 )
		local function listener2( event )
	    	
	    	progressView:setProgress( 1 )
			local function listener3( event )
	    
			storyboard.gotoScene( "mainMenuScreen" )

			end
			timer.performWithDelay( 1000, listener3 )
		end
		timer.performWithDelay( 1000, listener2 )
	end
	timer.performWithDelay( 1000, listener )
end


-- Called when scene is about to move offscreen
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener( "listener", onUpdate )
	Runtime:removeEventListener( "listener2", onUpdate )
	Runtime:removeEventListener( "listener3", onUpdate )
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
end

-- called after this scene has transitioned out
function scene:didExitScene( event )
	background:removeSelf()
	background = nil
	progressView:removeSelf()
	progressView = nil
	storyboard.removeScene( "loadingScreen" )
end

scene:addEventListener( "createScene" )

scene:addEventListener( "enterScene" )

scene:addEventListener( "exitScene" )

scene:addEventListener( "destroyScene" )

scene:addEventListener( "didExitScene" )

return scene