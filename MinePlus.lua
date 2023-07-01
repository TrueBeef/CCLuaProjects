turtleUtil = require("TurtleMovementUtil")

function ExcavateCustom ()
	term.clear()
	term.setCursorPos(1,1)
	term.write("How Far Forward do you want to mine?")
	term.setCursorPos(1,2)
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
	term.write("Should we return home after? (y/n)")
	returnHome = read()
		
	term.clear()	
	term.setCursorPos(1,1)	
	print("OK!")
	print("Selected Distance: " .. mineLayerLength)
	print("Selected Width: " .. mineLayerWidth)	
	print("Returning Home: " .. returnHome)	
	print("Mining!")		

	turtleUtil.initGlobals()
	turtleUtil.fuelUp()
	turtleUtil.mineLayer(mineLayerWidth, mineLayerLength)

	if(returnHome == "y") then
		turtleUtil.returnHome()
	end

	while(turtleUtil.currentFacingDir ~= turtleUtil.facingDirection.North) do
		turtleUtil.turnRight()
	end
end

ExcavateCustom()
