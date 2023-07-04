
-- More advanced turtle helpers that can be used to make full programs
-- Uses Lightweight Json Library by rxi. Thanks dude.
-- https://github.com/rxi/json.lua
-- json.encode({ 1, 2, 3, { x = 10 } }) -- Returns '[1,2,3,{"x":10}]'
-- json.decode('[1,2,3,{"x":10}]') -- Returns { 1, 2, 3, { x = 10 } }
json = require("json")

-- Globals --
turnDirection = { None = 0, Left = 1, Right = 2 }
facingDirection = { North = 1, East = 2, South = 3, West = 4 }
miningQuadrant = { Left = 0, Right = 1}

mineLayerWidth = 0
mineLayerLength = 0

localPos = vector.new(0, 0, 0)

lastTurnDir = turnDirection.None
currentFacingDir = facingDirection.North

local function InitializeGlobals()
	-- Prolly dont need to do these but eh
	localPos = vector.new(0, 0, 0)

	lastTurnDir = turnDirection.None
	currentFacingDir = facingDirection.North
end
--Saving and loading the last known position of this turtle.
--Helps us not get lost.
local function SaveMinePlusData()
	-- Also make the Movement Util save

	fs.makeDir("/Seanware/Savedata")
	local saveFile = fs.open("/Seanware/Savedata/TurtleUtilSavedata.json", "w")

	local saveData = {
			localPosX = localPos.x,
			localPosY = localPos.y,
			localPosZ = localPos.z,
			currentDir = currentFacingDir
		}

	encodedJson = json.encode(saveData)
	saveFile.write(encodedJson) --writes all the stuff in handle to the file defined in 'saveTo'
	saveFile.close()
end

local function LoadMinePlusData()
	-- Also make the Movement Util load

	local saveFile = fs.open("/Seanware/Savedata/TurtleUtilSavedata.json", "r")
	local encodedDat = saveFile.readAll()
	saveData = json.decode(encodedDat)

	localPos = vector.new(saveData["localPosX"], saveData["localPosY"], saveData["localPosZ"])
	currentFacingDir = saveData["currentDir"]

	print("X: " .. localPos.x)
	print("Y: " .. localPos.y)
	print("Z: " .. localPos.z)
	print("Facing Dir: " .. currentFacingDir)
end

local function ClearSavedata()
	if(fs.exists("TurtleUtilSavedata.json")) then
		fs.delete("TurtleUtilSavedata.json")
	end
end


local function GetLocalPositionData()
	return currentFacingDir, localPos
end

--This is stupid. fix later.
local function FuelUp()
	turtle.refuel()
end

-- Returns true if we need more fuel. false of all is well.
local function CheckFuel (MovementSteps)
	local fuelRemaining = turtle.getFuelLevel()
	if(fuelRemaining ~= "unlimited" and fuelRemaining < (MovementSteps + 10)) then
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(colors.red)
		term.write("We are almost out of fuel!")
		term.setCursorPos(1,2)
		term.write("Current Fuel: " .. turtle.getFuelLevel())
		term.setCursorPos(1,3)
		return true
	else
		return false
	end
end

-- Check if the inventory is full or not.
local function CheckInventoryFullnes ()
	local totalItems = 0
	local slotsWithItems = 0

	for i=1,16 do		
		if(turtle.getItemCount(i) ~= 0) then
			slotsWithItems = slotsWithItems + 1
			totalItems = totalItems + turtle.getItemCount()
		end
	end

	return totalItems, slotsWithItems
end

local function MoveBackwardUtil()
	if(turtle.back()) then
		SaveMinePlusData()

		if(currentFacingDir == facingDirection.North) then
			-- Sub to X Coord
			localPos = localPos - vector.new(1, 0, 0)
		elseif(currentFacingDir == facingDirection.South) then
			-- Add X Coord
			localPos = localPos + vector.new(1, 0, 0)
		elseif(currentFacingDir == facingDirection.East) then
			-- Subtract Y coord
			localPos = localPos - vector.new(0, 1, 0)
		else
			-- Add to Y coord
			localPos = localPos + vector.new(0, 1, 0)
		end
		return true
	else
		return false
	end
end

-- Moves the turtle while also tallying what directions we've moved
local function MoveForwardUtil()
	if(turtle.forward()) then
		SaveMinePlusData()

		if(currentFacingDir == facingDirection.North) then
			-- Add to X Coord
			localPos = localPos + vector.new(1, 0, 0)
		elseif(currentFacingDir == facingDirection.South) then
			-- Subtract X Coord
			localPos = localPos - vector.new(1, 0, 0)
		elseif(currentFacingDir == facingDirection.East) then
			-- Add to Y coord
			localPos = localPos + vector.new(0, 1, 0)
		else
			-- Subtract Y coord
			localPos = localPos - vector.new(0, 1, 0)
		end
		return true
	else
		return false
	end
end

local function MoveUpUtil()
	if(turtle.up()) then

		-- Add Z coord
		localPos = localPos + vector.new(0, 0, 1)
		SaveMinePlusData()
		return true
	else
		return false
	end
end

local function MoveDownUtil()
	if(turtle.down()) then
		-- Subtract Z coord
		localPos = localPos - vector.new(0, 0, 1)
		SaveMinePlusData()
		return true
	else
		return false
	end	
end

local function TurnRightUtil()
	lastTurnDir = turnDirection.Right
	
	if(currentFacingDir == facingDirection.West) then
		currentFacingDir = facingDirection.North
	else
		currentFacingDir = currentFacingDir + 1
	end

	turtle.turnRight()
end

local function TurnLeftUtil()
	lastTurnDir = turnDirection.Left

	if(currentFacingDir == facingDirection.North) then
		currentFacingDir = facingDirection.West
	else
		currentFacingDir = currentFacingDir - 1
	end

	turtle.turnLeft()
end

local function TurnAround()
	if(lastTurnDir == turnDirection.Left or lastTurnDir == turnDirection.None) then		
		TurnLeftUtil()
		TurnLeftUtil()

	elseif(lastTurnDir == turnDirection.Right) then
		TurnRightUtil()
		TurnRightUtil()
	end
end

local function FaceDirection(targDirection)
	while(currentFacingDir ~= targDirection) do
		if(currentFacingDir == facingDirection.North and targDirection == facingDirection.West) then
			TurnLeftUtil()
		end
		
		if(currentFacingDir == facingDirection.West and targDirection == facingDirection.North) then
			TurnRightUtil()
		end
		
		if (targDirection < (currentFacingDir)) then
			TurnLeftUtil()
		end

		if (targDirection > (currentFacingDir)) then
			TurnRightUtil()
		end
	end	
end

-- Mines down 3 blocks such that 
-- a block is above, in front, and below 
-- the turtle.
local function MineDownUtil()
	for i=1,3 do
		if(MoveDownUtil() == false) then
			turtle.digDown()
			MoveDownUtil()
		end
	end
end

local function MineUpUtil()
	for i=1,3 do
		if(MoveUpUtil() == false) then
			turtle.digUp()
			MoveUpUtil()
		end
	end
end

-- Mines forwards X times. 
-- Checks fuel levels after every move.
local function MineForwards (MineForwardsCount)	
	local mineFwdNum = tonumber(MineForwardsCount)	
	for i = 1, mineFwdNum, 1 do
		turtle.digUp()
		turtle.digDown()

		if(i ~= mineFwdNum) then
			if(MoveForwardUtil() == false)then
				turtle.dig()
				MoveForwardUtil()
			end
		end

		CheckFuel(mineFwdNum + mineLayerWidth)
	end	
end

local function GoToPosition(targetPos)
	-- Travel Up or down
	if(targetPos.z > localPos.z) then		
		while(localPos.z ~= targetPos.z) do
			if(MoveUpUtil() == false) then
				turtle.digUp()
			end
		end
	elseif (targetPos.z ~= localPos.z) then
		while(localPos.z ~= targetPos.z) do
			if(MoveDownUtil() == false) then
				turtle.digDown()
			end
		end
	end

	--Adjust Y Pos
	if(targetPos.y < localPos.y) then		
		FaceDirection(facingDirection.West)
	elseif (targetPos.y ~= localPos.y) then
		FaceDirection(facingDirection.East)
	end

	while(localPos.y ~= targetPos.y) do
		if(MoveForwardUtil() == false) then
			turtle.dig()
		end
	end

	--Adjust X pos
	if(targetPos.x < localPos.x) then		
		FaceDirection(facingDirection.South)	
	elseif (targetPos.x ~= localPos.x) then
		FaceDirection(facingDirection.North)	
	end

	while(localPos.x ~= targetPos.x) do
		if(MoveForwardUtil() == false) then
			turtle.dig()
		end
	end	
end

--When this file is 'required' it returns the functions below
return { 
	initGlobals = InitializeGlobals,
	saveTurtleUtilData = SaveMinePlusData,
	loadTurtleUtilData = LoadMinePlusData,
	clearSaveData = ClearSavedata,
	fuelUp = FuelUp,
	checkFuel = CheckFuel,
	moveForward = MoveForwardUtil,
	moveBackward = MoveBackwardUtil,
	moveUp = MoveUpUtil,
	moveDown = MoveDownUtil,	
	turnRight = TurnRightUtil,
	turnLeft = TurnLeftUtil,
	turnAround = TurnAround,
	faceDirection = FaceDirection,
	mineForward = MineForwards,	
	mineDown = MineDownUtil,
	mineUp = MineUpUtil,	
	goToPos = GoToPosition,	
	checkInventory = CheckInventoryFullnes,
	getLocalData = GetLocalPositionData,
	direction = facingDirection,	
}

	