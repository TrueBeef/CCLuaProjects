json = require("json")

secondsRemaining = 0
desiredTimer = 0

local function SaveTimerData()

	fs.makeDir("/Seanware/Savedata")
	local saveFile = fs.open("/Seanware/Savedata/BreedTimer.json", "w")

	local saveData = {
		secondsRemaining = secondsRemaining,
		desiredTimer = desiredTimer
	}

	encodedJson = json.encode(saveData)
	saveFile.write(encodedJson) --writes all the stuff in handle to the file defined in 'saveTo'
	saveFile.close()
end

local function LoadTimerData()
	-- Also make the Movement Util load	

	print("Loading saved data...")

	local saveFile = fs.open("/Seanware/Savedata/BreedTimer.json", "r")
	local encodedDat = saveFile.readAll()
	saveData = json.decode(encodedDat)
	saveFile.close()

	secondsRemaining = saveData["secondsRemaining"]
	desiredTimer = saveData["desiredTimer"]
end

function BeginLoad()
	LoadTimerData()
	CheckTimer()
end

function TriggerBreed()
	-- Redstone signal on each side
	redstone.setOutput("left", true)
	redstone.setOutput("right", true)
	sleep(.2)
	redstone.setOutput("left", false)
	redstone.setOutput("right", false)	
end

function CheckTimer()
	while(secondsRemaining ~= 0) do
		sleep(1)
		secondsRemaining = secondsRemaining - 1	
		term.clear()
		term.setTextColor(colors.green)
		term.setCursorPos(1, 1)
		term.write("Time until next trigger: ")
		term.setTextColor(colors.lime)
		term.setCursorPos(1, 2)
		term.write(tostring(math.floor(secondsRemaining / 60)) .. " Minutes and " .. tostring(math.fmod(secondsRemaining, 60)) .. " Seconds.")
		SaveTimerData()
	end

	TriggerBreed()
	secondsRemaining = desiredTimer
	SaveTimerData()
	CheckTimer()
end

local function InitializeTimer()
	if(fs.exists("/Seanware/Savedata/BreedTimer.json")) then
		BeginLoad()
	else
		term.clear()
		term.setCursorPos(1, 1)			
		print("How long should we wait? (Minutes)")
		minutesToWait = tonumber(read())
		secondsRemaining = (minutesToWait * 60)
		desiredTimer = secondsRemaining 
		SaveTimerData()
		TriggerBreed()
		CheckTimer()
	end
end

InitializeTimer()