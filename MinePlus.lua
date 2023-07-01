turtleUtil = require("TurtleMovementUtil")

-- Mines one layer of material - good for mining obsidian?
local function MineLayer(LayerWidth, LayerLength, LayerDepth)	
	local layW = tonumber(LayerWidth)
	local layL = tonumber(LayerLength)	
	local layD = tonumber(LayerDepth)	

	if(turtleUtil.moveForward() == false) then
		turtle.dig()
		turtleUtil.moveForward()
	end
	for z = 0, math.abs(layD), 1 do

		for x = 1, layW, 1 do	
			turtleUtil.mineForward(layL)
		
			if(x ~= layW) then
				turtleUtil.turnMineTurn()
			end
		end

		--Turn around.
		turtleUtil.turnAround()

		-- Go up or go down?
		if(layD > 0) then
			-- We want to mine up.
			if(layD ~= 0 and z ~= math.abs(layD)) then			
				--Go up 3 levels
				turtleUtil.mineUp()
			end
		else
			-- We want to mine down			
			if(layD ~= 0 and z ~= math.abs(layD)) then			
				--Go up 3 levels
				turtleUtil.mineUp()
			end
		end
	end
end

function MinePLusInit ()
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
	term.write("Distance: " .. mineLayerLength)
	term.setCursorPos(1,2)
	term.write("Width: " .. mineLayerWidth)
	term.setCursorPos(1,3)
	term.write("Should we mine above/below? \n(e.g 50 or -50)")
	term.setCursorPos(1,4)
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

	MineLayer(mineLayerWidth, mineLayerLength, mineLayerDepth)

	if(returnHome == "y") then
		turtleUtil.returnHome()
	end

	while(turtleUtil.currentFacingDir ~= turtleUtil.facingDirection.North) do
		turtleUtil.turnRight()
	end
end

MinePLusInit()
