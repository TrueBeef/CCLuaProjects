local function SaveLocalPositioning()
	fs.makeDir("/Seanware/Savedata")
	local file = fs.open("/Seanware/Savedata/TurtleUtilSavedata.lua","w")
	
		local handle = download.readAll() --Reads everything in download
		download.close() --remember to close the download!
		local file = fs.open(saveTo,"w") --opens the file defined in 'saveTo' with the permissions to write.
		file.write(handle) --writes all the stuff in handle to the file defined in 'saveTo'
		file.close() --remember to close the file!
		term.setTextColor(colors.green)
		print("Installed file: " .. repoFile)
		else --if returned false
		term.setTextColor(colors.red)
		print("Unable to download the file ".. repoFile)
		print("Make sure you have the HTTP API enabled or")
		print("an internet connection!")
	end --end the if
end --close the function

end

SaveLocalPositioning()