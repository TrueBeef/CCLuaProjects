turtleUtil = require("TurtleMovementUtil")

function ExcavateCustom ()
	term.clear()
	sleep(0.2)
	print("Mine Layer Depth: ")
	mineLayerLength = tonumber(read())

		
	term.clear()	
	sleep(0.2)
	print("Selected Depth: " .. mineLayerLength)
	print("")
	print("Mine Layer Width: ")
	mineLayerWidth = tonumber(read())

		
	term.clear()	
	sleep(0.2)
	print("OK!")
	print("Selected Depth: " .. mineLayerLength)
	print("Selected Width: " .. mineLayerWidth)	
	print("Mining!")
		

	turtleUtil.FuelUp()
	turtleUtil.MineLayer(mineLayerWidth, mineLayerLength)
	turtleUtil.ReturnHome()

	while(currentFacingDir ~= facingDirection.North) do
		turtleUtil.TurnRightUtil()
	end
end

MineLayer()
