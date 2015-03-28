local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )


-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    local params = event.params
    background = display.newImage("Assets/highscore_popup.png")
    background.x = display.contentWidth/2
    background.y = display.contentHeight*.45
    background.id = "background"    
    group:insert(background)

end


--- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view

end

-- Called when new scene has transitioned in
function scene:didExitScene( event )

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