turtleUtil = require("TurtleMovementUtil")

versionNumber = " -== Mine Plus v1.1.18 ==- "

local function Return_DoneMining()
	term.clear()
	term.setCursorPos(1,1)
	term.write("We're done mining!'")
	term.setCursorPos(1,2)
	
	turtleUtil.goToPos(vector.new(0, 0, 0))	
	turtleUtil.faceDirection(turtleUtil.direction.North)
end

local function Return_FullInventory(leftOffPos)
	term.clear()
	term.setCursorPos(1,1)
	term.write("Our inventory is close to full!")
	term.setCursorPos(1,2)
	term.write("Empty and press enter.")
	term.setCursorPos(1,3)
	turtleUtil.goToPos(vector.new(0, 0, 0))

	read()

	local totalItems, slotsWithItems = turtleUtil.checkInventory()
	if(totalItems ~= 0) then
		Return_FullInventory()
	end

	-- We're good to go.
	turtleUtil.moveBackward()
	turtleUtil.goToPos(leftOffPos)
end


local function Return_OutOfFuel(leftOffPos, costToHome)	
	turtleUtil.goToPos(vector.new(0, 0, 0))	
	print("Add fuel and press enter.")
	
	read()

	-- Attempt to refuel with anything in the inventory
	for i=1,16 do
		turtle.select(i)
		turtle.refuel()
	end

	turtle.select(1)
	
	if(turtleUtil.checkFuel(costToHome)) then
		Return_OutOfFuel()
	end

	-- We're good to go.
	turtleUtil.goToPos(leftOffPos)
end


local function CheckResources()
	local totalItems, slotsWithItems = turtleUtil.checkInventory()
	local currentDirection, turtlePos = turtleUtil.getLocalData() -- We need the current position so that we can come back if we end up going to refuel.

	-- Check for inventory fullness
	if(slotsWithItems >= 15) then
		Return_FullInventory(turtlePos)
	end	

	-- Check fuel levels
	-- Calculate cost to get to home pos
	costToHome = (turtlePos.x + turtlePos.y + turtlePos.z + 1)
	if(turtleUtil.checkFuel(costToHome) == true) then
		Return_OutOfFuel(turtlePos, costToHome)
	end
end

local function FindBottom()
	moveDown = true

	while (moveDown) do
		moveDown = turtleUtil.moveDown()
	end

	return true		
end

local function TravelAndMineZ(desiredDepth)
	local currentDirection, turtlePos = turtleUtil.getLocalData()
	
	if(desiredDepth > 0 and turtlePos.z < desiredDepth) then
		turtleUtil.mineUp()
		return true
	end

	if(desiredDepth < 0 and turtlePos.z > desiredDepth) then
		turtleUtil.mineDown()
		return true
	end			

	return false
end


local function TravelAndMine(travelPos)
	local targetPos = vector.new(travelPos.x, travelPos.y, travelPos.z)
	turtleUtil.goToPos(targetPos)
	turtle.digUp()
	turtle.digDown()
	CheckResources()

	return turtleUtil.getLocalData()
end


local function CheckIfAtEnd(layMaxW, layMaxL, layMaxD)
	local currentDirection, turtlePos = turtleUtil.getLocalData()
	if(math.fmod(math.abs(turtlePos.z), 6) == 0) then
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


local function MineLayer(layMaxW, layMaxL, layMaxD)
	local currentDirection, turtlePos = turtleUtil.getLocalData()
	
	-- Mine forwards and backwards based on the current Y coord.
	-- Every other column we swap which direction we're going. Thus the modulo.
	-- Y Starts at zero.
	if(math.fmod(turtlePos.y, 2) == 0) then
		if(turtlePos.x == 1) then
			turtle.digUp()
			turtle.digDown()
			targetPos = vector.new(turtlePos.x + 1, turtlePos.y, turtlePos.z)
			currentDirection, turtlPos = TravelAndMine(targetPos)
		elseif(turtlePos.x < layMaxL) then
			local targetPos = vector.new(turtlePos.x + 1, turtlePos.y, turtlePos.z)
			currentDirection, turtlPos = TravelAndMine(targetPos)
		end

		-- We need to increase/decrase our Y coord
		if(turtlePos.x == layMaxL) then		
			-- Check if we're going up or down
			-- We use a mod of 6 since the turtle goes down 3 blocks every layer
			-- Every other layer we swap which direction we're going. Thus the modulo.
			if(math.fmod(math.abs(turtlePos.z), 6) == 0) then
				if(turtlePos.y < layMaxW) then
					targetPos = vector.new(turtlePos.x, turtlePos.y + 1, turtlePos.z)
				end
			else
				if(turtlePos.y > 0) then
					targetPos = vector.new(turtlePos.x, turtlePos.y - 1, turtlePos.z)
				end
			end

			currentDirection, turtlPos = TravelAndMine(targetPos)
		end
	else
		if(turtlePos.x == layMaxL) then
			turtle.digUp()
			turtle.digDown()
			targetPos = vector.new(turtlePos.x - 1, turtlePos.y, turtlePos.z)
			currentDirection, turtlPos = TravelAndMine(targetPos)
		elseif(turtlePos.x > 1) then
			local targetPos = vector.new(turtlePos.x - 1, turtlePos.y, turtlePos.z)
			currentDirection, turtlPos = TravelAndMine(targetPos)
		end

		-- We need to increase/decrase our Y coord
		-- X Starts at 1
		if(turtlePos.x == 1) then		
			-- Check if we're going up or down
			-- We use a mod of 6 since the turtle goes down 3 blocks every layer
			if(math.fmod(math.abs(turtlePos.z), 6) == 0) then
				if(turtlePos.y < layMaxW) then
					targetPos = vector.new(turtlePos.x, turtlePos.y + 1, turtlePos.z)
				end
			else
				if(turtlePos.y > 0) then
					targetPos = vector.new(turtlePos.x, turtlePos.y - 1, turtlePos.z)
				end
			end

			currentDirection, turtlPos = TravelAndMine(targetPos)
		end
	end

	
	print("x: " .. turtlPos.x .. ", y: " .. turtlPos.y .. ", z: " turtlPos.z)
	
	-- Handle depth
	if(CheckIfAtEnd() == true) then
		print("We're at the end")			
		TravelAndMineZ(layMaxD)
	end
end

local function Quarry(LayerWidth, LayerLength, LayerDepth)	
	local layW = tonumber(LayerWidth)
	local layL = tonumber(LayerLength)	
	local layD = tonumber(LayerDepth)	

	if(turtleUtil.moveForward() == false) then
		turtle.dig()
		turtleUtil.moveForward()
	end	

	
	local isDone = false
	while(isDone == false) do
		local currentDirection, turtlePos = turtleUtil.getLocalData()
		MineLayer(layW, layL, layD)
		
		if(turtlePos.z >= layD and CheckIfAtEnd() == true) then
			isDone = true
		end
	end	
end

function MinePLusInit ()
	term.clear()
	term.setCursorPos(1,1)
	term.write(versionNumber)
	term.setCursorPos(1,2)
	term.write("How Far Forward do you want to mine?")
	term.setCursorPos(1,3)
	mineLayerLength = tonumber(read())
	
	term.clear()		
	term.setCursorPos(1,1)
	term.write("Distance: " .. mineLayerLength)
	term.setCursorPos(1,2)
	term.write("How wide do you want to mine?")
	term.setCursorPos(1,3)
	mineLayerWidth = tonumber(read())

	term.clear()		
	term.setCursorPos(1,1)
	term.write("Distance: " .. mineLayerLength)
	term.setCursorPos(1,2)
	term.write("Width: " .. mineLayerWidth)
	term.setCursorPos(1,3)
	term.write("Should we mine above/below?")
	term.setCursorPos(1,4)
	term.write("(e.g 5 for up or -5 for down)")
	term.setCursorPos(1,5)
	mineLayerDepth = tonumber(read())

	term.clear()		
	term.setCursorPos(1,1)
	term.write("Distance: " .. mineLayerLength)
	term.setCursorPos(1,2)
	term.write("Width: " .. mineLayerWidth)
	term.setCursorPos(1,3)
	term.write("Depth: " .. mineLayerDepth)
	term.setCursorPos(1,4)
	term.write("Should we return home after? (y/n)")
	term.setCursorPos(1,5)	
	returnHome = read()
		
	term.clear()
	term.setCursorPos(1,1)
	print("OK!")
	print("Selected Distance: " .. mineLayerLength)
	print("Selected Width: " .. mineLayerWidth)	
	print("Selected Depth: " .. mineLayerDepth)
	print("Returning Home: " .. returnHome)	
	print("Mining!")		

	turtleUtil.initGlobals()
	turtleUtil.fuelUp()
	CheckResources()

	Quarry(mineLayerWidth - 1, mineLayerLength, mineLayerDepth)

	if(returnHome == "y" or returnHome == "Y" or returnHome == "yes") then
		Return_DoneMining()
	end
	
end

MinePLusInit()
