-- Uses Lightweight Json Library by rxi. Thanks dude.
-- https://github.com/rxi/json.lua
-- json.encode({ 1, 2, 3, { x = 10 } }) -- Returns '[1,2,3,{"x":10}]'
-- json.decode('[1,2,3,{"x":10}]') -- Returns { 1, 2, 3, { x = 10 } }
json = require("json")
turtleUtil = require("TurtleMovementUtil")

minutesToWait = 0
secondsRemaining = 0

farmPlotLength = 0
farmPlotWidth = 0

currentlyLowFuel = false -- Were we going home to refuel?
currentlyFullInventory = false -- Were we going home for a full inventory?
lastPos = vector.new(0, 0, 0)

local function SaveHarvestData()
	turtleUtil.saveTurtleUtilData()
	-- Also make the Movement Util save
	fs.makeDir("/Seanware/Savedata")
	local saveFile = fs.open("/Seanware/Savedata/RanchHandSaveData.json", "w")

	local saveData = {
		lastPosX = lastPos.x,
		lastPosY = lastPos.y,
		lastPosZ = lastPos.z,
		currentlyFullInventory = currentlyFullInventory,
		currentlyLowFuel = currentlyLowFuel,
		farmPlotLength = farmPlotLength,
		farmPlotWidth = farmPlotWidth,
		minutesToWait = minutesToWait,			
		secondsRemaining = secondsRemaining
	}

	encodedJson = json.encode(saveData)
	saveFile.write(encodedJson) --writes all the stuff in handle to the file defined in 'saveTo'
	saveFile.close()
end

local function LoadHarvestData()
	turtleUtil.loadTurtleUtilData()

	local saveFile = fs.open("/Seanware/Savedata/RanchHandSaveData.json", "r")
	local encodedDat = saveFile.readAll()
	saveData = json.decode(encodedDat)
	saveFile.close()

	lastPos = vector.new(saveData["lastPosX"], saveData["lastPosY"], saveData["lastPosZ"])
	currentlyFullInventory = saveData["currentlyFullInventory"]
	currentlyLowFuel = saveData["currentlyLowFuel"]

	minutesToWait = saveData["minutesToWait"]	
	secondsRemaining = saveData["secondsRemaining"]
	farmPlotLength = saveData["farmPlotLength"]
	farmPlotWidth = saveData["farmPlotWidth"]

	print("Resuming from loaded save!")
end

local function DepositResources()
	turtleUtil.goToPos(vector.new(-1, 0, 0))
	
	for i=3,16 do
		turtle.select(i)
		turtle.dropDown()
	end

	turtle.select(1)	
end

local function Return_FullInventory()
	currentlyFullInventory = true	

	term.clear()
	term.setCursorPos(1,1)
	term.write("My inventory is close to full!")
	term.setCursorPos(1,2)
	term.write("Please empty it before I continue.")
	term.setCursorPos(1,3)	
	DepositResources()

	SaveHarvestData()

	-- Sleeps for 5 seconds and checks inventory again.
	-- All items must be gone.
	local totalItems, slotsWithItems = turtleUtil.checkInventory()
	while(slotsWithItems > 2) do
		sleep(5)
		totalItems, slotsWithItems = turtleUtil.checkInventory()
	end		
	
	currentlyFullInventory = false
	SaveHarvestData()
	turtleUtil.goToPos(lastPos)
end

local function Return_OutOfFuel()
	currentlyLowFuel = true

	local currentDirection, turtlePos = turtleUtil.getLocalData()
	local costToHome = (math.abs(turtlePos.x) + math.abs(turtlePos.y) + math.abs(turtlePos.z)) + 1

	turtleUtil.goToPos(vector.new(0, 0, 0))	
	
	SaveHarvestData()
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
	turtleUtil.moveBackward()
	currentlyLowFuel = false
	SaveHarvestData()
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
	local costToHome = (math.abs(turtlePos.x) + math.abs(turtlePos.y) + math.abs(turtlePos.z)) + 1
	if(turtleUtil.checkFuel(costToHome) == true) then
		lastPos = turtlePos
		Return_OutOfFuel()
	end
end

local function HarvestActions()
	turtle.select(1)
	turtle.suckDown()
	turtle.placeDown()
	turtle.suckDown()
	turtle.suckDown()	
	CheckResources()
	SaveHarvestData()
end

local function CleanupActions()
	turtle.suckDown()
	turtle.suckDown()
	turtle.suckDown()
	turtle.suckDown()
	CheckResources()
	SaveHarvestData()
end

local function BeginHarvest()		
	while(true) do
		
		local endHarvestPass = false
		local endCleanupPass = false

		-- Go forwards one.
		turtleUtil.goToPos(vector.new(1, 0, 0))

		while(endHarvestPass == false) do
			turtleUtil.moveInGrid(farmPlotWidth, farmPlotLength, HarvestActions(), false)
			HarvestActions()
			endHarvestPass = turtleUtil.checkEndGrid(farmPlotWidth, farmPlotLength, false)
		end

		while(endCleanupPass == false) do
			turtleUtil.moveInGrid(farmPlotWidth, farmPlotLength, CleanupActions(), true)
			CleanupActions()
			endCleanupPass = turtleUtil.checkEndGrid(farmPlotWidth, farmPlotLength, true)
		end

		--Go Deposit our stuff.
		-- We should check if our inventory gets full while cleaning also
		DepositResources()

		while(secondsRemaining ~= 0) do
			sleep(1)
			secondsRemaining = secondsRemaining - 1	
			term.clear()
			term.setTextColor(colors.green)
			term.setCursorPos(1, 1)
			term.write("Time Until next harvest: ")
			term.setTextColor(colors.lime)
			term.setCursorPos(1, 2)
			term.write(tostring(math.floor(secondsRemaining / 60)) .. " Minutes and " .. tostring(math.fmod(secondsRemaining)) .. " Seconds.")
			SaveHarvestData()
		end

		term.clear()
		term.setTextColor(colors.green)
		term.setCursorPos(1, 1)
		term.write("Beginning Harvest!")
	end
end

local function InitializeFarmer()
	if(fs.exists("/Seanware/Savedata/RanchHandSaveData.json")) then
		LoadHarvestData()
	else
		print("Before We start...")
		print("Please place seeds in slot 1.")
		print("...")
		print("How Long is the plot?")
		farmPlotLength = read()

		print("How Wide is the plot?")
		farmPlotWidth = read()

		print("How many minutes to wait before harvest?")
		minutesToWait = read()
		secondsRemaining = (minutesToWait * 60)

		term.clear()
		term.setCursorPos(1,1)
		print("Beginning Harvest")
		BeginHarvest()
	end
end

InitializeFarmer()




