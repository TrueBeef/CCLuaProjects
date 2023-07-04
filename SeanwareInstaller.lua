-- Shortened Raw Link: https://tinyurl.com/SeanWareInstaller
-- wget run https://tinyurl.com/SeanWareInstaller

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.orange)
print("")
print("~ SEANWARE Installer ~")
print("Checking for updates.. ")

fs.makeDir("/Seanware/Savedata")

local function InstallFromGit(repoFile, saveTo)
	local download = http.get("https://github.com/TrueBeef/CCLuaProjects/raw/main/" .. repoFile .. ".lua") --This will make 'download' hold the contents of the file.
	if(download) then --checks if download returned true or false
		local handle = download.readAll() --Reads everything in download
		download.close() --remember to close the download!
		local file = fs.open(saveTo .. ".lua","w") --opens the file defined in 'saveTo' with the permissions to write.
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

local function InstallAdditionalModules()
	term.setTextColor(colors.white)
	print("Install others? (y/n)")
	installMore = read()

	if(installMore == "y") then
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(colors.orange)
		term.write("~ SEANWARE Installer ~")
		term.setTextColor(colors.white)
		term.setCursorPos(1,2)				
		term.write("Filename in CCLuaProjectsRepo:")
		term.setCursorPos(1,3)
		local repoFile = read()

		term.clear()
		term.setCursorPos(1,1)
		term.write("Selected Filename: " .. repoFile)
		term.setCursorPos(1,2)
		term.write("Save as + in directory: ")
		term.setCursorPos(1,3)
		local saveAs = read()

		InstallFromGit(repoFile, saveAs)
	else
		term.clear()
		term.setTextColor(colors.green)
		print("Done Installing Modules.")
	end
end

--Put all our things here we for sure want installed.
-- Just the filenames.
--Check for updates to the installer.
InstallFromGit("SeanwareInstaller", "SeanwareInstaller")

term.setTextColor(colors.orange)
print("Installing Dependencies ... ")
InstallFromGit("json", "json")
InstallFromGit("TurtleMovementUtil", "TurtleMovementUtil")

-- Any additional stuff
InstallAdditionalModules()