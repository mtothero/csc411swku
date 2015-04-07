--[[/************************************************************/
/* Author: 	Frat Defense Team - Matt Tothero, Josh Smith,       */
/*			Dave Clymer, Alec McCloskey                         */
/* Creation Date: March 2014 									*/
/* Modification Date: 4/4/2015								    */
/* Course: CSC354 & CSC411									    */
/* Professor Name: Dr. Parson & Dr. Frye					    */
/* Filename: Minion          									*/
/* Purpose: A minion represents an enemy that needs to be killed*/
/* 			off. The game controller instantiates Minion objects*/
/************************************************************/--]]

local Minion = {}
local Minion_mt = {__index = Minion}
local widget = require( "widget" )

--Class for the Minions 

--Private Variables
--local health
--local damage
--local moveSpeed
--local bounty
--local x
--local y
--Private Functions


--Public Functions

--Constructor
function Minion.new(initX, initY, initSpawnTimer, table)
	local newMinion ={
		health = table[1] or 100,
		damage = table[2] or 10,
		moveSpeed = table[3] or 30,
		bounty = table[4] or 50,
		y = initY or 50,
		x = initX or 50,

		minionString = table[5],
		minionImage = display.newImage("Assets/"..(table[5]).."/" ..(table[5]).. "_standing(R)_01.png", initX, initY),
			--display.newImage("Assets/bottleThrower.png", initX, initY),
		spawnTimer = initSpawnTimer,
		animationNum = 1
	}
	newMinion.minionImage.isVisible = false
	return setmetatable(newMinion, Minion_mt)
end

--Moves the minion, based on moveSpeed
--Dir is the direction
--1 is up
--2 is right
--3 is down
--4 is left
function Minion:move(dir)
	if(self.spawnTimer > 0) then
		self.spawnTimer = self.spawnTimer -  1
	elseif(self.spawnTimer == 0) then
		self.minionImage.isVisible = true 
		self.spawnTimer = self.spawnTimer - 1
	elseif (dir == 1) then 
		self.y = self.y - self.moveSpeed/2
		self.minionImage:removeSelf()
		self.minionImage = display.newImage("Assets/"..(self.minionString).."/" ..(self.minionString).. "_walking(B)_0" .. self.animationNum .. ".png", self.x, self.y)
		physics.addBody(self.minionImage, "static")
		self.animationNum = self.animationNum + 1
		if self.animationNum > 2 then
			self.animationNum = 1
		end 
	elseif(dir == 2) then
		self.x = self.x + self.moveSpeed/2
		self.minionImage.x = self.x
		self.minionImage:removeSelf()
		self.minionImage = display.newImage("Assets/"..(self.minionString).."/" ..(self.minionString).. "_walking(R)_0" .. self.animationNum .. ".png", self.x, self.y)
		physics.addBody(self.minionImage, "static")
		self.animationNum = self.animationNum + 1
		if self.animationNum > 2 then
			self.animationNum = 1
		end 
	end
end

function Minion:getY()
	returnY = self.y
	return returnY 
end
function Minion:getX()
	returnX = self.x
	return returnX
end

function Minion:hit(damageTaken)
	self.health = self.health - damageTaken
	if(self.health <= 0) then
		return 1
	else 
		return 0
	end
end

function Minion:kill()
	self.minionImage.isVisible = false
end

function Minion:getBounty()
	return self.bounty
end

function Minion:getDamage()
	return self.damage
end

function Minion:getImage()
	return self.minionImage
end

return Minion