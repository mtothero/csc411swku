--[[/************************************************************/
/* Author: 	Frat Defense Team - Matt Tothero, Josh Smith,       */
/*			Dave Clymer, Alec McCloskey                         */
/* Creation Date: March 2014 									*/
/* Modification Date: 4/4/2015								    */
/* Course: CSC354 & CSC411									    */
/* Professor Name: Dr. Parson & Dr. Frye					    */
/* Filename: Tower          									*/
/* Purpose: A tower represents a defense object. The game       */
/*			controller instantiates Tower objects				*/
/************************************************************/--]]

local Tower = {}
local Tower_mt = {__index = Tower}
local widget = require( "widget" )

function Tower.new(initX, initY, table)
	local newTower ={
		damage = table[1] or 100,
		attackSpeed = table[2] or 5,
		price = table[3] or 50,
		range = table[4] or 175,
		towerString = table[5] or "bottleThrower_standing(F)_01",

		y = initY or 50,
		x = initX or 50,
		backSwing = 0,
		towerImage = display.newImage("Assets/"..(table[5]).."/" ..(table[5]).. "_standing(" .. (initY<620 and 'F' or 'B').. ")_01.png", initX, initY),
		dir = initY<620 and 'F' or 'B'
	}
	return setmetatable(newTower, Tower_mt)
end

function Tower:attack(minionHit, theGame)
	if(self.backSwing == 0) then
		minionDeath = minionHit:hit(self.damage)
		self.backSwing = self.attackSpeed*2
		self.towerImage:removeSelf()
		self.dir = self.x<minionHit:getX() and 'R' or self.x>minionHit:getX() and 'L' or self.y < minionHit:getY() and 'F' or 'B' 
		self.towerImage = display.newImage("Assets/"..(self.towerString).."/" ..(self.towerString).. "_walking(" .. (self.dir).. ")_01.png", self.x, self.y)
		theGame:shoot(minionHit, self)
		return minionDeath 
	end
	return 0
end

function Tower:getY()
	returnY = self.y
	return returnY 
end
function Tower:getX()
	returnX = self.x
	return returnX
end

function Tower:getRange()
	return self.range
end

function Tower:remove()
	self.towerImage.isVisible = false
end

function Tower:decrementBackSwing()
	if(self.backSwing > 0) then
		self.backSwing = self.backSwing - 1
		self.towerImage:removeSelf()
		self.towerImage = display.newImage("Assets/"..(self.towerString).."/" ..(self.towerString).. "_walking(" .. (self.dir).. ")_02.png", self.x, self.y)
	end
end

return Tower