-- Shortened Raw Link: https://tinyurl.com/SeanWareInstaller
-- wget run https://tinyurl.com/SeanWareInstaller

--[[
 ________  _______   ________  ________   ___       __   ________  ________  _______      
|\   ____\|\  ___ \ |\   __  \|\   ___  \|\  \     |\  \|\   __  \|\   __  \|\  ___ \     
\ \  \___|\ \   __/|\ \  \|\  \ \  \\ \  \ \  \    \ \  \ \  \|\  \ \  \|\  \ \   __/|    
 \ \_____  \ \  \_|/_\ \   __  \ \  \\ \  \ \  \  __\ \  \ \   __  \ \   _  _\ \  \_|/__  
  \|____|\  \ \  \_|\ \ \  \ \  \ \  \\ \  \ \  \|\__\_\  \ \  \ \  \ \  \\  \\ \  \_|\ \ 
    ____\_\  \ \_______\ \__\ \__\ \__\\ \__\ \____________\ \__\ \__\ \__\\ _\\ \_______\
   |\_________\|_______|\|__|\|__|\|__| \|__|\|____________|\|__|\|__|\|__|\|__|\|_______|
   \|_________|                                                                           
                                                                                                                                                                
--]]
-- Copyright Seanware(tm)

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.orange)       

print(" _____                               "
print("|   __|___ ___ ___ _ _ _ ___ ___ ___ "
print("|__   | -_| .'|   | | | | .'|  _| -_|"
print("|_____|___|__,|_|_|_____|__,|_| |___|"
print("")
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
		local installing = true 
		while(installing) do
			term.clear()
			term.setCursorPos(1,1)
			term.setTextColor(colors.orange)
			print(" _____                               "
			print("|   __|___ ___ ___ _ _ _ ___ ___ ___ "
			print("|__   | -_| .'|   | | | | .'|  _| -_|"
			print("|_____|___|__,|_|_|_____|__,|_| |___|"
			print("")

			term.setTextColor(colors.white)
			term.setCursorPos(1,6)				
			term.write("Filename in CCLuaProjectsRepo:")
			term.setCursorPos(1,7)
			local repoFile = read()

			term.clear()
			term.setCursorPos(1,1)
			term.write("Selected Filename: " .. repoFile)
			term.setCursorPos(1,2)
			term.write("Save as + in directory: ")
			term.setCursorPos(1,3)
			local saveAs = read()

			InstallFromGit(repoFile, saveAs)
			
			print("Install others? (y/n)")
			loopedInstallMore = read()

			if(loopedInstallMore ~= "y") then
				break
			end
		end
	end

	term.clear()
	term.setTextColor(colors.green)
	print("Done Installing Modules.")
end


InstallFromGit("SeanwareInstaller", "SeanwareInstaller")

term.setTextColor(colors.green)
print("Installing Dependencies ... ")
InstallFromGit("json", "json")
InstallFromGit("TurtleMovementUtil", "TurtleMovementUtil")

-- Any additional stuff
InstallAdditionalModules()