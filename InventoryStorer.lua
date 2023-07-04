
local function ListChests()
	return { peripheral.find("minecraft:chest") }
end

local function ListTurtles( )
	return { peripheral.find("turtle") }
end

local function TurtleToBuffer(turtle, bufferChest)
	print("Found turtle.")
	print("Transferring to buffer...")
	
	-- turtleItem = turtle.getItemDetail(i)
	-- if not turtleItem then break end
	
	--Loop through turtle inventory
	for i=1,16, 1 do

		-- make sure this chest has atleast one empty slot.
		for j=1,bufferChest.size(), 1 do

			local item = bufferChest.getItemDetail(j)

			if(item == nil) then
				-- Pull from name, from slot, limit, to slot
				if(peripheral.getName(turtle) ~= nil) then
					bufferChest.pullItems(peripheral.getName(turtle), i, 64)
				else 
					break 
				end

				break
			end
		end
	end
end

local function BufferToBulk(bufferChest)
	print("Transferring from buffer to bulk...")	
	chestTable = ListChests()

	
		-- turtleItem = turtle.getItemDetail(i)
		-- if not turtleItem then break end	

	for _, chest in pairs(chestTable) do
		--Loop through turtle inventory
		for i=1,16, 1 do

			-- make sure this chest has atleast one empty slot.
			for j=1,chest.size(), 1 do

				local item = chest.getItemDetail(j)

				if(item == nil) then
					-- Pull from name, from slot, limit, to slot
					chest.pullItems(peripheral.getName(peripheral.find(peripheral.getName(bufferChest))), i, 64)
					break
				end
			end
		end			
	end
end

local function WaitForTurtle( )
	while(true)	do
		-- Look for turtles
		turtleTable = ListTurtles()		
		print("Buffer chest: barrel ")
		print("Looking for turtle...")
		for _, turtle in pairs(turtleTable) do
			-- We have turtles?
			
			--Find methods of peripheral. Keep for later tbh.
			-- turtleMeths = peripheral.getMethods(peripheral.getName(turtle))
			-- for _, method in pairs(turtleMeths) do
			--	print(method)
			--end
			
			local bufferChest = peripheral.find("minecraft:barrel")
			TurtleToBuffer(turtle, bufferChest)	
			BufferToBulk(bufferChest)
		end

		sleep(10)
	end
end

WaitForTurtle()



