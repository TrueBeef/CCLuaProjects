
-- More advanced turtle helpers that can be used to make full programs

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
local function SaveLocalPositioning()
	
end

local function LoadLocalPositioning()
	
end

--This is stupid. fix later.
local function FuelUp()
	turtle.refuel()
end

local function CheckFuel (MovementSteps)
	local fuelRemaining = turtle.getFuelLevel()
	if(fuelRemaining ~= "unlimited" and fuelRemaining < (MovementSteps + 5)) then
		term.clear()
		print("We ran out of fuel!")
		ReturnHome()
	end
end

local function CheckInventoryFullnes ()
	local emptySlots = 0
	local fullness = 0

-- Check if the inventory is full or not.
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
		return true
	else
		return false
	end
end

local function MoveUpUtil()
	if(turtle.up()) then
		-- Add Z coord
		localPos = localPos + vector.new(0, 0, 1)
		return true
	else
		return false
	end
end

local function MoveDownUtil()
	if(turtle.down()) then
		-- Subtract Z coord
		localPos = localPos - vector.new(0, 0, 1)
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
		if(targDirection > (currentFacingDir + 2)) then
			TurnLeftUtil()
		else
			TurnRightUtil()
		end
	end	
end

-- Mines down 3 blocks such that 
-- a block is above, in front, and below 
-- the turtle.
local function MineDownUtil()
	for i=0,4 do
		if(MoveDownUtil() == false) then
			turtle.digDown()
		end
	end
end

local function MineUpUtil()
	for i=0,4 do
		if(MoveUpUtil() == false) then
			turtle.digUp()
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
	else
		while(localPos.z ~= targetPos.z) do
			if(MoveDownUtil() == false) then
				turtle.digDown()
			end
		end
	end

	--Adjust Y Pos
	if(targetPos.y < localPos.y) then		
		FaceDirection(facingDirection.West)
	else
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
	else
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
	fuelUp = FuelUp,
	checkFuel = CheckFuel,
	moveForward = MoveForwardUtil,
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
	currentFacingDir = currentFacingDir,
	direction = facingDirection,
	localPosition = localPos
}

	