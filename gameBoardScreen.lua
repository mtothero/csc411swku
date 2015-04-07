--[[/************************************************************/
/* Author:  Frat Defense Team - Matt Tothero, Josh Smith,       */
/*          Dave Clymer, Alec McCloskey                         */
/* Creation Date: March 2014                                    */
/* Modification Date: 4/4/2015                                  */
/* Course: CSC354 & CSC411                                      */
/* Professor Name: Dr. Parson & Dr. Frye                        */
/* Filename: gameBoardScreen                                    */
/* Purpose: This displays the game board for a single player    */
/*          game.                                               */
/************************************************************/--]]

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local game = require("gameClass")
local game = game.new(false)
local map = display.newGroup()
map = game.getmap()
local backButton

-- called once the game ends
function endGameScreen(scene, score)
    local options =
    {
        params =
        {
            score = score,
        }
    }
    storyboard.gotoScene(scene, options)
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

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


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
    mapURL = "Assets/map.jpg"
    game:mapCreate(mapURL)
    gameTimer = timer.performWithDelay(100, game, 0)

    local function handlePledge( event )
        if("ended" == event.phase ) then
            game:towerChoosen('pledge')
        end 
    end
    pledge = widget.newButton
    {
        x = 86,
        y = 940,
        defaultFile = "Assets/pledge_button.png",
        overFile = "Assets/pledge_button_hover.png",
        onEvent = handlePledge
    }
    local function handleBottleTower( event )
        if("ended" == event.phase ) then
            game:towerChoosen('bottleThrower')
        end 
    end

    local function handlePause(event)
        if("ended" == event.phase) then
            timer.pause(gameTimer)
            pauseButton.isVisible = false
            playButton.isVisible = true  
        end 
    end 
    local function handlePlay(event)
        if("ended" == event.phase) then
            timer.resume(gameTimer)
            playButton.isVisible = false
            pauseButton.isVisible = true 
        end 
    end 
    playButton = widget.newButton
    {
        x = 1528,
        y = 1137,
        defaultFile = "Assets/play_button.png",
        overFile = "Assets/play_button.png",
        onEvent = handlePlay
    }
    playButton.isVisible = false
    pauseButton = widget.newButton
    {
        x = 1528,
        y = 1137,
        defaultFile = "Assets/pause_button.png",
        overFile = "Assets/pause_button.png",
        onEvent = handlePause
    }   

    bottleThrower = widget.newButton
    {
        x = 215,
        y = 940,
        defaultFile = "Assets/thrower_button.png",
        overFile = "Assets/thrower_button_hover.png",
        onEvent = handleBottleTower
    }
    local function handleBasketBallTower( event )
        if("ended" == event.phase ) then
            game:towerChoosen('baller')
        end 
    end
    basketballTower = widget.newButton
    {
        x = 86,
        y = 1073,
        defaultFile = "Assets/baller_button.png",
        overFile = "Assets/baller_button_hover.png",
        onEvent = handleBasketBallTower
    }
    local function handleFootBallTower( event )
        if("ended" == event.phase ) then
            game:towerChoosen('footballer')
        end 
    end
    footballTower = widget.newButton
    {
        x = 215,
        y = 1073,
        defaultFile = "Assets/football_button.png",
        overFile = "Assets/football_button_hover.png",
        onEvent = handleFootBallTower
    }
    -- Function to handle button events
    local function handleBackPress( event )
        if ( "ended" == event.phase ) then
            game:removeUNR()
            storyboard.gotoScene( "mainMenuScreen" )
        end
    end
    backButton = widget.newButton
    {
        x = display.contentWidth/3,
        y = (display.contentHeight)*.87,
        width = 206,
        height = 64,
        defaultFile = "Assets/newgame_buttonMain.png",
        overFile = "Assets/newgame_buttonMain.png",
        onEvent = handleBackPress
    }

    backButton.isVisible = false
    Runtime:addEventListener( "key", onKeyEvent )
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
    map:removeSelf()
    backButton:removeSelf( )
    pledge:removeSelf( )
    bottleThrower:removeSelf( )
    basketballTower:removeSelf( )
    footballTower:removeSelf( )
    pauseButton:removeSelf()
    playButton:removeSelf()
    timer.cancel(gameTimer)
    game:minionWipe()
    game:towerWipe()

    Runtime:removeEventListener( "handleBackPress", onUpdate )
    Runtime:removeEventListener( "key", onKeyEvent )
end

-- Called after the scene is removed
function scene:didExitScene( event )
   storyboard.removeScene( "gameBoardScreen" )
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
end

--Checks if they want to add a tower
--Needed due to multiplayer
function touchScreen(event)
    game.addTower(event)
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
scene:addEventListener( "destroyScene", scene )

scene:addEventListener( "didExitScene", scene )

---------------------------------------------------------------------------------

return scene