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
	term.setCursorPos(1,3)	
	print("OK!")
	print("Selected Distance: " .. mineLayerLength)
	print("Selected Width: " .. mineLayerWidth)	
	print("Mining!")		

	turtleUtil.FuelUp()
	turtleUtil.MineLayer(mineLayerWidth, mineLayerLength)
	turtleUtil.ReturnHome()

	while(currentFacingDir ~= facingDirection.North) do
		turtleUtil.TurnRightUtil()
	end
end

ExcavateCustom()
