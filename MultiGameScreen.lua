local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local game = require("gameClass")
local game = game.new(true)
local map = display.newGroup()
map = game.getmap()

local isServer, isClient, mapURL
local client, server, clients, numPlayers, serverStatus, score

function endGameScreen(scene, score)
    if(isServer) then
        if(scene == "loseScreen") then
            for i=1, numPlayers 
               do clients[i]:sendPriority({5,1,score})
            end
        elseif(scene == "winScreen") then
            for i=1, numPlayers 
               do clients[i]:sendPriority({5,2,score})
            end
        end

        listener = {}
        function listener:timer( event )
            local options =
            {
                params =
                {
                    score = score,
                }
            }
            storyboard.gotoScene(scene, options)
        end
        timer.performWithDelay( 1000, listener )
    end
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
            Runtime:addEventListener("autolanReceived", serverReceived);
        end

        if ( server == "nothing" ) then
           isServer = false
           isClient = true
           serverStatus = "nothing"
           Runtime:addEventListener("autolanReceived", clientReceived);
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
        game.setServer(false)
    end

    if(isServer) then
        createServerGUI()
        mapURL = "Assets/map.jpg"
        game.setServer(true)
    end

    game:mapCreate(mapURL)
    gameTimer = timer.performWithDelay(100, game, 0)
    
    if(isClient) then
        timer.pause(gameTimer)
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
        client:disconnect( )
    end

    isClient = nil
    isServer = nil
    numPlayers = nil
    clients = nil
    client = nil
    server = nil
    
    Runtime:removeEventListener("autolanReceived", clientReceived);
    Runtime:removeEventListener("autolanReceived", serverReceived);
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
            game.spawnSingleEnemy(5)
            client:sendPriority({2,5})
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
            game.spawnSingleEnemy(6)
            client:sendPriority({2,6})
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
            if(game.spawnSingleEnemy(1))then 
                client:sendPriority({2,1})
            end 
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
            if(game.spawnSingleEnemy(2)) then 
                client:sendPriority({2,2})
            end
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
            if(game.spawnSingleEnemy(3)) then
                client:sendPriority({2,3})
            end
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
            if(game.spawnSingleEnemy(7)) then 
                 client:sendPriority({2,7})
            end
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
            if(game.spawnSingleEnemy(4)) then
                client:sendPriority({2,4})
            end 
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
            if(game.spawnSingleEnemy(8))then 
                 client:sendPriority({2,8})
            end 
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

--Checks if screen is tapped
--to add a tower. Also sends the tower
--to the client to sync the game
function touchScreen(event)
    if(isServer) then
        sendTower = game.addTower(event)
        if(sendTower) then
            for i=1, numPlayers 
               do clients[i]:sendPriority({2,sendTower})
            end
        end
    end
end

-- CLIENT RETRIEVAL CODE
clientReceived = function(event)
    print("client received")
    local message = event.message
    print("message", message, message[1], message[2])

    --figure out packet type
    if(message[1] == 1) then
        if(message[2] == 1) then --we are the first player to join, let us take control of the ball
            timer.resume(gameTimer)  
        end
    elseif(message[1] == 2) then
        game.addTowerClient(message[2])
    end

    if(message[1] == 5) then
        if(message[2] == 1) then
            serverStatus = "serverLost"
            score = message[3]
        elseif(message[2] == 2) then
            serverStatus = "serverWon"
            score = message[3]
        end

        endlistener = {}
        function endlistener:timer( event )
            if(serverStatus == "serverWon") then
                scene = "loseScreen"
                sceneImage = "lost"
            elseif(serverStatus == "serverLost") then
                scene = "winScreen"
                sceneImage = "win"
            end

            local options =
            {
            params =
                {
                    score = score,
                    sceneImage = sceneImage,
                }
            }
            storyboard.gotoScene(scene, options)
        end
        timer.performWithDelay( 1000, endlistener )
    end
end

-- SERVER RETRIEVAL CODE
serverReceived = function(event)
    print("server received")
    local message = event.message 
    print(message)
    if(message[1] == 2) then
        game.spawnSingleEnemy(message[2])
    end
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