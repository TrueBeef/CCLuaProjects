
-- More advanced turtle helpers that can be used to make full programs

turnDirection = { None = 0, Left = 1, Right = 2 }
facingDirection = { North = 1, East = 2, South = 3, West = 4 }
miningQuadrant = { Left = 0, Right = 1}

mineLayerWidth = 0
mineLayerLength = 0

localXPos = 0
localYPos = 0
localZPos = 0

lastTurnDir = turnDirection.None
currentFacingDir = facingDirection.North

local function InitializeGlobals()
	-- Prolly dont need to do these but eh
	localXPos = 0
	localYPos = 0
	localZPos = 0

	lastTurnDir = turnDirection.None
	currentFacingDir = facingDirection.North
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

-- Moves the turtle while also tallying what directions we've moved
local function MoveForwardUtil()
	if(turtle.forward()) then
		if(currentFacingDir == facingDirection.North) then
			localYPos = localYPos + 1
		elseif(currentFacingDir == facingDirection.South) then
			localYPos = localYPos - 1
		elseif(currentFacingDir == facingDirection.East) then
			localXPos = localXPos + 1
		else 
			localXPos = localXPos - 1
		end
		return true
	else
		return false
	end
end

local function MoveUpUtil()
	if(turtle.up()) then
		localZPos = localZPos + 1
		return true
	else
		return false
	end
end

local function MoveDownUtil()
	if(turtle.down()) then
		localZPos = localZPos - 1
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

local function TurnMineTurn()
	if(lastTurnDir == turnDirection.Left or lastTurnDir == turnDirection.None) then		
		TurnRightUtil()
		turtle.dig()
		MoveForwardUtil()
		turtle.digUp()
		turtle.digDown()
		TurnRightUtil()

	elseif(lastTurnDir == turnDirection.Right) then
		TurnLeftUtil()
		turtle.dig()
		MoveForwardUtil()
		turtle.digUp()
		turtle.digDown()
		TurnLeftUtil()
	end
end


-- Mines forwards X times and then returns to where it started.
local function MineForwards (MineForwardsCount)	
	local mineFwdNum = tonumber(MineForwardsCount)	
	for i = 1, mineFwdNum, 1 do
		turtle.digUp()
		turtle.digDown()		

		if(i ~= mineFwdNum) then
			if(MoveForwardUtil() == false)then
				turtle.dig()
			end
		end

		CheckFuel(mineFwdNum + mineLayerWidth)
	end	
end

-- Mines one layer of material - good for mining obsidian?
local function MineLayer(LayerWidth, LayerLength)	
	local layW = tonumber(LayerWidth)
	local layL = tonumber(LayerLength)	

	if(MoveForwardUtil() == false) then
		turtle.dig()
		MoveForwardUtil()
	end

	for x = 1, layW, 1 do	
		MineForwards(layL)
		
		if(x ~= layW) then
			TurnMineTurn()
		end
	end
end

local function ReturnHome() 

	-- Travel Up or down
	if(localZPos < 0) then		
		while(localZPos ~= 0) do
			if(MoveUpUtil() == false) then
				turtle.digUp()
			end
		end
	else
		while(localZPos ~= 0) do
			if(MoveDownUtil() == false) then
				turtle.digDown()
			end
		end
	end

	while(localXPos ~= 0) do
		if(MoveForwardUtil() == false) then
			turtle.dig()
		end
	end

	--Adjust X Pos
	if(localXPos > 0) then		
		while(currentFacingDir ~= facingDirection.West) do
			TurnRightUtil()
		end
	else
		while(currentFacingDir ~= facingDirection.East) do
			TurnLeftUtil()
		end
	end

	while(localXPos ~= 0) do
		if(MoveForwardUtil() == false) then
			turtle.dig()
		end
	end


	--Adjust Y pos
	if(localYPos > 0) then		
		while(currentFacingDir ~= facingDirection.South) do
			TurnLeftUtil()
		end		
	else
		while(currentFacingDir ~= facingDirection.North) do
			TurnRightUtil()
		end			
	end

	while(localYPos ~= 0) do
		if(MoveForwardUtil() == false) then
			turtle.dig()
		end
	end
end

--When this file is 'required' it returns the functions below
return { 
	returnHome = ReturnHome,
	fuelUp = FuelUp,
	checkFuel = CheckFuel,
	moveForward = MoveForwardUtil,
	moveUp = MoveUpUtil,
	moveDown = MoveDownUtil,
	returnHome = ReturnHome,
	turnRight = TurnRightUtil,
	turnLeft = TurnLeftUtil,
	mineForward = MineForwards,
	mineLayer = MineLayer,
	initGlobals = InitializeGlobals,
	currentFacingDir = currentFacingDir,
	facingDirection = facingDirection,
	localXPos = localXPos,
	localYPos = localYPos,
	localZPos = localZPos
}

	