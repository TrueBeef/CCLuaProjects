

function FindEmptySlot()
	
end

function PushToInventory( ... )
	-- body
end

function ListChests()
	return { peripheral.find("minecraft:chest") }
end

function ListTurtles( )
	return { peripheral.find("turtle") }
end

function TurtleToBulk(turtle)
	chestTable = ListChests()
	
	for i=1,16 do
		turtleItem = turtle.getItemDetail(i)

		selectedChestSlot = nil

		--Loop through turtle inventory
		for _, chest in pairs(chestTable) do
			-- find a chest with an empty slot.
			for j=1,chest.size() do
				local item = chest.getItemDetail(j)

				if(item ~= nil) then
					-- Check if item name is the same as our turtleItem name
					if(item.name == turtleItem.name) then
						local remainingSpace = (item.maxCount - item.count)

					end
				end
			end

			if(selectedChestSlot ~= nil) then
				break
			end
		end
	end
end

function WaitForTurtle( )
	while(true)	do
		-- Look for turtles
		turtleTable = ListTurtles()

		for _, turtle in pairs(turtleTable) do
			-- We have turtles?
			TurtleToBulk(turtle)
		end

		sleep(10)
	end
end



