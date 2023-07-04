local function ClearSaveData()
	if(fs.exists("/Seanware/Savedata/TurtleUtilSavedata.json")) then
		fs.delete("/Seanware/Savedata/TurtleUtilSavedata.json")
	end

	if(fs.exists("/Seanware/Savedata/MinePlusSaveData.json")) then
		fs.delete("/Seanware/Savedata/MinePlusSaveData.json")
	end
end