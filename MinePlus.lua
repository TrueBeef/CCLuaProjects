turtleUtil = require("TurtleMovementUtil")
local function MineLayer(LayerWidth, LayerLength, LayerDepth)	
	local layW = tonumber(LayerWidth)
	local layL = tonumber(LayerLength)	
	local layD = tonumber(LayerDepth)

	if(turtleUtil.moveForward() == false) then
		turtle.dig()
		turtleUtil.moveForward()
	end
	for z=1,layD, 1 do

		-- Handles the x and Y coords.
		for x=1, layL, 1 do
			for y=1, layW, 1 do
			
				local turtPos = turtleUtil.localPosition

				turtleUtil.goToPos(vector.new(x, y, turtPos.z))
				turtle.digUp()
				turtle.digDown()
			end
		end

		-- Go up or go down?
		if(layD > 0) then
			-- We want to mine up.
			if(layD ~= 0 and z ~= math.abs(layD)) then			
				--Go up 3 levels
				turtleUtil.mineUp()
				--turtleUtil.mineForward(2)
			end
		else
			-- We want to mine down			
			if(layD ~= 0 and z ~= math.abs(layD)) then			
				--Go up 3 levels
				turtleUtil.mineDown()
				-- turtleUtil.mineForward(2)
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

	MineLayer(mineLayerWidth, mineLayerLength, mineLayerDepth)

	if(returnHome == "y") then
		turtleUtil.returnHome()
	end	
end

MinePLusInit()
