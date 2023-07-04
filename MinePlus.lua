-- Uses Lightweight Json Library by rxi. Thanks dude.
-- https://github.com/rxi/json.lua
-- json.encode({ 1, 2, 3, { x = 10 } }) -- Returns '[1,2,3,{"x":10}]'
-- json.decode('[1,2,3,{"x":10}]') -- Returns { 1, 2, 3, { x = 10 } }
json = require("json")

turtleUtil = require("TurtleMovementUtil")

versionNumber = " -== Mine Plus v1.2.7 ==- "

mineLayerLength = 0
mineLayerWidth = 0
mineLayerDepth = 0
returnHome = ""
plummet = ""
lastPos = vector.new(0, 0, 0)

local function SaveMinePlusData()
	-- Also make the Movement Util save
	turtleUtil.saveTurtleUtilData()

	fs.makeDir("/Seanware/Savedata")
	local saveFile = fs.open("/Seanware/Savedata/MinePlusSaveData.json", "w")

	local saveData = {
			mineLayerLength = mineLayerLength,
			mineLayerWidth = mineLayerWidth,
			mineLayerDepth = mineLayerDepth,
			returnHome = returnHome,
			lastPosX = lastPos.x,
			lastPosY = lastPos.y,
			lastPosZ = lastPos.z
		}

	encodedJson = json.encode(saveData)
	saveFile.write(encodedJson) --writes all the stuff in handle to the file defined in 'saveTo'
	saveFile.close()
end

local function LoadMinePlusData()
	-- Also make the Movement Util load
	turtleUtil.loadTurtleUtilData()

	print("Loading saved data...")

	local saveFile = fs.open("/Seanware/Savedata/MinePlusSaveData.json", "r")
	local encodedDat = saveFile.readAll()
	saveData = json.decode(encodedDat)

	mineLayerLength = saveData["mineLayerLength"]
	mineLayerWidth = saveData["mineLayerWidth"]
	mineLayerDepth = saveData["mineLayerDepth"]
	returnHome = saveData["returnHome"]
	lastPos = vector.new(saveData["lastPosX"], saveData["lastPosY"], saveData["lastPosZ"])

	print("L: " .. mineLayerLength)
	print("W: " .. mineLayerWidth)
	print("D: " .. mineLayerDepth)
	print("Home: " .. returnHome)
	print("LastPos X: " .. lastPos.x)
	print("LastPos Y: " .. lastPos.y)
	print("LastPos Z: " .. lastPos.z)
end

local function Return_DoneMining()
	term.clear()
	term.setCursorPos(1,1)
	term.write("We're done mining!")
	term.setCursorPos(1,2)
	
	turtleUtil.goToPos(vector.new(0, 0, 0))	
	turtleUtil.faceDirection(turtleUtil.direction.North)

	turtleUtil.clearSaveData()
end

local function Return_FullInventory()
	SaveMinePlusData()
	term.clear()
	term.setCursorPos(1,1)
	term.write("My inventory is close to full!")
	term.setCursorPos(1,2)
	term.write("Please empty it before I continue.")
	term.setCursorPos(1,3)
	turtleUtil.goToPos(vector.new(0, 0, 0))

	-- Sleeps for 5 seconds and checks inventory again.
	-- All items must be gone.
	local totalItems, slotsWithItems = turtleUtil.checkInventory()
	while(totalItems ~= 0) do
		sleep(5)
		totalItems, slotsWithItems = turtleUtil.checkInventory()
	end	

	-- We're good to go.
	turtleUtil.moveBackward()
	turtleUtil.goToPos(lastPos)
end


local function Return_OutOfFuel(costToHome)
	SaveMinePlusData()
	turtleUtil.goToPos(vector.new(0, 0, 0))	
	print("Add fuel so we may continue.")

	while(turtleUtil.checkFuel(costToHome)) do
		sleep(10)
		-- Attempt to refuel with anything in the inventory
		for i=1,16 do
			turtle.select(i)
			turtle.refuel()
		end

		turtle.select(1)
	end	

	-- We're good to go.
	turtleUtil.goToPos(lastPos)
end


local function CheckResources()
	local totalItems, slotsWithItems = turtleUtil.checkInventory()
	local currentDirection, turtlePos = turtleUtil.getLocalData() -- We need the current position so that we can come back if we end up going to refuel.

	-- Check for inventory fullness
	if(slotsWithItems >= 15) then
		lastPos = turtlePos
		Return_FullInventory()
	end	

	-- Check fuel levels
	-- Calculate cost to get to home pos
	costToHome = (turtlePos.x + turtlePos.y + turtlePos.z + 1)
	if(turtleUtil.checkFuel(costToHome) == true) then
		lastPos = turtlePos
		Return_OutOfFuel(turtlePos, costToHome)
	end
end

local function FindBottom()
	moveDown = true

	while (moveDown) do
		moveDown = turtleUtil.moveDown()
	end

	-- Go up one just to align with any previously mined portions.
	turtleUtil.moveUp()

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
	if(math.fmod(turtlePos.z, 6) == 0) then
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
		
		if(math.fmod(turtlePos.z, 6) == 0) then
			if(turtlePos.x == 1) then
				turtle.digUp()
				turtle.digDown()
				targetPos = vector.new(turtlePos.x + 1, turtlePos.y, turtlePos.z)
				currentDirection, turtlePos = TravelAndMine(targetPos)
			elseif(turtlePos.x < layMaxL) then
				local targetPos = vector.new(turtlePos.x + 1, turtlePos.y, turtlePos.z)
				currentDirection, turtlePos = TravelAndMine(targetPos)
			end		

			--Layer one
			if(turtlePos.x == layMaxL) then -- Are we as far forward as we can get?
				if(turtlePos.y < layMaxW) then -- Are we still not at the max width?
					targetPos = vector.new(turtlePos.x, turtlePos.y + 1, turtlePos.z) -- Go to next column
					currentDirection, turtlePos = TravelAndMine(targetPos)
				end
			end
		else

			if(turtlePos.x == layMaxL) then
				turtle.digUp()
				turtle.digDown()
				targetPos = vector.new(turtlePos.x - 1, turtlePos.y, turtlePos.z)
				currentDirection, turtlePos = TravelAndMine(targetPos)
			elseif(turtlePos.x > 1) then
				local targetPos = vector.new(turtlePos.x - 1, turtlePos.y, turtlePos.z)
				currentDirection, turtlePos = TravelAndMine(targetPos)
			end

			--Layer two
			if(turtlePos.x == 1) then
				if(turtlePos.y > 0) then
					targetPos = vector.new(turtlePos.x, turtlePos.y - 1, turtlePos.z)
					currentDirection, turtlePos = TravelAndMine(targetPos)
				end
			end
		end

	else -- If we are on an alternate column (Width)
		if(math.fmod(turtlePos.z, 6) == 0) then			

			if(turtlePos.x == layMaxL) then
				turtle.digUp()
				turtle.digDown()
				targetPos = vector.new(turtlePos.x - 1, turtlePos.y, turtlePos.z)
				currentDirection, turtlePos = TravelAndMine(targetPos)
			elseif(turtlePos.x > 1) then
				local targetPos = vector.new(turtlePos.x - 1, turtlePos.y, turtlePos.z)
				currentDirection, turtlePos = TravelAndMine(targetPos)
			end
		
			--Layer one
			if(turtlePos.x == 1) then -- Are we as far forward as we can get?
				if(turtlePos.y < layMaxW) then -- Are we still not at the max width?
					targetPos = vector.new(turtlePos.x, turtlePos.y + 1, turtlePos.z) -- Go to next column
					currentDirection, turtlePos = TravelAndMine(targetPos)
				end
			end			

		else

			if(turtlePos.x == 1) then
				turtle.digUp()
				turtle.digDown()
				targetPos = vector.new(turtlePos.x + 1, turtlePos.y, turtlePos.z)
				currentDirection, turtlePos = TravelAndMine(targetPos)
			elseif(turtlePos.x < layMaxL) then
				local targetPos = vector.new(turtlePos.x + 1, turtlePos.y, turtlePos.z)
				currentDirection, turtlePos = TravelAndMine(targetPos)
			end	

			--Layer two
			if(turtlePos.x == layMaxL) then
				if(turtlePos.y > 0) then
					targetPos = vector.new(turtlePos.x, turtlePos.y - 1, turtlePos.z)
					currentDirection, turtlePos = TravelAndMine(targetPos)
				end
			end
		end
	end


	currentDirection, turtlePos = turtleUtil.getLocalData()
	print("x: " .. turtlePos.x .. ", y: " .. turtlePos.y .. ", z: " .. turtlePos.z)	
	
	-- Handle depth
	if(CheckIfAtEnd(layMaxW, layMaxL, layMaxD) == true) then
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

	if(plummet == "y") then	
		FindBottom()
	end
	
	local isDone = false
	while(isDone == false) do
		local currentDirection, turtlePos = turtleUtil.getLocalData()
		MineLayer(layW, layL, layD)
		
		if(math.abs(turtlePos.z) >= math.abs(layD) and CheckIfAtEnd(layW, layL, layD) == true) then
			isDone = true
		end
	end	
end

local function BeginMineProcess()

	turtleUtil.initGlobals()
	turtleUtil.fuelUp()
	CheckResources()

	Quarry(mineLayerWidth - 1, mineLayerLength, mineLayerDepth)

	if(returnHome == "y" or returnHome == "Y" or returnHome == "yes") then
		Return_DoneMining()
	end
end

local function CheckForLoadData()
	if(fs.exists("/Seanware/Savedata/MinePlusSaveData.json")) then
		LoadMinePlusData()
		BeginMineProcess()
		return true
	else
		return false
	end
end

local function MinePlusInit ()
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
	term.write("Distance: " .. mineLayerLength)
	term.setCursorPos(1,2)
	term.write("Width: " .. mineLayerWidth)
	term.setCursorPos(1,3)
	term.write("Depth: " .. mineLayerDepth)
	term.setCursorPos(1,4)
	term.write("Homing: " .. returnHome)
	term.setCursorPos(1,5)
	term.write("Plummet to bottom initially? (y/n)")
	term.setCursorPos(1,6)	
	plummet = read()	

	term.clear()		
	term.setCursorPos(1,1)
	term.write("Distance: " .. mineLayerLength)
	term.setCursorPos(1,2)
	term.write("Width: " .. mineLayerWidth)
	term.setCursorPos(1,3)
	term.write("Depth: " .. mineLayerDepth)
	term.setCursorPos(1,4)
	term.write("Homing: " .. returnHome)
	term.setCursorPos(1,5)	
	term.write("Use save/load system? (y/n)")
	term.setCursorPos(1,6)	
	useSaveLoad = read()
		
	term.clear()
	term.setCursorPos(1,1)
	print("OK!")
	print("Selected Distance: " .. mineLayerLength)
	print("Selected Width: " .. mineLayerWidth)	
	print("Selected Depth: " .. mineLayerDepth)
	print("Returning Home: " .. returnHome)	
	print("Mining!")

	if(useSaveLoad == "y") then
		SaveMinePlusData()
	end

	BeginMineProcess()
end

if(CheckForLoadData() == false) then
	MinePlusInit()
end


