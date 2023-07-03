-- Uses Lightweight Json Library by rxi. Thanks dude.
-- https://github.com/rxi/json.lua
-- json.encode({ 1, 2, 3, { x = 10 } }) -- Returns '[1,2,3,{"x":10}]'
-- json.decode('[1,2,3,{"x":10}]') -- Returns { 1, 2, 3, { x = 10 } }

json = require("json")

local function SaveLocalPositioning()
	local posX = 5
	local posY = -7
	local posZ = 13
	local facingDir = "North"

	local saveData = {}

	fs.makeDir("/Seanware/Savedata")
	local saveFile = fs.open("/Seanware/Savedata/TurtleUtilSavedata.json", "w")

	encodedJson = json.encode({saveData = { 
		posX,
		posY,
		posZ,
		facingDir 
	}})
	saveFile.write(encodedJson) --writes all the stuff in handle to the file defined in 'saveTo'
	saveFile.close() --remember to close the file!
		
	term.setTextColor(colors.green)
	print("Saved File to /Seanware/Savedata")
end --close the function

SaveLocalPositioning()