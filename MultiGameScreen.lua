local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local game = require("gameClass")
local game = game.new()
local map = display.newGroup()
map = game.getmap()

local isServer, isClient, mapURL
local client, server, clients, numPlayers

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

    local aParams = event.params

    if aParams then
        client = aParams.var1
        server = aParams.var2
        clients = aParams.var3
        numPlayers = aParams.var4

        if ( client == "nothing" ) then
            isClient = false
            isServer = true
        end

        if ( server == "nothing" ) then
           isServer = false
           isClient = true
        end
    end

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

    --isClient = true
    if(isClient) then
        createClientGUI()
        mapURL = "Assets/clientMap.jpg"
    end

    if(isServer) then
        createServerGUI()
        mapURL = "Assets/map.jpg"
    end

    game:mapCreate(mapURL)
    gameTimer = timer.performWithDelay(100, game, 0)
 
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

    local function handlePause(event)
        if("ended" == event.phase) then
            timer.pause(gameTimer)
            pauseButton.isVisible = false
            playButton.isVisible = true  
        end 
    end
    pauseButton = widget.newButton
    {
        x = 1528,
        y = 1137,
        defaultFile = "Assets/pause_button.png",
        overFile = "Assets/pause_button.png",
        onEvent = handlePause
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
    mapURL = nil
    timer.cancel(gameTimer)
    game:minionWipe()
    game:towerWipe()

    pauseButton:removeSelf()
    playButton:removeSelf()
    backButton:removeSelf( )
    if(isServer) then
        pledge:removeSelf( )
        bottleThrower:removeSelf( )
        basketballTower:removeSelf( )
        footballTower:removeSelf( )
        server:disconnect( )
        server:stop()
    end

    if(isClient) then
        copMinion:removeSelf( )
        cop2Minion:removeSelf( )
        highschoolerMinion:removeSelf( )
        highschooler2Minion:removeSelf( )
        oldManMinion:removeSelf( )
        oldMan2Minion:removeSelf( )
        teacherMinion:removeSelf( )
        teacher2Minion:removeSelf( )
    end

    isClient = nil
    isServer = nil
    numPlayers = nil
    clients = nil
    client = nil
    server = nil
    
    Runtime:removeEventListener( "handleBackPress", onUpdate )
    Runtime:removeEventListener( "key", onKeyEvent )
end

function scene:didExitScene( event )
   storyboard.removeScene( "MultiGameScreen" )
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
end

function createServerGUI()
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
end

function createClientGUI() 
    local function handleCopMinion( event )
        if("ended" == event.phase ) then
            
        end 
    end
    copMinion = widget.newButton
    {
        x = 56,
        y = 930,
        defaultFile = "Assets/copButton.png",
        overFile = "Assets/copButtonPressed.png",
        onEvent = handleCopMinion
    }

    local function handleCop2Minion( event )
        if("ended" == event.phase ) then
            
        end 
    end
    cop2Minion = widget.newButton
    {
        x = 156,
        y = 930,
        defaultFile = "Assets/cop2Button.png",
        overFile = "Assets/cop2ButtonPressed.png",
        onEvent = handleCop2Minion
    }

    local function handleHighschoolerMinion( event )
        if("ended" == event.phase ) then
            
        end 
    end
    highschoolerMinion = widget.newButton
    {
        x = 256,
        y = 930,
        defaultFile = "Assets/highSchoolerButton.png",
        overFile = "Assets/highSchoolerButtonPressed.png",
        onEvent = handleHighschoolerMinion
    }

    local function handleHighschooler2Minion( event )
        if("ended" == event.phase ) then
            
        end 
    end
    highschooler2Minion = widget.newButton
    {
        x = 356,
        y = 930,
        defaultFile = "Assets/highSchooler2Button.png",
        overFile = "Assets/highSchooler2ButtonPressed.png",
        onEvent = handleHighschooler2Minion
    } 

    local function handleOldManMinion( event )
        if("ended" == event.phase ) then
            
        end 
    end
    oldManMinion = widget.newButton
    {
        x = 56,
        y = 1080,
        defaultFile = "Assets/oldManButton.png",
        overFile = "Assets/oldManButtonPressed.png",
        onEvent = handleOldManMinion
    }

    local function handleOldMan2Minion( event )
        if("ended" == event.phase ) then
            
        end 
    end
    oldMan2Minion = widget.newButton
    {
        x = 156,
        y = 1080,
        defaultFile = "Assets/oldMan2Button.png",
        overFile = "Assets/oldMan2ButtonPressed.png",
        onEvent = handleOldMan2Minion
    }

    local function handleTeacherMinion( event )
        if("ended" == event.phase ) then
            
        end 
    end
    teacherMinion = widget.newButton
    {
        x = 256,
        y = 1080,
        defaultFile = "Assets/teacherButton.png",
        overFile = "Assets/teacherButtonPressed.png",
        onEvent = handleTeacherMinion
    }

    local function handleTeacher2Minion( event )
        if("ended" == event.phase ) then
            
        end 
    end
    teacher2Minion = widget.newButton
    {
        x = 356,
        y = 1080,
        defaultFile = "Assets/teacher2Button.png",
        overFile = "Assets/teacher2ButtonPressed.png",
        onEvent = handleTeacher2Minion
    } 
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