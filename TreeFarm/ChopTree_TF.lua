-- Uses Lightweight Json Library by rxi. Thanks dude.
-- https://github.com/rxi/json.lua
-- json.encode({ 1, 2, 3, { x = 10 } }) -- Returns '[1,2,3,{"x":10}]'
-- json.decode('[1,2,3,{"x":10}]') -- Returns { 1, 2, 3, { x = 10 } }
json = require("json")
turtleUtil = require("TurtleMovementUtil")

treeHeight = 0
pruneLeaves = false

local function TurnAndMine()
	turtleUtil.turnLeft()
	turtle.dig()
end

function ChopTree( desiredHeight )
	turtleUtil.initGlobals()
	turtleUtil.goToPos(vector.new(1, 0, 0))	
	for i=0, desiredHeight - 1 do
		TurnAndMine()
		TurnAndMine()
		TurnAndMine()
		TurnAndMine()
		turtleUtil.goToPos(vector.new(1, 0, i))		
	end

	turtleUtil.goToPos(vector.new(0, 0, 0))	
end


local function CheckReadNum(read)
	if(tonumber(read) == nil) then
		return false
	elseif(tonumber(read) < 100) then
		return true, read
	end
end

local function CheckReadYN(read)
	if(read == "y") then
		return true
	else
		return false
	end
end


local function BeginTreeChop()	
	print("How high?")
	local success, readData = CheckReadNum(read())
	if(success == false) then		
		print("Sorry, too high. Less than 100 blocks.")		
	else
		treeHeight = readData
	end

	print("Prune adjacent blocks?")
	if(CheckReadYN(read())) then
		pruneLeaves = true
	end

	print("Choping tree")
	ChopTree(treeHeight)
end


BeginTreeChop()


