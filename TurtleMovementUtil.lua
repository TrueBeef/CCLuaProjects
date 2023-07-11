
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

localPos = nil

lastTurnDir = turnDirection.None
currentFacingDir = facingDirection.North

currentlyGoingTo = false
goingToPos = vector.new(0, 0, 0)

local function InitializeGlobals()
	-- Prolly dont need to do these but eh
	if(localPos == nil) then
		localPos = vector.new(0, 0, 0)
	end

	lastTurnDir = turnDirection.None
	currentFacingDir = facingDirection.North
end

local function ClearSaveData()
	if(fs.exists("/Seanware/Savedata/TurtleUtilSavedata.json")) then
		local saveFile = fs.open("/Seanware/Savedata/TurtleUtilSavedata.json", "r")	
		saveFile.close()
		fs.delete("/Seanware/Savedata/TurtleUtilSavedata.json")
	end
end

--Saving and loading the last known position of this turtle.
--Helps us not get lost.
local function SaveTurtleUtilData()
	-- Also make the Movement Util save
	fs.makeDir("/Seanware/Savedata")
	local saveFile = fs.open("/Seanware/Savedata/TurtleUtilSavedata.json", "w")

	local saveData = {
			localPosX = localPos.x,
			localPosY = localPos.y,
			localPosZ = localPos.z,
			currentDir = currentFacingDir,
			currentlyGoingTo = currentlyGoingTo,
			goingToPosX = goingToPos.x,
			goingToPosY = goingToPos.y,
			goingToPosZ = goingToPos.z
		}

	encodedJson = json.encode(saveData)
	saveFile.write(encodedJson) --writes all the stuff in handle to the file defined in 'saveTo'
	saveFile.close()
end

local function LoadTurtleUtilData()
	-- Also make the Movement Util load

	local saveFile = fs.open("/Seanware/Savedata/TurtleUtilSavedata.json", "r")
	local encodedDat = saveFile.readAll()
	saveData = json.decode(encodedDat)
	saveFile.close()

	localPos = vector.new(saveData["localPosX"], saveData["localPosY"], saveData["localPosZ"])
	currentFacingDir = saveData["currentDir"]
	currentlyGoingTo = saveData["currentlyGoingTo"]
	goingToPos = vector.new(saveData["goingToPosX"], saveData["goingToPosY"], saveData["goingToPosZ"])

	print("X: " .. localPos.x)
	print("Y: " .. localPos.y)
	print("Z: " .. localPos.z)
	print("Facing Dir: " .. currentFacingDir)	
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
			totalItems = totalItems + turtle.getItemCount(i)
		end
	end

	return totalItems, slotsWithItems
end

local function MoveBackwardUtil()
	if(turtle.back()) then

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
		SaveTurtleUtilData()
		return true
	else
		return false
	end
end

-- Moves the turtle while also tallying what directions we've moved
local function MoveForwardUtil()
	if(turtle.forward()) then

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
		
		SaveTurtleUtilData()
		return true
	else
		return false
	end
end

local function MoveUpUtil()
	if(turtle.up()) then

		-- Add Z coord
		localPos = localPos + vector.new(0, 0, 1)
		SaveTurtleUtilData()
		return true
	else
		return false
	end
end

local function MoveDownUtil()
	if(turtle.down()) then
		-- Subtract Z coord
		localPos = localPos - vector.new(0, 0, 1)
		SaveTurtleUtilData()
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

	SaveTurtleUtilData()
	turtle.turnRight()
end

local function TurnLeftUtil()
	lastTurnDir = turnDirection.Left

	if(currentFacingDir == facingDirection.North) then
		currentFacingDir = facingDirection.West
	else
		currentFacingDir = currentFacingDir - 1
	end

	SaveTurtleUtilData()
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

local function GoToPosition(targetPos) 
	-- Travel Up or down
	if(targetPos.z > localPos.z) then		
		while(localPos.z ~= targetPos.z) do
			if(MoveUpUtil() == false) then
				turtle.digUp()
			end

			SaveTurtleUtilData()
		end
	elseif (targetPos.z ~= localPos.z) then
		while(localPos.z ~= targetPos.z) do
			if(MoveDownUtil() == false) then
				turtle.digDown()
			end

			SaveTurtleUtilData()
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

		SaveTurtleUtilData()
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

		SaveTurtleUtilData()
	end	

	SaveTurtleUtilData()
end

local function MoveInGrid(gridMaxWidth, gridMaxLength, inReverse)
	
	-- Every other column we swap which direction we're going. Thus the modulo.
	-- Y Starts at zero.
	if(math.fmod(localPos.y, 2) == 0) then
		
		if(inReverse == false) then

			if(localPos.x == 1) then				
				targetPos = vector.new(localPos.x + 1, localPos.y, localPos.z)
				GoToPosition(targetPos) 
				

			elseif(localPos.x < gridMaxLength) then

				local targetPos = vector.new(localPos.x + 1, localPos.y, localPos.z)
				GoToPosition(targetPos) 
				
			end		

			--Layer one
			if(localPos.x == gridMaxLength) then -- Are we as far forward as we can get?
				if(localPos.y < gridMaxWidth) then -- Are we still not at the max width?
					targetPos = vector.new(localPos.x, localPos.y + 1, localPos.z) -- Go to next column
					GoToPosition(targetPos) 
					
				end
			end

		else

			if(localPos.x == gridMaxLength) then
				
				targetPos = vector.new(localPos.x - 1, localPos.y, localPos.z)
				GoToPosition(targetPos)

			elseif(localPos.x > 1) then
				local targetPos = vector.new(localPos.x - 1, localPos.y, localPos.z)
				GoToPosition(targetPos)				
			end

			--Layer two
			if(localPos.x == 1) then
				if(localPos.y > 0) then
					targetPos = vector.new(localPos.x, localPos.y - 1, localPos.z)
					GoToPosition(targetPos) 
				end
			end
		end

	else -- If we are on an alternate column (Width)
		if(inReverse == false) then			

			if(localPos.x == gridMaxLength) then				
				targetPos = vector.new(localPos.x - 1, localPos.y, localPos.z)
				GoToPosition(targetPos) 				
				
			elseif(localPos.x > 1) then
				local targetPos = vector.new(localPos.x - 1, localPos.y, localPos.z)
				GoToPosition(targetPos)
			end
		
			--Layer one
			if(localPos.x == 1) then -- Are we as far forward as we can get?
				if(localPos.y < gridMaxWidth) then -- Are we still not at the max width?
					targetPos = vector.new(localPos.x, localPos.y + 1, localPos.z) -- Go to next column
					GoToPosition(targetPos)
				end
			end
		else
			if(localPos.x == 1) then
				targetPos = vector.new(localPos.x + 1, localPos.y, localPos.z)
				GoToPosition(targetPos) 
				
				
			elseif(localPos.x < gridMaxLength) then
				local targetPos = vector.new(localPos.x + 1, localPos.y, localPos.z)
				GoToPosition(targetPos) 
				
				
			end	

			--Layer two
			if(localPos.x == gridMaxLength) then
				if(localPos.y > 0) then
					targetPos = vector.new(localPos.x, localPos.y - 1, localPos.z)
					GoToPosition(targetPos) 					
				end
			end
		end
	end
end

local function CheckIfEndOfGrid(layMaxW, layMaxL, isReversed)
	local currentDirection, turtlePos = turtleUtil.getLocalData()
	if(isReversed == false) then
		if(turtlePos.y == layMaxW) then
			-- Are we supposed to be at the top or bottom?
			if(math.fmod(layMaxW, 2) == 0 and turtlePos.x == layMaxL) then
				--We are at the correct point. Dig down and start a new layer.
				return true
			elseif(math.fmod(layMaxW, 2) ~= 0 and turtlePos.x == 1) then
				--We are at the correct point. Dig down and start a new layer.	
				return true
			end
		end	
	else	
		-- We know we started here going forward so the 'End point' is right where we started; y0 x1.
		if(turtlePos.y == 0 and turtlePos.x == 1) then
			return true
		end
	end
	return false
end

--When this file is 'required' it returns the functions below
return { 
	initGlobals = InitializeGlobals,
	saveTurtleUtilData = SaveTurtleUtilData,
	loadTurtleUtilData = LoadTurtleUtilData,
	clearSaveData = ClearSaveData,
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
	goToPos = GoToPosition,	
	moveInGrid = MoveInGrid,
	checkEndGrid = CheckIfEndOfGrid,
	checkInventory = CheckInventoryFullnes,
	getLocalData = GetLocalPositionData,
	direction = facingDirection,	
}

	