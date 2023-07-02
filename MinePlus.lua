turtleUtil = require("TurtleMovementUtil")

versionNumber = " -== Mine Plus v 1.1.0 ==- "

local function MineLayerFromEnd(layW, layL)
	-- Handles the x and Y coords.
	for y=layW, 1, -1 do
		local currentDirection, turtPos = turtleUtil.getLocalData()

		if(turtPos.x == 1) then			
			--We are going to the end pos
			for x=1, layL, 1 do
			
				currentDirection, turtPos = turtleUtil.getLocalData()
				local targetPos = vector.new(x, y - 1, turtPos.z)

				turtleUtil.goToPos(targetPos)
				turtle.digUp()
				turtle.digDown()
			end
		elseif (turtPos.x == layL) then
			for x=layL, 1, -1 do		
					
				local targetPos = vector.new(x, y - 1, turtPos.z)

				turtleUtil.goToPos(targetPos)
				turtle.digUp()
				turtle.digDown()
			end
		end			
	end
end

local function MineLayerFromStart(layW, layL)
	-- Handles the x and Y coords.
	for y=1, layW, 1 do
		local currentDirection, turtPos = turtleUtil.getLocalData()

		if(turtPos.x == 1) then			
			--We are going to the end pos
			for x=1, layL, 1 do
			
				currentDirection, turtPos = turtleUtil.getLocalData()
				local targetPos = vector.new(x, y - 1, turtPos.z)

				turtleUtil.goToPos(targetPos)
				turtle.digUp()
				turtle.digDown()
			end
		elseif (turtPos.x == layL) then
			for x=layL, 1, -1 do		
					
				local targetPos = vector.new(x, y - 1, turtPos.z)

				turtleUtil.goToPos(targetPos)
				turtle.digUp()
				turtle.digDown()
			end
		end			
	end
end

local function Return_FullInventory(leftOffPos)
	term.clear()
	term.setCursorPos(1,1)
	term.write("Our inventory is close to full!")
	term.setCursorPos(1,2)
	term.write("Empty and press enter.")
	term.setCursorPos(1,3)
	goToPos(0, 0)

	read()

	local totalItems, slotsWithItems = turtleUtil.checkInventory()
	if(totalItems ~= 0) then
		Return_FullInventory()
	end

	-- We're good to go.
	turtleUtil.goToPos(leftOffPos)
end


local function Return_OutOfFuel(leftOffPos)	
	goToPos(0, 0)	
	print("Add fuel and press enter.")
	
	read()

	for i=1,16 do
		turtle.select(i)
		turtle.refuel()
	end

	turtle.select(1)
	
	if(turtleUtil.checkFuel()) then
		Return_OutOfFuel()
	end

	-- We're good to go.
	turtleUtil.goToPos(leftOffPos)

end


local function Quarry(LayerWidth, LayerLength, LayerDepth)	
	local layW = tonumber(LayerWidth)
	local layL = tonumber(LayerLength)	
	local layD = tonumber(LayerDepth)	

	if(turtleUtil.moveForward() == false) then
		turtle.dig()
		turtleUtil.moveForward()
	end	

	local goBack = false

	for z=1, (math.abs(layD) + 1), 1 do

		if(goBack == false) then
			MineLayerFromStart(layW, layL)
			goBack = true
		else
			MineLayerFromEnd(layW, layL)
			goBack = false
		end

		-- Go up or go down?
		if(layD > 0) then
			-- We want to mine up.
			if(layD ~= 0 and z ~= math.abs(layD) + 1) then			
				--Go up 3 levels
				turtleUtil.mineUp()
				--turtleUtil.mineForward(2)
			end
		else
			-- We want to mine down			
			if(layD ~= 0 and z ~= math.abs(layD) + 1) then			
				--Go up 3 levels
				turtleUtil.mineDown()
				-- turtleUtil.mineForward(2)
			end
		end

		local totalItems, slotsWithItems = turtleUtil.checkInventory()
		local currentDirection, turtPos = turtleUtil.getLocalData() -- We need the current position so that we can come back if we end up going to refuel.

		-- Check for inventory fullness
		if(slotsWithItems >= 15) then
			Return_FullInventory(turtPos)
		end	

		-- Check fuel levels
		if(turtleUtil.checkFuel() == true) then
			Return_OutOfFuel(turtPos)
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

	Quarry(mineLayerWidth, mineLayerLength, mineLayerDepth)

	if(returnHome == "y" or returnHome == "Y" or returnHome == "yes") then
		local targetPos = vector.new(0, 0, 0)	
		turtleUtil.goToPos(targetPos)
		turtleUtil.faceDirection(turtleUtil.direction.North)
	end
	
end

MinePLusInit()
