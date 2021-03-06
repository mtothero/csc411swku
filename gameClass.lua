--[[/************************************************************/
/* Author:  Frat Defense Team - Matt Tothero, Josh Smith,       */
/*          Dave Clymer, Alec McCloskey                         */
/* Creation Date: March 2014                                    */
/* Modification Date: 4/7/2015                                  */
/* Course: CSC354 & CSC411                                      */
/* Professor Name: Dr. Parson & Dr. Frye                        */
/* Filename: gameClass                                          */
/* Purpose: This class creates is the structure of a game       */
/*          object that handles all game player.                */
/************************************************************/--]]

local game = {}
local game_mt = {__index = game}
local widget = require( "widget" )
local Minion = require ("Minion")
local Tower = require("Tower")
local physics = require("physics")
physics.start()
physics.setGravity( 0,0)
local needsInput, onCollision

------------------------------------------------------
--PRIVATE FUNCTIONS
------------------------------------------------------
local spawnTable = 
{
    [1] = {225, 5, 30, 10, "highSchooler", 50},
    [2] = {250, 5,  35, 10, "highSchooler2", 75},
    [3] = {1700, 10, 15, 20, "oldMan", 100},
    [4] = {100, 10, 40, 20, "teacher", 125},
    [5] = {2000, 20, 25, 40, "cop", 150},
    [6] = {3000, 25, 25, 90, "cop2", 200},
    [7] = {1700, 10, 15, 25, "oldMan2", 250},
    [8] = {200, 10, 40, 20, "teacher2", 300},
    ['pledge'] = {75, 2, 50, 175, 'pledge'},
    ['bottleThrower'] = {100, 4, 150, 400, 'bottleThrower'},
    ['Baller'] = {150, 4, 250, 500, 'Baller'},
    ['footballer'] = {200, 5, 500, 250, 'footballer'}
}

local spawners =
{
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  
    1, 1, 1, 1, 1, 2, 2, 1, 1, 1,
    1, 2, 1, 2, 1, 2, 1, 2, 1, 2,
    2, 1, 1, 3, 3, 3, 2, 2, 1, 1, 
    3, 1, 3, 1, 3, 2, 3, 2, 3, 3, 
    2, 2, 4, 3, 3, 4, 3, 2, 2, 3, 
    4, 3, 3, 4, 3, 3, 4, 4, 3, 4, 
    4, 4, 4, 4, 4, 5, 4, 4, 4, 4,
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 
    5, 5, 6, 5, 4, 4, 5, 4, 5, 5, 
    6, 3, 6, 6, 3, 6, 6, 3, 6, 6,
}



--map creation 
-- 0 is town
-- 1 is placeable 
-- 2 is minion path 
-- other is spawn and destination
local NumberOfColumns = 19
local map = {
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,  0,  4,  0,            
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,  0,  3,  0,            
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    1,   0,   0,   1,   1,  1,  3,  0,          
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    1,   0,   3,   0,   0,  0,  0,  0,          
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    1,   0,   3,   0,   0,  0,  0,  0,          
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,    1,   0,   3,   1,   1,  1,  0,  0,          
    2,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   3,   1,   0,  0,  0,  0,           
    2,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   1,   0,  0,  0,  0,           
    0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   1,    1,   0,   0,   1,   0,  0,  0,  0,           
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,  0,  0,  0,          
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,  0,  0,  0,          
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,  0,  0,  0,           
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,  0,  0,  0,         
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,  0,  0,  0,          
}

local function deductRep(cost) --used to deduct rep points
    if repPoints >= cost then
        repPoints = repPoints - cost
        repText.text = repPoints
        return true   
    end 
    return false
end 

local function addRep(bounty)
    if(isServer) then
        repPoints = repPoints + bounty
        repText.text = repPoints
        score = score + repPoints + bounty
        scoreText.text = score
    end 
end

local function addAttackPoints(bounty)
    attackPoints = attackPoints + bounty
    if(isServer == false) then 
       
        attackPointsText.text = attackPoints
        score = score + attackPoints + bounty 
        scoreText.text = score
    end
end

local function bottleThrower( event )
     if "ended" == event.phase then 
        towerChoosen = true
        damage = 100
      end
 end


-----------------------------------------------------
--PUBLIC FUNCTIONS
-----------------------------------------------------
function game.new(isMulti) 	--constructor 
	local newGame= {}
    multiplayer = isMulti
    isServer = true
    levelRects = {}
    levelGroup = display.newGroup()
    towers     = display.newGroup()
    gameMap    = display.newGroup()
    levelImage = display.newGroup()
    newRound = true
    minionTable = {}
    towerTable = {}
    towerChoosen = false
    towerName = nil
    repPoints  = 1000
    attackPoints = 100
    newAP = 0
    attackScore = 0
    round = 1
    score = 0
    health = 100
    repText = display.newText(repPoints, 530, 80, "Helvetica", 69)
    attackPointsText = display.newText('', 530, 80, "Helvetica",69)
    healthText = display.newText(health, 210, 80, "Helvetica", 69)
    roundText = display.newText(round, 1860, 1160, "Helvetica",53)
    scoreText = display.newText(score, 1050, 80, "Helvetica",  69)
    maxRounds = 11
    endGame = false
    timeBetweenRounds = 100 -- changeback 
    timeUntilNextRound = timeBetweenRounds
    timeUNRText = display.newText("Next Round Starts in " .. timeUntilNextRound/10 .. " seconds." , display.contentWidth/2, 650, "Helvetica", 50)
	return setmetatable(newGame, game_mt)
end

--function setServer(setNewServer)
--This sets the current game as either being
--the server or the client.
function game.setServer(setNewServer)
    isServer = setNewServer
    if(isServer == false) then
        repText.text = ""
        attackPointsText.text = attackPoints 
    end
end

--function touchScreen(event)
function game.addTower(event)
    if(endGame == false)then 
        if event.phase == "ended" then
            if towerChoosen == true then
                local target = event.target
                if target.towerOn == false then
                    if(deductRep(spawnTable[towerName][3])) then
                        local towerID = target.towerID
                        tempTower = Tower.new(target.x + 75, target.y + 35, spawnTable[towerName])
                        table.insert(towerTable, tempTower)
                        target.towerOn = true
                        towerChoosen = false 
                        return tempTower
                    end
                end
            end
        end
    end
    return false
end

--Client side version of addTower
--This is important since it doesn't keep track of rep points.
function game.addTowerClient(myTower)   
    table.insert(towerTable,Tower.new(myTower.x, myTower.y, spawnTable[myTower.towerString]))
end

--Creates the map
function game:mapCreate(mapURL)
	local i 
	for i = 1, #map do   
        local placementAllowed = false
        local groundImage
        local xPos , yPos

        --Sort out placeable areas etc...
        if map[i] == 0 then
            -- groundImage = "images/grass.png" 
        elseif (map[i] == 1 or map[i] == 2)then
            -- groundImage = "images/floor.png" 
            placementAllowed = true
        end

        if     i <= NumberOfColumns then xPos = 50+(100*(i-1));  yPos = 20
        elseif i <= NumberOfColumns*2 then xPos = 50+(100*(i-(NumberOfColumns + 1))); yPos = 120
        elseif i <= NumberOfColumns*3 then xPos = 50+(100*(i-(NumberOfColumns*2 + 1))); yPos = 220
        elseif i <= NumberOfColumns*4 then xPos = 50+(100*(i-(NumberOfColumns*3 + 1))); yPos = 320
        elseif i <= NumberOfColumns*5 then xPos = 50+(100*(i-(NumberOfColumns*4 + 1))); yPos = 420
        elseif i <= NumberOfColumns*6 then xPos = 50+(100*(i-(NumberOfColumns*5 + 1))); yPos = 520
        elseif i <= NumberOfColumns*7 then xPos = 50+(100*(i-(NumberOfColumns*6 + 1))); yPos = 620
        elseif i <= NumberOfColumns*8 then xPos = 50+(100*(i-(NumberOfColumns*7 + 1))); yPos = 720
        elseif i <= NumberOfColumns*9 then xPos = 50+(100*(i-(NumberOfColumns*8 + 1))); yPos = 820
        elseif i <= NumberOfColumns*10 then xPos = 50+(100*(i-(NumberOfColumns*9 + 1))); yPos = 920
        elseif i <= NumberOfColumns*11 then xPos = 50+(100*(i-(NumberOfColumns*10 + 1))); yPos = 1020
        else xPos = 50+(100*(i-(NumberOfColumns*11 + 1))); yPos = 1120
        end
        if(i > 20) then
            levelRects[i] = display.newRect(xPos,yPos,100, 100) 
            levelGroup:insert(levelRects[i])
        
            if placementAllowed == true then 
                levelRects[i].towerOn = false
                levelRects[i].towerID = i
                levelRects[i]:addEventListener("touch", touchScreen)
            end
        end
    end

    tempImage = display.newImage(mapURL, display.contentWidth/2 - 70, display.contentHeight/2 - 20)
    levelGroup:insert(tempImage)
    levelGroup.x = 75
    levelGroup.y = 35
end

--sets up all display objects for the game
function game:getmap()
    gameMap:insert(levelGroup)
    gameMap:insert(towers)
    gameMap:insert(repText)
    gameMap:insert(healthText)
    gameMap:insert(scoreText)
    gameMap:insert(roundText)
    return gameMap
end

--Spawns a single enemy.
--The server also keeps track of attackPoints, so even though it is still
--seperate via if/else statement, they both remove attackpoints
function game.spawnSingleEnemy(spawnNumber)
    if(isServer == false)then
        if(attackPoints >= spawnTable[spawnNumber][6]) then
            attackPoints = attackPoints - spawnTable[spawnNumber][6]
            attackPointsText.text = attackPoints
            local spawnX, spawnY
            spawnX = 50
            spawnY = 720
            local enemy = Minion.new(spawnX, spawnY, table.getn(minionTable)*5 + timeUntilNextRound, spawnTable[spawnNumber])
            table.insert(minionTable, enemy)
            return true
        end
        return false
    else
        local spawnX, spawnY
        spawnX = 50
        spawnY = 720
        local enemy = Minion.new(spawnX, spawnY, table.getn(minionTable)*5 + timeUntilNextRound, spawnTable[spawnNumber])
        attackPoints = attackPoints - spawnTable[spawnNumber][6]
        table.insert(minionTable, enemy)
    end
end

--adds singleplayer minions
function game:addMinions()
    local spawnX, spawnY
    local i
    for i = 1, #map do
        if (map[i] == 2) then
            if     i <= NumberOfColumns then spawnX = 50+(100*(i-1));  spawnY = 20
            elseif i <= NumberOfColumns*2 then spawnX = 50+(100*(i-(NumberOfColumns + 1))); spawnY = 120
            elseif i <= NumberOfColumns*3 then spawnX = 50+(100*(i-(NumberOfColumns*2 + 1))); spawnY = 220
            elseif i <= NumberOfColumns*4 then spawnX = 50+(100*(i-(NumberOfColumns*3 + 1))); spawnY = 320
            elseif i <= NumberOfColumns*5 then spawnX = 50+(100*(i-(NumberOfColumns*4 + 1))); spawnY = 420
            elseif i <= NumberOfColumns*6 then spawnX = 50+(100*(i-(NumberOfColumns*5 + 1))); spawnY = 520
            elseif i <= NumberOfColumns*7 then spawnX = 50+(100*(i-(NumberOfColumns*6 + 1))); spawnY = 620
            elseif i <= NumberOfColumns*8 then spawnX = 50+(100*(i-(NumberOfColumns*7 + 1))); spawnY = 720
            elseif i <= NumberOfColumns*9 then spawnX = 50+(100*(i-(NumberOfColumns*8 + 1))); spawnY = 820
            elseif i <= NumberOfColumns*10 then spawnX = 50+(100*(i-(NumberOfColumns*9 + 1))); spawnY = 920
            elseif i <= NumberOfColumns*11 then spawnX = 50+(100*(i-(NumberOfColumns*10 + 1))); spawnY = 1020
            else spawnX = 50+(100*(i-(NumberOfColumns*12 + 1))); spawnY = 1120
            end
        end
    end
    
    for i = 1, 10 do 
        local enemy = Minion.new(spawnX, spawnY, i*5 + timeBetweenRounds, spawnTable[spawners[i + (10*(round - 1))]])
        local image_name = enemy:getImage()
        table.insert(minionTable, enemy)
    end
end

--plays the game
function game:play()
    if newRound == true then
        if(multiplayer==false) then 
            game:addMinions()
        else
            addAttackPoints(round * 200)

        end
        newRound = false 
        print("ADDED MINIONS!")
        timeUntilNextRound = timeBetweenRounds
        local timeUNRSeconds = timeUntilNextRound / 10
        timeUNRSeconds = timeUNRSeconds - (timeUNRSeconds % 10)
        timeUNRText.text = "Next Round Starts in " .. timeUNRSeconds .. " seconds." 
        timeUNRText.isVisible = true 
    else
    	if(timeUntilNextRound == 0)then
    		timeUNRText.isVisible = false
    	else
    		timeUntilNextRound = timeUntilNextRound - 1 
    		local timeUNRSeconds =(timeUntilNextRound/10)
        	timeUNRSeconds = timeUNRSeconds - (timeUNRSeconds % 1)
        	timeUNRText.text = "Next Round Starts in " .. timeUNRSeconds .. " seconds." 
    	end 
        local removeNum = {}
        for i = 1, #minionTable do 
            mapRectsRow =  ((minionTable[i]:getY() / 100)-1) --* NumberOfColumns)-- + ((minionTable[1]:getX() + 50)/100 - ((((minionTable[1]:getY() / 100)) * NumberOfColumns))) 
            mapRectsRow = mapRectsRow - mapRectsRow%1
            mapRectsColumn = (minionTable[i]:getX() - 50)/100
            mapRectsColumn = mapRectsColumn - mapRectsColumn%1
            mapRectsNum = mapRectsColumn + mapRectsRow*NumberOfColumns + 1
            if(map[mapRectsNum] == 3)then
                minionTable[i]:move(1)
            elseif(map[mapRectsNum] == 4) then
                table.insert(removeNum, i)
                newAP = newAP + minionTable[i]:getBounty()
                minionTable[i]:kill()
                health = health - minionTable[i]:getDamage()
                healthText.text = health
                
                if health <= 0 then
                    endGame = true
                    table.remove(minionTable, i)
                    return
                end 

            else 
                minionTable[i]:move(2)
            end
         end
        --Remove minion at end and decrement health
        for i = #removeNum, 1, -1  do  
            tempMinion = table.remove(minionTable, removeNum[i])
            tempMinion = nil
        end
        removeNum = {}
                
        --HIT DETECTION
        for i = 1, #minionTable do
            for j = 1, #towerTable do
                local isHit = game:checkHit(towerTable[j], minionTable[i])
                if(isHit == 1) then
                    local minionKilled = towerTable[j]:attack(minionTable[i], self)
                    if(minionKilled == 1) then 
                        minionTable[i]:kill()
                        table.insert(removeNum, i)
                        break 
                    end
                end
            end  
        end
        --decrements BackSwing
        for i = 1, #towerTable do
            towerTable[i]:decrementBackSwing()
        end

        --if a minion died, remove from table and add bounty
        for i = #removeNum, 1, -1  do  
            minionTemp = table.remove(minionTable, removeNum[i])
            addRep(minionTemp:getBounty())
        end 
        if(multiplayer == false) then 
            if(#minionTable == 0 and round < maxRounds)then
                round = round + 1
                roundText.text = round
                newRound = true 
            elseif(#minionTable == 0 and round == maxRounds) then
                endGame = true 
            end
        elseif(#minionTable == 0 and attackPoints <= 50 and round <maxRounds) then 
            round = round + 1
            roundText.text = round
            addAttackPoints(newAP)
            newAP = 0
            newRound = true
        elseif(#minionTable == 0 and attackPoints <= 50 and round == maxRounds) then
            endGame = true

        end
    end
end


--Every so many ticks, plays through another
--frame of the game.
function game:timer(event)
    self:play()
    if(endGame == true) then
        timer.cancel(event.source)
        self:finishGame()
    end
end

--Sets whether the game was a loss or a win
--for the server.
function game:finishGame()
    if(health <= 0 ) then 
        endGameScreen("loseScreen", score)
    else
        endGameScreen("winScreen", score)
    end 
end 

--Wipes the grid of all minions.
--Used when restarting the game.
function game:minionWipe()
    minionTemp = table.remove(minionTable)
    while minionTemp do
        minionTemp:kill()
        minionTemp = table.remove(minionTable)
    end
end
 
--Wipes the grid of all towers.
--Mostly used when restarting the game
function game:towerWipe()
    towerTemp = table.remove(towerTable)
    while towerTemp do 
        towerTemp:remove()
        towerTemp = table.remove(towerTable)
    end 
end

--Checks if a minion is in range for a tower
function game:checkHit(towerCheck, minionCheck)
    local rangeCheck = towerCheck:getRange()
    local minionX = minionCheck:getX()
    local minionY = minionCheck:getY()
    local towerX = towerCheck:getX()
    local towerY = towerCheck:getY()
    local squareSum = ((minionY-towerY)*(minionY-towerY)) + ((minionX - towerX)*(minionX-towerX))
    if(squareSum < (rangeCheck*rangeCheck)) then
        return 1
    end
    return 0
end 

--Determines current defender tower to place
function game:towerChoosen(name)
    towerChoosen = true
    towerName = name
end

--Creates the bullet and starts its movement across the screen
function game:shoot(minionHit, towerShoot)
    local bullet = display.newImage("Assets/bullet.png")
    physics.addBody(bullet, {density = 1, friction = 0, bounce = 0});
    bullet.myName = "bullet"
    bullet.x = towerShoot.x
    bullet.y = towerShoot.y
    transition.to ( bullet, { time = 100, x = minionHit.x, y = minionHit.y} )
end

--helper method when hardware back button is pressed.
function game.removeUNR()
    timeUNRText.text = ""
    timeUNRText.isVisible = false
    timeUNRText:removeSelf()
    scoreText.text = ""
    scoreText.isVisible = false
    scoreText:removeSelf()
    if(isServer == false) then
        attackPointsText.text = ""
        attackPointsText.isVisible = false
        attackPointsText:removeSelf()
    end

end 

--Checks if bullet has finally reached its destination
function onCollision(event)
    if(event.object2.myName=="bullet") then    
        event.object2.isVisible = false
        event.object2:removeSelf()
        event.object2.myName=nil
    end

    if(event.object1.myName=="bullet")then
        event.object1.isVisible = false
        event.object1:removeSelf()
        event.object1.myName=nil    
    end
end

Runtime:addEventListener("collision" , onCollision)

return game