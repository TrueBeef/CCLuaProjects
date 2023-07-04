-- Uses Lightweight Json Library by rxi. Thanks dude.
-- https://github.com/rxi/json.lua
-- json.encode({ 1, 2, 3, { x = 10 } }) -- Returns '[1,2,3,{"x":10}]'
-- json.decode('[1,2,3,{"x":10}]') -- Returns { 1, 2, 3, { x = 10 } }

posX = 0
posY = 0
posZ = 0
facingDir = ""

json = require("json")

local function SaveLocalPositioning()
	posX = 5
	posY = -7
	posZ = 13
	facingDir = "North"

	-- Also make the Movement Util save

	fs.makeDir("/Seanware/Savedata")
	local saveFile = fs.open("/Seanware/Savedata/TestSavedata.json", "w")

	local saveData = {
			localPosX = posX,
			localPosY = posY,
			localPosZ = posZ,
			currentDir = facingDir
		}

	encodedJson = json.encode(saveData)
	saveFile.write(encodedJson) --writes all the stuff in handle to the file defined in 'saveTo'
	saveFile.close()
end --close the function

local function LoadLocalPositioning ()
	-- Also make the Movement Util load

	local saveFile = fs.open("/Seanware/Savedata/TestSavedata.json", "r")
	local encodedDat = saveFile.readAll()
	saveData = json.decode(encodedDat)

	localPos = vector.new(saveData["localPosX"], saveData["localPosY"], saveData["localPosZ"])
	currentFacingDir = saveData["currentDir"]

	print("X: " .. localPos.x)
	print("Y: " .. localPos.y)
	print("Z: " .. localPos.z)
	print("Facing Dir: " .. currentFacingDir)
end

SaveLocalPositioning()
LoadLocalPositioning()