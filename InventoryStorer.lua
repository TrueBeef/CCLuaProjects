local function ListChests()
	return { peripheral.find("minecraft:chest") }
end

local function TurtleToBuffer(turtle, bufferChest)
	print("Found turtle.")
	print("Transferring to buffer...")
	
	-- turtleItem = turtle.getItemDetail(i)
	-- if not turtleItem then break end
	
	--Loop through turtle inventory
	if(turtle ~= nil) then
		for i=1,16, 1 do			
			if(turtle ~= nil) then
				bufferChest.pullItems(peripheral.getName(turtle), i)
			end
		end
	end
end

local function BufferToBulk(bufferChest)
	print("Transferring from buffer to bulk...")	
	chestTable = ListChests()
	
	for i=1, bufferChest.size(), 1 do
		for _, chest in pairs(chestTable) do
			local attempts = 0
			local bufferItem = bufferChest.getItemDetail(i)
			while (bufferItem ~= nil) do
				if(attempts > 2) then
					break
				end
				
				chest.pullItems(peripheral.getName(bufferChest), i)
				attempts = attempts + 1
			end

			if(bufferItem == nil) then
				break
			end
		end
	end
end

local function WaitForTurtle( )
	while(true)	do
		-- Look for turtles
		term.clear()
		term.setCursorPos(1, 1)
		bufferChest = peripheral.find("minecraft:barrel")
		BufferToBulk(bufferChest)

		print("- Remember to keep turtle landing modem")
		print("open with an adjacent inventory of some kind.")
		print("- Place a barrel for turtle buffer.")
		print("")
		print("Waiting for turtle...")
		
		local turtle = nil
		turtle = peripheral.find("turtle")

		if(turtle ~= nil) then
			TurtleToBuffer(turtle, bufferChest)	
			BufferToBulk(bufferChest)
		end		

		sleep(10)
	end
end

WaitForTurtle()



