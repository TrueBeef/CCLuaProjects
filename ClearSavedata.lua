local function ClearSaveData()
	fs.delete("/Seanware/Savedata/TurtleUtilSavedata.json")
	fs.delete("/Seanware/Savedata/TurtleUtilSavedata")
	fs.delete("/Seanware/Savedata/MinePlusSaveData.json")
	fs.delete("/Seanware/Savedata/MinePlusSaveData")
end